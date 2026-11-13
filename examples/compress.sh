#!/usr/bin/env bash
# Compress a prompt with Curtly. Requires CURTLY_API_KEY.
# Strict error handling: exit on nonzero return, unassigned variable, or piped failure
set -euo pipefail

# Execute prompt compression request with parameter expansion check for CURTLY_API_KEY
curl -sS https://curtly.dev/api/v1/compress \
  -H "Authorization: Bearer ${CURTLY_API_KEY:?set CURTLY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    # Prompt payload: uncompressed text, balanced optimization mode, and target model tokenizer profile
    "prompt": "You are a customer support agent. Please make sure that you always greet the customer warmly and never issue refunds above $50.",
    "mode": "balanced",
    "model": "gpt-4o"
  }'
