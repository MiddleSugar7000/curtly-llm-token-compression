# `POST /api/v1/compress`

Compresses a prompt and returns the result with token statistics. You then send the compressed text to your LLM yourself.

## Request

```http
POST https://curtly.dev/api/v1/compress
Authorization: Bearer ctly_live_...
Content-Type: application/json
```

### Body

| Field | Type | Default | Description |
|---|---|---|---|
| `prompt` | string | required | Text to compress. Max **50,000** characters (`413` above that). |
| `mode` | string | `balanced` | `conservative`, `balanced`, `aggressive` or `agent`. See [modes](../compression-modes.md). |
| `model` | string | none | Target model id, used to pick the tokenizer and cost estimates. |
| `tokenizer` | string | from `model` | Force a tokenizer family. |
| `protectCodeBlocks` | boolean | `true` | Lock code fences and inline code. Alias: `protectCode`. |
| `protectVariables` | boolean | `true` | Lock template variables. |
| `protectJson` | boolean | `true` | Lock JSON payloads. |
| `enableAiDistillation` | boolean | `false` | Allow the AI-assisted step. Only effective when AI compression is on for the request or key. |

### Headers

| Header | Values | Effect |
|---|---|---|
| `X-Curtly-Mode` | `fast`, `auto`, `aggressive`, `agent` | Overrides body `mode` |
| `X-Curtly-Compress-Input` | `true`, `false` | Toggles the AI-assisted step |

## Response `200`

```json
{
  "success": true,
  "compressed": "Role: Customer support. Greet warmly. Never issue refunds above $50.",
  "cleanCompressed": "...",
  "brevityDirective": "...",
  "outputDirective": "...",
  "outputSavingsEstimate": {},
  "stats": {
    "mode": "balanced",
    "originalTokens": 31,
    "finalTokens": 16,
    "savedTokens": 15,
    "savedPercent": 48.4,
    "tokenizerUsed": "o200k_base",
    "latencyMs": 3,
    "stageBreakdown": {
      "deterministicSaved": 12,
      "densitySaved": 3,
      "protectedItemsCount": 1
    },
    "protectedItems": [],
    "integrityPassed": true,
    "aiCompression": "disabled",
    "estimatedSavingsPer10kCalls": {}
  }
}
```

The values above are illustrative. Field meanings:

| Field | Meaning |
|---|---|
| `compressed` | Compressed prompt, ready to send |
| `cleanCompressed` | Compressed prompt without internal markers |
| `brevityDirective` / `outputDirective` | Text you can append to your system prompt to get shorter answers |
| `stats.originalTokens` / `finalTokens` | Token counts before and after, in the reported tokenizer |
| `stats.integrityPassed` | `false` means a protected entity could not be verified; do not trust this output |
| `stats.estimatedSavingsPer10kCalls` | Cost estimate per model for 10,000 calls |

### Response headers

`X-Curtly-Engine-Mode`, `X-Curtly-Mode`, `X-Curtly-Ai-Compression`, `X-Curtly-Saved-Tokens`, `X-Curtly-Saved-Percent`, `X-Curtly-Integrity` (`passed` or `warning`), `X-Curtly-Latency-Ms`, `X-Curtly-Quota-Mode` (`standard` or `overage`), plus `X-RateLimit-*`.

## Errors

| Status | Body `code` | Cause |
|---|---|---|
| 400 | none | `prompt` missing or not a string |
| 401 | `UNAUTHORIZED_API_KEY_REQUIRED` or message only | Missing, invalid, revoked or expired key |
| 403 | none | Key lacks compression scope |
| 413 | none | Prompt over 50,000 characters |
| 429 | `QUOTA_EXCEEDED` / `RATE_LIMIT_EXCEEDED` | See [errors and limits](errors-and-limits.md) |
| 500 | none | Internal error |

## Example

```bash
curl -s https://curtly.dev/api/v1/compress \
  -H "Authorization: Bearer $CURTLY_API_KEY" \
  -H "X-Curtly-Mode: fast" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Please could you kindly summarize the following text ...","model":"gpt-4o"}'
```
