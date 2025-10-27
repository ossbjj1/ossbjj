#!/usr/bin/env -S deno run -A
/**
 * seed_import.ts (Sprint 4)
 * 
 * Imports techniques and steps from seeds/ into Supabase with:
 * - Deterministic UUID v5 (stable IDs)
 * - Idempotent upserts (ON CONFLICT DO UPDATE)
 * - Validation (ref integrity, counts, duplicates)
 * - Flags: --dry-run (preview), --apply (execute)
 * 
 * Usage:
 *   export SUPABASE_URL=https://...
 *   export SUPABASE_SERVICE_ROLE=eyJ...
 *   deno run -A seed_import.ts --dry-run
 *   deno run -A seed_import.ts --apply
 */

import { createClient } from "npm:@supabase/supabase-js@2";

// UUID v5 namespace (random, stable for this project)
const NAMESPACE_TECHNIQUE = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
const NAMESPACE_STEP = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";

type Technique = {
  slug: string;
  category: string;
  title_en: string;
  title_de: string;
  skill_level: string;
  display_order: number;
};

type Step = {
  technique_slug: string;
  idx: number;
  variant: "gi" | "nogi";
  title_en: string;
  title_de: string;
  cues_en: string;
  cues_de: string;
};

async function generateUUID(namespace: string, name: string): Promise<string> {
  const namespaceBytes = new Uint8Array(
    namespace.split("-").join("").match(/.{2}/g)!.map((h) => parseInt(h, 16))
  );
  const nameBytes = new TextEncoder().encode(name);
  const combined = new Uint8Array(namespaceBytes.length + nameBytes.length);
  combined.set(namespaceBytes);
  combined.set(nameBytes, namespaceBytes.length);

  const hashBuffer = await crypto.subtle.digest("SHA-1", combined);
  const hashArray = Array.from(new Uint8Array(hashBuffer));

  // Set version (5) and variant bits
  hashArray[6] = (hashArray[6] & 0x0f) | 0x50;
  hashArray[8] = (hashArray[8] & 0x3f) | 0x80;

  const hex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${
    hex.slice(16, 20)
  }-${hex.slice(20, 32)}`;
}

async function main() {
  const args = Deno.args;
  const isDryRun = args.includes("--dry-run");
  const isApply = args.includes("--apply");

  if (!isDryRun && !isApply) {
    console.error("Error: Specify --dry-run or --apply");
    Deno.exit(1);
  }

  // Env validation
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE");
  if (!url || !key) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE required");
    Deno.exit(1);
  }

  const supabase = createClient(url, key);

  // Load seeds
  const techniquesRaw = await Deno.readTextFile("seeds/techniques.json");
  const stepsRaw = await Deno.readTextFile("seeds/steps.json");
  const techniques: Technique[] = JSON.parse(techniquesRaw);
  const steps: Step[] = JSON.parse(stepsRaw);

  console.log(`📦 Loaded ${techniques.length} techniques, ${steps.length} steps`);

  // Validation
  const slugSet = new Set(techniques.map((t) => t.slug));
  const errors: string[] = [];

  if (techniques.length !== 20) {
    errors.push(`Expected 20 techniques, got ${techniques.length}`);
  }

  if (steps.length < 80 || steps.length > 120) {
    errors.push(`Expected 80-120 steps, got ${steps.length}`);
  }
  // Note: 94 steps (20 techniques × 4–5 steps/variant) meets MVP; expand to ≥100 in future sprints

  for (const step of steps) {
    if (!slugSet.has(step.technique_slug)) {
      errors.push(`Step references unknown technique: ${step.technique_slug}`);
    }
  }

  const stepKeys = steps.map((s) =>
    `${s.technique_slug}:${s.variant}:${s.idx}`
  );
  const stepKeySet = new Set(stepKeys);
  if (stepKeys.length !== stepKeySet.size) {
    errors.push("Duplicate (technique_slug, variant, idx) detected");
  }

  if (errors.length > 0) {
    console.error("❌ Validation failed:");
    errors.forEach((e) => console.error(`  - ${e}`));
    Deno.exit(1);
  }

  console.log("✅ Validation passed");

  // Generate UUIDs
  const techniqueRows = await Promise.all(
    techniques.map(async (t) => ({
      id: await generateUUID(NAMESPACE_TECHNIQUE, t.slug),
      category: t.category,
      title_en: t.title_en,
      title_de: t.title_de,
      display_order: t.display_order,
    }))
  );

  const slugToId = new Map(
    techniques.map((t, i) => [t.slug, techniqueRows[i].id])
  );

  const stepRows = await Promise.all(
    steps.map(async (s) => {
      const techniqueId = slugToId.get(s.technique_slug)!;
      const stepKey = `${s.technique_slug}:${s.variant}:${s.idx}`;
      return {
        id: await generateUUID(NAMESPACE_STEP, stepKey),
        technique_id: techniqueId,
        variant: s.variant,
        idx: s.idx,
        title_en: s.title_en,
        title_de: s.title_de,
        duration_s: 10,
      };
    })
  );

  if (isDryRun) {
    console.log("\n🔍 Dry-run preview:");
    console.log(`  Techniques: ${techniqueRows.length} rows`);
    console.log(`  Steps: ${stepRows.length} rows`);
    console.log("\nSample technique:", techniqueRows[0]);
    console.log("Sample step:", stepRows[0]);
    console.log("\n✅ Dry-run complete. Use --apply to execute.");
    return;
  }

  // Apply
  console.log("\n⚙️  Upserting techniques...");
  for (const row of techniqueRows) {
    const { error } = await supabase.from("technique").upsert(row, {
      onConflict: "id",
    });
    if (error) {
      console.error(`❌ Technique upsert failed (${row.id}):`, error.message);
      Deno.exit(1);
    }
  }

  console.log("⚙️  Upserting steps...");
  for (const row of stepRows) {
    const { error } = await supabase.from("technique_step").upsert(row, {
      onConflict: "id",
    });
    if (error) {
      console.error(`❌ Step upsert failed (${row.id}):`, error.message);
      Deno.exit(1);
    }
  }

  console.log("\n✅ Import complete!");
  console.log(`  Techniques: ${techniqueRows.length}`);
  console.log(`  Steps: ${stepRows.length}`);
}

main();
