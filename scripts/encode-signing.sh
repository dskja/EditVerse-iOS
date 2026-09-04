#!/usr/bin/env bash
# Encode local Apple signing files for GitHub Actions secrets.
# Usage:
#   ./scripts/encode-signing.sh path/to/certificate.p12 path/to/profile.mobileprovision
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <certificate.p12> <profile.mobileprovision>"
  exit 1
fi

CERT="$1"
PROFILE="$2"

echo "=== BUILD_CERTIFICATE_BASE64 ==="
base64 < "$CERT" | tr -d '\n'
echo
echo
echo "=== BUILD_PROVISION_PROFILE_BASE64 ==="
base64 < "$PROFILE" | tr -d '\n'
echo
echo
echo "Also set secrets: P12_PASSWORD, KEYCHAIN_PASSWORD, APPLE_TEAM_ID"
echo "Optional: EXPORT_METHOD (ad-hoc | development | app-store | enterprise)"
