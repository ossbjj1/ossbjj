// server/supabase/functions/gating_check_step_access/index.ts
// Server-Authoritative Step Access Check (Sprint 4.1 Production)
//
// Replaces client-side entitlement checks with server-side validation.
// Production hardening: CORS whitelist, rate limiting, structured logging.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type GatingReason = "free" | "premium" | "premiumRequired" | "authRequired";
type Json = Record<string, unknown>;

interface CheckAccessRequest {
  techniqueStepId: string;
}

interface CheckAccessResponse {
  allowed: boolean;
  reason: GatingReason;
}

interface RateLimitConfig {
  cap: number;
  windowSeconds: number;
}

// Helper: Consistent response format
function resp(body: Json, status: number, headers: Record<string, string> = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

// Helper: Parse rate limit config (e.g., "30/m" -> {cap:30, window:60})
function parseEnvRate(rateStr: string): RateLimitConfig {
  const match = rateStr.match(/^(\d+)\/(m|h)$/);
  if (!match) return { cap: 30, windowSeconds: 60 }; // Default 30/min
  const cap = parseInt(match[1], 10);
  const windowSeconds = match[2] === "m" ? 60 : 3600;
  return { cap, windowSeconds };
}

// Helper: Upstash rate-limit using pipeline with timeout
async function upstashIncr(
  key: string,
  ttlSeconds: number,
): Promise<number | null> {
  const url = Deno.env.get("UPSTASH_REDIS_REST_URL");
  const token = Deno.env.get("UPSTASH_REDIS_REST_TOKEN");
  if (!url || !token) return null; // Upstash not configured

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 4000);

  try {
    const encKey = encodeURIComponent(key);
    // Use pipeline for atomic INCR + EXPIRE NX
    const pipeBody = JSON.stringify({
      pipeline: [
        ["INCR", encKey],
        ["EXPIRE", encKey, ttlSeconds, "NX"],
      ],
    });
    const pipeResp = await fetch(`${url}/pipeline`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: pipeBody,
      signal: controller.signal,
    });
    if (!pipeResp.ok) throw new Error(`pipeline ${pipeResp.status}`);
    const results = await pipeResp.json();
    // results = { result: [ { result: number }, { result: 1|0 } ] }
    const count = (results?.result?.[0]?.result as number) ?? null;
    return typeof count === "number" ? count : null;
  } catch (e) {
    console.error("Upstash pipeline error:", e);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

// Helper: Rate limit check
async function checkRateLimit(
  scopeKey: string,
  config: RateLimitConfig,
): Promise<{ ok: boolean; retryAfter?: number }> {
  const count = await upstashIncr(scopeKey, config.windowSeconds);
  if (count === null) {
    // Upstash down, fail-open with warning
    console.warn("Rate limiting unavailable, allowing request");
    return { ok: true };
  }

  if (count > config.cap) {
    const retryAfter = config.windowSeconds;
    return { ok: false, retryAfter };
  }

  return { ok: true };
}

// Helper: Get origin for CORS
function getOrigin(req: Request): string | null {
  return req.headers.get("Origin");
}

// Helper: Get IP (Cloudflare/Deno Deploy)
function getIp(req: Request): string {
  const cf = req.headers.get("CF-Connecting-IP");
  if (cf) return cf;
  const xr = req.headers.get("X-Real-IP");
  if (xr) return xr;
  const xc = req.headers.get("X-Client-IP");
  if (xc) return xc;
  const xff = req.headers.get("X-Forwarded-For");
  if (xff && xff.length > 0) return xff.split(",")[0].trim();
  return "unknown";
}

// Helper: CORS headers (dynamic origin)
function getCorsHeaders(
  origin: string | null,
  allowedOrigins: Set<string>,
  allowAll: boolean,
): Record<string, string> {
  if (!origin) return {};
  if (!allowAll && !allowedOrigins.has(origin)) return {};
  return {
    "Access-Control-Allow-Origin": allowAll ? "*" : origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "600",
    "Vary": "Origin",
  };
}

// Helper: Structured logging
function log(
  event: string,
  fields: Json,
  level: "info" | "warn" | "error" = "info",
) {
  const logLevel = Deno.env.get("LOG_LEVEL") || "info";
  const levels = { info: 0, warn: 1, error: 2 };
  if (levels[level] < levels[logLevel as keyof typeof levels]) return;

  console.log(JSON.stringify({ ts: new Date().toISOString(), event, level, ...fields }));
}

async function hashUserId(uid: string): Promise<string> {
  const bytes = new TextEncoder().encode(uid);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

serve(async (req) => {
  const reqId = crypto.randomUUID();
  const t0 = Date.now();
  const ip = getIp(req);
  const origin = getOrigin(req);

  // Parse CORS whitelist
  const corsOriginsEnv = Deno.env.get("CORS_ALLOWED_ORIGINS") || "";
  const allowedOrigins = new Set(corsOriginsEnv.split(",").map(o => o.trim()).filter(Boolean));
  const allowAll = allowedOrigins.size === 0; // dev-mode: allow all origins
  const corsHeaders = getCorsHeaders(origin, allowedOrigins, allowAll);

  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  // Check origin (if configured)
  if (corsOriginsEnv && origin && !allowedOrigins.has(origin)) {
    log("origin_forbidden", { reqId, origin, ip }, "warn");
    return resp({ error: "origin_forbidden" }, 403, corsHeaders);
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      log("auth_required", { reqId, ip }, "warn");
      return resp({ allowed: false, reason: "authRequired" }, 401, corsHeaders);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // 1. Verify JWT and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      log("auth_invalid", { reqId, ip, error: authError?.message }, "warn");
      return resp({ allowed: false, reason: "authRequired" }, 401, corsHeaders);
    }
    const userHash = await hashUserId(user.id);

    // 2. Rate limiting (per user preferred, IP fallback)
    const userRateConfig = parseEnvRate(Deno.env.get("RL_USER_RATE") || "30/m");
    const ipRateConfig = parseEnvRate(Deno.env.get("RL_IP_RATE") || "60/m");
    const userEpoch = Math.floor(Date.now() / (userRateConfig.windowSeconds * 1000));
    const ipEpoch = Math.floor(Date.now() / (ipRateConfig.windowSeconds * 1000));
    const userKey = `rl:gating_check:user:${user.id}:${userEpoch}`;
    const ipKey = `rl:gating_check:ip:${ip}:${ipEpoch}`;

    const userRL = await checkRateLimit(userKey, userRateConfig);
    if (!userRL.ok) {
      log("rate_limited", { reqId, userIdHash: userHash, scope: "user", retryAfter: userRL.retryAfter }, "warn");
      return resp(
        { error: "rate_limited", retryAfter: userRL.retryAfter },
        429,
        { ...corsHeaders, "Retry-After": String(userRL.retryAfter) },
      );
    }

    const ipRL = await checkRateLimit(ipKey, ipRateConfig);
    if (!ipRL.ok) {
      log("rate_limited", { reqId, ip, scope: "ip", retryAfter: ipRL.retryAfter }, "warn");
      return resp(
        { error: "rate_limited", retryAfter: ipRL.retryAfter },
        429,
        { ...corsHeaders, "Retry-After": String(ipRL.retryAfter) },
      );
    }

    // 3. Parse request body
    let body: unknown;
    try {
      body = await req.json();
    } catch (e) {
      log("bad_request", { reqId, userId: user.id, parseError: String(e) }, "warn");
      return resp({ error: "bad_request" }, 400, corsHeaders);
    }
    const techniqueStepId = (body as Record<string, unknown>)?.["techniqueStepId"];
    if (typeof techniqueStepId !== "string" || techniqueStepId.length === 0) {
      log("bad_request", { reqId, userId: user.id, reason: "missing_or_invalid_stepId" }, "warn");
      return resp({ error: "bad_request" }, 400, corsHeaders);
    }

    // 4. Fetch step index from technique_step table (server-side query)
    const { data: stepData, error: stepError } = await supabase
      .from("technique_step")
      .select("idx")
      .eq("id", techniqueStepId)
      .single();

    if (stepError || !stepData) {
      log("step_not_found", { reqId, userIdHash: userHash, techniqueStepId }, "warn");
      return resp({ error: "not_found" }, 404, corsHeaders);
    }

    const idx = stepData.idx as number;

    // 5. Free tier: idx 0-1 (steps 1-2)
    if (idx <= 1) {
      const response: CheckAccessResponse = { allowed: true, reason: "free" };
      const durationMs = Date.now() - t0;
      log("gating_check_step_access", {
        reqId,
        userIdHash: userHash,
        techniqueStepId,
        idx,
        decision: { allowed: true, reason: "free" },
        durationMs,
      });
      return resp(response, 200, corsHeaders);
    }

    // 6. Premium required for idx >= 2 (step 3+)
    // Fetch entitlement from user_profile (server-side, RLS-protected)
    const { data: profileData, error: profileError } = await supabase
      .from("user_profile")
      .select("entitlement")
      .eq("user_id", user.id)
      .maybeSingle();

    if (profileError) {
      log("profile_fetch_error", { reqId, userIdHash: userHash, error: profileError.message }, "error");
      return resp({ error: "server_error" }, 500, corsHeaders);
    }

    const entitlement = (profileData?.entitlement as string) ?? "free";
    const allowed = entitlement === "premium" || entitlement === "pro";
    const reason: GatingReason = allowed ? "premium" : "premiumRequired";
    const response: CheckAccessResponse = { allowed, reason };

    const durationMs = Date.now() - t0;
    log("gating_check_step_access", {
      reqId,
      userIdHash: userHash,
      techniqueStepId,
      idx,
      entitlement,
      decision: { allowed, reason },
      durationMs,
    });

    return resp(response, 200, corsHeaders);
  } catch (error) {
    const durationMs = Date.now() - t0;
    log("unexpected_error", { reqId, ip, error: String(error), durationMs }, "error");
    // Include CORS on 500
    const corsOriginsEnv = Deno.env.get("CORS_ALLOWED_ORIGINS") || "";
    const allowedOrigins = new Set(corsOriginsEnv.split(",").map(o => o.trim()).filter(Boolean));
    const allowAll = allowedOrigins.size === 0;
    const origin = getOrigin(req);
    const headers = getCorsHeaders(origin, allowedOrigins, allowAll);
    return resp({ error: "server_error", detail: String(error) }, 500, headers);
  }
});
