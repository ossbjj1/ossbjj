#!/usr/bin/env bash
set -euo pipefail

# Convenience launcher for iOS Simulator with Supabase config.
# Usage:
#   scripts/run_ios_dev.sh [SIMULATOR_UDID]
# If UDID omitted, uses the currently configured iPhone 16e UDID.

DEVICE_ID=${1:-"5CB3D663-3763-403E-AE15-A9DE071AC92D"}

# Resolve Supabase URL/Key from env or macOS Keychain
URL=${SUPABASE_URL:-$(security find-generic-password -a oss -s oss_supa_url -w 2>/dev/null || true)}
ANON=${SUPABASE_ANON_KEY:-$(security find-generic-password -a oss -s oss_supa_anon -w 2>/dev/null || true)}

if [[ -z "${URL}" ]]; then
  echo "Missing SUPABASE_URL. Set env var or store in Keychain:" >&2
  echo "  security add-generic-password -a oss -s oss_supa_url -w https://YOUR-REF.supabase.co -U" >&2
  exit 1
fi

if [[ -z "${ANON}" ]]; then
  echo "Missing SUPABASE_ANON_KEY. Set env var or store in Keychain:" >&2
  echo "  security add-generic-password -a oss -s oss_supa_anon -w YOUR_ANON_PUBLIC_KEY -U" >&2
  exit 1
fi

# Start Simulator (no-op if already running)
open -a Simulator >/dev/null 2>&1 || true

# Run Flutter with dart-defines
cd "$(dirname "$0")/../app"
flutter run -d "${DEVICE_ID}" \
  --dart-define=SUPABASE_URL="${URL}" \
  --dart-define=SUPABASE_ANON_KEY="${ANON}" "$@"
