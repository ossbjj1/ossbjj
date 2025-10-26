// server/supabase/functions/gating_check_step_access/index.ts
// Server-Authoritative Step Access Check (Sprint 4.1 Security Fix)
//
// Replaces client-side entitlement checks with server-side validation.
// Prevents bypassing premium gating via app binary manipulation.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type GatingReason = "free" | "premium" | "premiumRequired" | "authRequired";

interface CheckAccessRequest {
  techniqueStepId: string;
}

interface CheckAccessResponse {
  allowed: boolean;
  reason: GatingReason;
}

serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      return new Response(
        JSON.stringify({ allowed: false, reason: "authRequired" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // 1. Verify JWT and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ allowed: false, reason: "authRequired" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 2. Parse request body
    const { techniqueStepId }: CheckAccessRequest = await req.json();
    if (!techniqueStepId) {
      return new Response(
        JSON.stringify({ error: "technique_step_id required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 3. Fetch step index from technique_step table (server-side query)
    const { data: stepData, error: stepError } = await supabase
      .from("technique_step")
      .select("idx")
      .eq("id", techniqueStepId)
      .single();

    if (stepError || !stepData) {
      return new Response(
        JSON.stringify({ error: "step_not_found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const idx = stepData.idx as number;

    // 4. Free tier: idx 0-1 (steps 1-2)
    if (idx <= 1) {
      const response: CheckAccessResponse = { allowed: true, reason: "free" };
      return new Response(JSON.stringify(response), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Premium required for idx >= 2 (step 3+)
    // Fetch entitlement from user_profile (server-side, RLS-protected)
    const { data: profileData, error: profileError } = await supabase
      .from("user_profile")
      .select("entitlement")
      .eq("user_id", user.id)
      .maybeSingle();

    if (profileError) {
      console.error("Profile fetch error:", profileError);
      return new Response(
        JSON.stringify({ error: "server_error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const entitlement = (profileData?.entitlement as string) ?? "free";

    if (entitlement === "premium" || entitlement === "pro") {
      const response: CheckAccessResponse = {
        allowed: true,
        reason: "premium",
      };
      return new Response(JSON.stringify(response), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 6. Access denied: premium required
    const response: CheckAccessResponse = {
      allowed: false,
      reason: "premiumRequired",
    };
    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ error: "server_error", detail: String(error) }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});
