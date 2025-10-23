// server/supabase/functions/gating_step_complete/index.ts
// Server-side Step-Gating + Achievement-Granting (MVP)
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Json = Record<string, unknown>;
function resp(body: Json, status: number) {
  return new Response(JSON.stringify(body), { headers: { "content-type": "application/json" }, status });
}

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const authHeader = req.headers.get("Authorization") || "";

    const authed = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
    const svc = createClient(supabaseUrl, serviceKey);

    const { technique_step_id } = await req.json();
    if (!technique_step_id) return resp({ error: "bad_request" }, 400);

    // 1) Auth
    const { data: auth } = await authed.auth.getUser();
    const user = auth?.user;
    if (!user) return resp({ error: "unauth" }, 401);

    // 2) Step exists?
    const { data: step, error: stepErr } = await authed
      .from("technique_step")
      .select("id, technique_id, variant, idx")
      .eq("id", technique_step_id).single();
    if (stepErr || !step) return resp({ error: "not_found" }, 404);

    // 3) Prereq (idx-1 same variant)?
    if (step.idx > 1) {
      const { data: prereq } = await authed
        .from("technique_step")
        .select("id")
        .eq("technique_id", step.technique_id)
        .eq("variant", step.variant)
        .eq("idx", step.idx - 1).maybeSingle();
      const prereqId = prereq?.id;
      if (!prereqId) return resp({ error: "prereq_missing" }, 423);

      const { count } = await authed
        .from("user_step_progress")
        .select("technique_step_id", { head: true, count: "exact" })
        .eq("user_id", user.id)
        .eq("technique_step_id", prereqId);
      if (!count) return resp({ error: "prereq_missing" }, 423);
    }

    // 4) Freemium (idx<=2) or Premium?
    if (step.idx > 2) {
      const { data: prof } = await authed
        .from("user_profile").select("entitlement").eq("user_id", user.id).single();
      if (!prof || prof.entitlement !== "pro") return resp({ error: "paywall_locked" }, 403);
    }

    // 5) Idempotent Write
    const { error: upErr } = await authed
      .from("user_step_progress")
      .upsert({ user_id: user.id, technique_step_id, completed_at: new Date().toISOString() });
    if (upErr) return resp({ error: "conflict" }, 409);

    // 6) ACHIEVEMENTS (MVP-light): first_grip, streak_7, steps_25, tech_5
    const { data: stepsCountRow } = await svc
      .from("user_step_progress")
      .select("technique_step_id", { count: "exact", head: true })
      .eq("user_id", user.id);
    const stepsCompleted = (stepsCountRow as unknown as { count: number } | null)?.count ?? 0;

    const { data: streakDays } = await svc.rpc("calc_streak_days", { p_user_id: user.id });
    const streak = Number(streakDays ?? 0);

    const { data: techCompleted } = await svc.rpc("count_completed_techniques", { p_user_id: user.id });
    const tech5 = Number(techCompleted ?? 0) >= 5;

    const { data: existing } = await svc
      .from("user_achievement")
      .select("achievement_id")
      .eq("user_id", user.id);
    const have = new Set<number>((existing ?? []).map(r => r.achievement_id));

    const { data: catalog } = await svc
      .from("achievement")
      .select("id,key");
    const idByKey = new Map<string, number>((catalog ?? []).map(a => [a.key as string, a.id as number]));

    const toUnlock: number[] = [];
    if (stepsCompleted >= 1) {
      const id = idByKey.get("first_grip"); if (id && !have.has(id)) toUnlock.push(id);
    }
    if (streak >= 7) {
      const id = idByKey.get("streak_7"); if (id && !have.has(id)) toUnlock.push(id);
    }
    if (stepsCompleted >= 25) {
      const id = idByKey.get("steps_25"); if (id && !have.has(id)) toUnlock.push(id);
    }
    if (tech5) {
      const id = idByKey.get("tech_5"); if (id && !have.has(id)) toUnlock.push(id);
    }

    if (toUnlock.length) {
      const rows = toUnlock.map(achievement_id => ({ user_id: user.id, achievement_id }));
      await svc.from("user_achievement").upsert(rows);
    }

    return resp({ state: "completed", unlocked: toUnlock.length }, 200);
  } catch (e) {
    return resp({ error: "server_error", detail: String(e) }, 500);
  }
});
