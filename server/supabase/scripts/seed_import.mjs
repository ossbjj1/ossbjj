#!/usr/bin/env node
/**
 * seed_import.mjs (Sprint 4 - Node.js version)
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
 *   node seed_import.mjs --dry-run
 *   node seed_import.mjs --apply
 */

import { createClient } from '@supabase/supabase-js';
import { createHash } from 'crypto';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// UUID v5 namespaces (project-specific)
const NAMESPACE_TECHNIQUE = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
const NAMESPACE_STEP = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';

function generateUUIDv5(namespace, name) {
  const namespaceBytes = Buffer.from(namespace.replace(/-/g, ''), 'hex');
  const nameBytes = Buffer.from(name, 'utf8');
  const combined = Buffer.concat([namespaceBytes, nameBytes]);

  const hash = createHash('sha1').update(combined).digest();

  // Set version (5) and variant bits
  hash[6] = (hash[6] & 0x0f) | 0x50;
  hash[8] = (hash[8] & 0x3f) | 0x80;

  const hex = hash.toString('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20, 32)}`;
}

async function main() {
  const args = process.argv.slice(2);
  const isDryRun = args.includes('--dry-run');
  const isApply = args.includes('--apply');

  if (!isDryRun && !isApply) {
    console.error('Error: Specify --dry-run or --apply');
    process.exit(1);
  }

  // Env validation
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE;
  if (!url || !key) {
    console.error('Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE required');
    process.exit(1);
  }

  const supabase = createClient(url, key);

  // Load seeds
  const seedsDir = join(__dirname, '../../../seeds');
  const techniquesRaw = readFileSync(join(seedsDir, 'techniques.json'), 'utf8');
  const stepsRaw = readFileSync(join(seedsDir, 'steps.json'), 'utf8');
  const techniques = JSON.parse(techniquesRaw);
  const steps = JSON.parse(stepsRaw);

  console.log(`📦 Loaded ${techniques.length} techniques, ${steps.length} steps`);

  // Validation
  const slugSet = new Set(techniques.map((t) => t.slug));
  const errors = [];

  if (techniques.length !== 20) {
    errors.push(`Expected 20 techniques, got ${techniques.length}`);
  }

  if (steps.length < 80 || steps.length > 120) {
    errors.push(`Expected 80-120 steps, got ${steps.length}`);
  }

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
    errors.push('Duplicate (technique_slug, variant, idx) detected');
  }

  if (errors.length > 0) {
    console.error('❌ Validation failed:');
    errors.forEach((e) => console.error(`  - ${e}`));
    process.exit(1);
  }

  console.log('✅ Validation passed');

  // Generate UUIDs
  const techniqueRows = techniques.map((t) => ({
    id: generateUUIDv5(NAMESPACE_TECHNIQUE, t.slug),
    category: t.category,
    title_en: t.title_en,
    title_de: t.title_de,
    display_order: t.display_order,
  }));

  const slugToId = new Map(
    techniques.map((t, i) => [t.slug, techniqueRows[i].id])
  );

  const stepRows = steps.map((s) => {
    const techniqueId = slugToId.get(s.technique_slug);
    const stepKey = `${s.technique_slug}:${s.variant}:${s.idx}`;
    return {
      id: generateUUIDv5(NAMESPACE_STEP, stepKey),
      technique_id: techniqueId,
      variant: s.variant,
      idx: s.idx,
      title_en: s.title_en,
      title_de: s.title_de,
      duration_s: 10,
    };
  });

  if (isDryRun) {
    console.log('\n🔍 Dry-run preview:');
    console.log(`  Techniques: ${techniqueRows.length} rows`);
    console.log(`  Steps: ${stepRows.length} rows`);
    console.log('\nSample technique:', techniqueRows[0]);
    console.log('Sample step:', stepRows[0]);
    console.log('\n✅ Dry-run complete. Use --apply to execute.');
    return;
  }

  // Apply
  console.log('\n⚙️  Upserting techniques...');
  for (const row of techniqueRows) {
    const { error } = await supabase.from('technique').upsert(row, {
      onConflict: 'id',
    });
    if (error) {
      console.error(`❌ Technique upsert failed (${row.id}):`, error.message);
      process.exit(1);
    }
  }

  console.log('⚙️  Upserting steps...');
  for (const row of stepRows) {
    const { error } = await supabase.from('technique_step').upsert(row, {
      onConflict: 'id',
    });
    if (error) {
      console.error(`❌ Step upsert failed (${row.id}):`, error.message);
      process.exit(1);
    }
  }

  console.log('\n✅ Import complete!');
  console.log(`  Techniques: ${techniqueRows.length}`);
  console.log(`  Steps: ${stepRows.length}`);
}

main().catch((err) => {
  console.error('❌ Fatal error:', err);
  process.exit(1);
});
