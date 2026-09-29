#!/usr/bin/env bash
# Compress a prompt with Curtly. Requires CURTLY_API_KEY.
set -euo pipefail

curl -sS https://curtly.dev/api/v1/compress \
  -H "Authorization: Bearer ${CURTLY_API_KEY:?set CURTLY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "You are a customer support agent. Please make sure that you always greet the customer warmly and never issue refunds above $50.",
    "mode": "balanced",
    "model": "gpt-4o"
  }'
