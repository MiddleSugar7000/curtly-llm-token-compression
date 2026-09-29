# `POST /api/v1/chat/completions`

OpenAI-compatible chat-completions proxy. Curtly compresses your `messages`, forwards them to your upstream provider, and returns the provider's response (including streaming).

## Request

```http
POST https://curtly.dev/api/v1/chat/completions
Authorization: Bearer ctly_live_...
Content-Type: application/json
```

Body follows the OpenAI chat-completions schema. Fields used by Curtly:

| Field | Description |
|---|---|
| `messages` | Required non-empty array. String `content` longer than 10 characters is compressed; other content is passed through. |
| `model` | Upstream model id. If omitted, your dashboard default model is used. If none is set, the call fails with `model_missing`. |
| `stream` | `true` streams server-sent events from the upstream. |
| other fields | Forwarded to the upstream unchanged. |

### Curtly headers

| Header | Values | Effect |
|---|---|---|
| `X-Curtly-Mode` | `fast`, `aggressive`, otherwise balanced | Compression mode. See [modes](../compression-modes.md). |
| `X-Curtly-Compress-Input` | `true`, `false` | AI-assisted step (subject to the key setting) |
| `X-Curtly-Brevity` | `lite`, `full`, `ultra`, `off` | Output brevity strength |
| `X-Curtly-Output-Efficiency` | `false` | Disable the output directive |
| `X-Provider` | `openrouter`, `openai`, `anthropic`, `groq`, `custom` | Upstream provider |
| `X-Provider-Key` | provider key | Upstream credential for this request |
| `X-Provider-Base-Url` | URL | Upstream base URL for `custom` |

See [authentication](authentication.md#upstream-provider-key-proxy-endpoint) for how the upstream key is resolved.

## Processing per message

1. Agent-noise cleaning (ANSI codes, progress bars, tool-output bloat).
2. Adaptive routing: short non-system messages (under about 150 characters) skip the AI-assisted step.
3. Safe Vault protection and compression.
4. Cached results are reused for identical inputs.
5. The Output Brevity Governor directive is injected.

## Response

The upstream provider's response body, unchanged in shape. For streaming, standard `text/event-stream` chunks.

## Errors

Errors use the OpenAI shape: `{ "error": { "message", "type", "code" } }`.

| Status | `code` | Cause |
|---|---|---|
| 400 | none | Invalid JSON or missing `messages` |
| 400 | `model_missing` | No model in request and no default configured |
| 400 | provider resolution codes | No upstream key or unusable base URL |
| 401 | `invalid_api_key`, `expired_api_key`, `unauthorized` | Bad, expired or missing Curtly key |
| 403 | `insufficient_scope`, `account_suspended` | Scope or account problem |
| 429 | `quota_exceeded`, `rate_limit_exceeded` | See [errors and limits](errors-and-limits.md) |
| 5xx | `upstream_unreachable`, `upstream_error` | Provider problem |

Provider resolution happens **before** quota is consumed, so a missing provider key never costs a request.

## Example

```bash
curl https://curtly.dev/api/v1/chat/completions \
  -H "Authorization: Bearer $CURTLY_API_KEY" \
  -H "X-Provider: openrouter" \
  -H "X-Provider-Key: $OPENROUTER_API_KEY" \
  -H "X-Curtly-Mode: auto" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek/deepseek-chat","messages":[{"role":"user","content":"Summarize: ..."}]}'
```
