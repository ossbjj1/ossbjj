-- 20251027_seed_steps_26.sql
-- Purpose: Add 26 technique_step seed rows to reach ~120 total.
-- Safe & idempotent, no schema drift; matches current schema (no cues columns required).

create extension if not exists pgcrypto;

with slug_map(slug,title_en) as (values
  ('hip-bump-sweep','Hip Bump Sweep'),
  ('pendulum-sweep','Pendulum (Flower) Sweep'),
  ('stack-pass','Stack Pass (Double Under)'),
  ('knee-cut-pass','Knee Cut Pass'),
  ('bridge-and-roll-mount','Mount Escape – Trap and Roll'),
  ('side-to-mount','Side Control to Mount'),
  ('triangle-choke','Triangle Choke'),
  ('kimura-lock','Kimura Lock (Double Wristlock)'),
  ('rear-naked-choke','Rear Naked Choke (Mata Leão)'
)),
payload(data) as (
  values ('[
    {"technique_slug":"hip-bump-sweep","variant":"gi","idx":5,"title_en":"Secure the Mount","title_de":"Mount festigen"},
    {"technique_slug":"hip-bump-sweep","variant":"nogi","idx":5,"title_en":"Secure the Mount","title_de":"Mount festigen"},
    {"technique_slug":"pendulum-sweep","variant":"gi","idx":5,"title_en":"Come Up to Mount","title_de":"In den Mount gelangen"},
    {"technique_slug":"pendulum-sweep","variant":"nogi","idx":5,"title_en":"Come Up to Mount","title_de":"In den Mount gelangen"},
    {"technique_slug":"stack-pass","variant":"gi","idx":5,"title_en":"Pass to Side Control","title_de":"In Seitkontrolle gehen"},
    {"technique_slug":"stack-pass","variant":"nogi","idx":5,"title_en":"Pass to Side Control","title_de":"In Seitkontrolle gehen"},
    {"technique_slug":"knee-cut-pass","variant":"gi","idx":5,"title_en":"Establish Side Control","title_de":"Seitkontrolle etablieren"},
    {"technique_slug":"knee-cut-pass","variant":"nogi","idx":5,"title_en":"Establish Side Control","title_de":"Seitkontrolle etablieren"},
    {"technique_slug":"bridge-and-roll-mount","variant":"gi","idx":5,"title_en":"Finish on Top","title_de":"Oben landen"},
    {"technique_slug":"bridge-and-roll-mount","variant":"nogi","idx":5,"title_en":"Finish on Top","title_de":"Oben landen"},
    {"technique_slug":"side-to-mount","variant":"gi","idx":1,"title_en":"Knee on Belly","title_de":"Knie auf den Bauch"},
    {"technique_slug":"side-to-mount","variant":"gi","idx":2,"title_en":"Take the Mount","title_de":"Mount einnehmen"},
    {"technique_slug":"side-to-mount","variant":"nogi","idx":1,"title_en":"Knee on Belly","title_de":"Knie auf den Bauch"},
    {"technique_slug":"side-to-mount","variant":"nogi","idx":2,"title_en":"Take the Mount","title_de":"Mount einnehmen"},
    {"technique_slug":"triangle-choke","variant":"gi","idx":1,"title_en":"Shoot the Triangle","title_de":"Triangle ansetzen"},
    {"technique_slug":"triangle-choke","variant":"gi","idx":2,"title_en":"Lock and Squeeze","title_de":"Schließen und drücken"},
    {"technique_slug":"triangle-choke","variant":"nogi","idx":1,"title_en":"Shoot the Triangle","title_de":"Triangle ansetzen"},
    {"technique_slug":"triangle-choke","variant":"nogi","idx":2,"title_en":"Lock and Squeeze","title_de":"Schließen und drücken"},
    {"technique_slug":"kimura-lock","variant":"gi","idx":1,"title_en":"Control the Wrist","title_de":"Handgelenk greifen"},
    {"technique_slug":"kimura-lock","variant":"gi","idx":2,"title_en":"Figure-Four Grip","title_de":"Kimura abschließen"},
    {"technique_slug":"kimura-lock","variant":"nogi","idx":1,"title_en":"Control the Wrist","title_de":"Handgelenk greifen"},
    {"technique_slug":"kimura-lock","variant":"nogi","idx":2,"title_en":"Figure-Four Grip","title_de":"Kimura abschließen"},
    {"technique_slug":"rear-naked-choke","variant":"gi","idx":1,"title_en":"Arm Under the Chin","title_de":"Arm unter das Kinn"},
    {"technique_slug":"rear-naked-choke","variant":"gi","idx":2,"title_en":"Lock the Choke","title_de":"Würgegriff fixieren"},
    {"technique_slug":"rear-naked-choke","variant":"nogi","idx":1,"title_en":"Arm Under the Chin","title_de":"Arm unter das Kinn"},
    {"technique_slug":"rear-naked-choke","variant":"nogi","idx":2,"title_en":"Lock the Choke","title_de":"Würgegriff fixieren"}
  ]'::jsonb)
),
rows as (
  select m.title_en as technique_title_en,
         lower(r.variant) as variant,
         r.idx::int as idx,
         r.title_en,
         r.title_de
  from payload p,
       jsonb_to_recordset(p.data) as r(
         technique_slug text,
         variant text,
         idx int,
         title_en text,
         title_de text
       )
       join slug_map m on m.slug = r.technique_slug
)
insert into technique_step (id, technique_id, variant, idx, title_en, title_de, duration_s)
select gen_random_uuid(), t.id, rows.variant, rows.idx, rows.title_en, rows.title_de, 10
from rows
join technique t on lower(t.title_en) = lower(rows.technique_title_en)
on conflict (technique_id, variant, idx) do update
set title_en = excluded.title_en,
    title_de = excluded.title_de;
