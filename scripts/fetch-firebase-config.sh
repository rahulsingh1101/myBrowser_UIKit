#!/usr/bin/env bash
# Fetches GoogleService-Info.plist from Firebase directly instead of
# committing it to git. Requires Firebase project access (ask an existing
# project member to add you in Firebase console > Project Settings > Users
# and permissions).
set -euo pipefail

PROJECT_ID="my-browser-2e77f"
APP_ID="1:783431569735:ios:368c41b49c8355f5c17c62"
OUTPUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/myBrowser_UIKit/GoogleService-Info.plist"

if ! command -v firebase &> /dev/null; then
  echo "Firebase CLI not found. Install it with:"
  echo "  npm install -g firebase-tools"
  exit 1
fi

if ! firebase login:list --json 2>/dev/null | grep -q '"user"'; then
  echo "Not logged in to Firebase. Opening login..."
  firebase login
fi

echo "Fetching GoogleService-Info.plist for $PROJECT_ID..."
firebase apps:sdkconfig IOS "$APP_ID" -P "$PROJECT_ID" -o "$OUTPUT"

echo "Done: $OUTPUT"
