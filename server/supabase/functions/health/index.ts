// deno-lint-ignore-file no-explicit-any
// Simple health endpoint for uptime checks (EU). Returns 200 and basic metadata.
// Deploy with: supabase functions deploy health --project-ref <ref>
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

function jsonResponse(body: any, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,OPTIONS",
      },
    });
  }

  if (req.method !== "GET") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const now = new Date().toISOString();
  return jsonResponse({ status: "ok", region: "eu", time: now });
});
