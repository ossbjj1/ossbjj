#!/usr/bin/env bash
set -euo pipefail

# Run OSS Flutter app on iOS Simulator with hot reload, loading env from .env
# Usage: scripts/dev/ios.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
APP_DIR="$ROOT_DIR/app"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -d "$APP_DIR" ]]; then
  echo "App directory not found: $APP_DIR" >&2
  exit 1
fi

# Load environment if present
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a; source "$ENV_FILE"; set +a
else
  echo "WARN: .env not found at $ENV_FILE" >&2
  echo "Create it from .env.sample and set SUPABASE_URL and SUPABASE_ANON_KEY." >&2
fi

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "ERROR: SUPABASE_URL or SUPABASE_ANON_KEY missing. Aborting." >&2
  exit 1
fi

# Ensure Simulator is running
open -a Simulator || true
sleep 1

cd "$APP_DIR"

# Start Flutter in debug (hot reload enabled). Keep in foreground for 'r' hot reload.
flutter run \
  --debug \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
