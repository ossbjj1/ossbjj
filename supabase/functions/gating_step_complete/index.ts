// supabase/functions/gating_step_complete/index.ts
// Server-Authoritative Step Completion with Gating (Sprint 4 MVP)
//
// Enforces:
// - Authentication (JWT required)
// - Prerequisite checks (previous step must be completed)
// - Freemium gating (idx >= 3 requires premium/trial)
// - Idempotency (duplicate calls handled gracefully)
// - Rate limiting (per user)
//
// Replaces direct client RPC calls to mark_step_complete with server validation.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Json = Record<string, unknown>;

interface CompleteStepRequest {
  technique_step_id: string;
}

interface CompleteStepResponse {
  success: boolean;
  idempotent: boolean;
  message: string;
}

interface StepInfo {
  idx: number;
  variant: string;
  technique_id: string;
}

interface UserProfile {
  entitlement: string;
  trial_end_at: string | null;
}

// Helper: Consistent JSON response
function resp(
  body: Json,
  status: number,
  headers: Record<string, string> = {},
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

// Helper: CORS headers (allow all for MVP, restrict in production)
function getCorsHeaders(): Record<string, string> {
  const origin = Deno.env.get("CORS_ALLOWED_ORIGINS") || "*";
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "600",
  };
}

// Helper: Structured logging with hashed user ID
async function log(
  event: string,
  fields: Json,
  level: "info" | "warn" | "error" = "info",
) {
  const logLevel = Deno.env.get("LOG_LEVEL") || "info";
  const levels = { info: 0, warn: 1, error: 2 };
  if (levels[level] < levels[logLevel as keyof typeof levels]) return;

  console.log(
    JSON.stringify({ ts: new Date().toISOString(), event, level, ...fields }),
  );
}

async function hashUserId(uid: string): Promise<string> {
  const bytes = new TextEncoder().encode(uid);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// Helper: Simple in-memory rate limiter (per user, 2s window)
const rateLimitMap = new Map<string, number>();
function checkRateLimit(userId: string): boolean {
  const now = Date.now();
  const key = `user:${userId}`;
  const lastCall = rateLimitMap.get(key) || 0;
  if (now - lastCall < 2000) {
    return false; // Rate limited
  }
  rateLimitMap.set(key, now);
  // Cleanup old entries (simple TTL)
  if (rateLimitMap.size > 10000) {
    const cutoff = now - 10000;
    for (const [k, v] of rateLimitMap.entries()) {
      if (v < cutoff) rateLimitMap.delete(k);
    }
  }
  return true;
}

serve(async (req) => {
  const reqId = crypto.randomUUID();
  const t0 = Date.now();
  const corsHeaders = getCorsHeaders();

  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return resp({ error: "method_not_allowed" }, 405, corsHeaders);
  }

  try {
    // Validate environment
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
      await log(
        "server_config_error",
        { reqId, error: "Missing env vars" },
        "error",
      );
      return resp({ error: "server_error" }, 500, corsHeaders);
    }

    // 1. Authenticate user via JWT
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      await log("auth_required", { reqId }, "warn");
      return resp({ error: "unauthorized" }, 401, corsHeaders);
    }

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabaseClient.auth
      .getUser();
    if (authError || !user) {
      await log("auth_invalid", { reqId, error: authError?.message }, "warn");
      return resp({ error: "unauthorized" }, 401, corsHeaders);
    }

    const userIdHash = await hashUserId(user.id);

    // 2. Rate limiting (simple: 2s cooldown per user)
    if (!checkRateLimit(user.id)) {
      await log("rate_limited", { reqId, userIdHash }, "warn");
      return resp(
        { error: "rate_limited", retryAfter: 2 },
        429,
        { ...corsHeaders, "Retry-After": "2" },
      );
    }

    // 3. Parse request body
    let body: CompleteStepRequest;
    try {
      body = await req.json();
    } catch (e) {
      await log("bad_request", { reqId, userIdHash, error: String(e) }, "warn");
      return resp({ error: "bad_request" }, 400, corsHeaders);
    }

    const { technique_step_id } = body;
    if (!technique_step_id || typeof technique_step_id !== "string") {
      await log("bad_request", {
        reqId,
        userIdHash,
        reason: "missing_technique_step_id",
      }, "warn");
      return resp({ error: "bad_request" }, 400, corsHeaders);
    }

    // 4. Fetch step info (idx, variant, technique_id) via anon client (RLS allows read)
    const { data: stepData, error: stepError } = await supabaseClient
      .from("technique_step")
      .select("idx, variant, technique_id")
      .eq("id", technique_step_id)
      .single();

    if (stepError || !stepData) {
      await log("step_not_found", {
        reqId,
        userIdHash,
        technique_step_id,
        error: stepError?.message,
      }, "warn");
      return resp({ error: "not_found" }, 404, corsHeaders);
    }

    const stepInfo = stepData as StepInfo;

    // 5. Prerequisite check: if idx > 0, ensure previous step (idx-1) is completed
    if (stepInfo.idx > 0) {
      const { data: prevStepData, error: prevStepError } = await supabaseClient
        .from("technique_step")
        .select("id")
        .eq("technique_id", stepInfo.technique_id)
        .eq("variant", stepInfo.variant)
        .eq("idx", stepInfo.idx - 1)
        .single();

      if (prevStepError || !prevStepData) {
        await log("prerequisite_missing", {
          reqId,
          userIdHash,
          technique_step_id,
          idx: stepInfo.idx,
          reason: "prev_step_not_found",
        }, "warn");
        return resp({ error: "prerequisite_missing" }, 409, corsHeaders);
      }

      const prevStepId = prevStepData.id as string;

      // Check if user has completed previous step
      const { data: prevProgressData, error: prevProgressError } =
        await supabaseClient
          .from("user_step_progress")
          .select("technique_step_id")
          .eq("user_id", user.id)
          .eq("technique_step_id", prevStepId)
          .maybeSingle();

      if (prevProgressError) {
        await log("progress_check_error", {
          reqId,
          userIdHash,
          error: prevProgressError.message,
        }, "error");
        return resp({ error: "server_error" }, 500, corsHeaders);
      }

      if (!prevProgressData) {
        await log("prerequisite_missing", {
          reqId,
          userIdHash,
          technique_step_id,
          idx: stepInfo.idx,
          reason: "prev_step_incomplete",
        }, "warn");
        return resp({ error: "prerequisite_missing" }, 409, corsHeaders);
      }
    }

    // 6. Freemium gating: idx >= 2 (step 3+) requires premium/trial
    if (stepInfo.idx >= 2) {
      const { data: profileData, error: profileError } = await supabaseClient
        .from("user_profile")
        .select("entitlement, trial_end_at")
        .eq("user_id", user.id)
        .maybeSingle();

      if (profileError) {
        await log("profile_fetch_error", {
          reqId,
          userIdHash,
          error: profileError.message,
        }, "error");
        return resp({ error: "server_error" }, 500, corsHeaders);
      }

      const profile = profileData as UserProfile | null;
      const entitlement = profile?.entitlement || "free";
      const trialEndAt = profile?.trial_end_at;

      const isPro = entitlement === "pro" || entitlement === "premium";
      const isTrialActive = entitlement === "trial" && trialEndAt &&
        new Date(trialEndAt) > new Date();

      if (!isPro && !isTrialActive) {
        await log("payment_required", {
          reqId,
          userIdHash,
          technique_step_id,
          idx: stepInfo.idx,
          entitlement,
        }, "info");
        return resp({ error: "payment_required" }, 402, corsHeaders);
      }
    }

    // 7. Call RPC with service_role to mark step complete
    const supabaseServiceClient = createClient(
      supabaseUrl,
      supabaseServiceRoleKey,
    );

    const { data: rpcData, error: rpcError } = await supabaseServiceClient
      .rpc("mark_step_complete", { p_technique_step_id: technique_step_id });

    if (rpcError) {
      await log("rpc_error", {
        reqId,
        userIdHash,
        technique_step_id,
        error: rpcError.message,
      }, "error");
      return resp({ error: "server_error" }, 500, corsHeaders);
    }

    const result = (rpcData as unknown as CompleteStepResponse[])?.[0];
    if (!result) {
      await log("rpc_no_result", { reqId, userIdHash, technique_step_id }, "error");
      return resp({ error: "server_error" }, 500, corsHeaders);
    }

    const durationMs = Date.now() - t0;
    await log("step_completed", {
      reqId,
      userIdHash,
      technique_step_id,
      idx: stepInfo.idx,
      success: result.success,
      idempotent: result.idempotent,
      durationMs,
    });

    return resp(result, 200, corsHeaders);
  } catch (error) {
    const durationMs = Date.now() - t0;
    await log("unexpected_error", {
      reqId,
      error: String(error),
      durationMs,
    }, "error");
    return resp({ error: "server_error" }, 500, corsHeaders);
  }
});
