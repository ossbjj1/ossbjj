// Simple health endpoint for uptime checks (multi-region). Returns 200 and basic metadata.
// Deploy with: supabase functions deploy health --project-ref <ref>
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

interface HealthResponse {
  status: string;
  region: string;
  time: string;
}

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin",
      "Access-Control-Allow-Methods": "HEAD, GET, OPTIONS"
    }
  });
}

serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "HEAD, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin"
      }
    });
  }

  if (req.method === "HEAD" || req.method === "GET") {
    const region = Deno.env.get("REGION") || "eu";
    const now = new Date().toISOString();
    const response: HealthResponse = { status: "ok", region, time: now };
    return jsonResponse(response);
  }

  return jsonResponse(
    { error: "method_not_allowed" },
    405,
  );
});
