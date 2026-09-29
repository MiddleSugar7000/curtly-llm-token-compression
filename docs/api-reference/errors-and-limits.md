# Errors, quotas and rate limits

## Rate limits

A sliding-window per-minute limit is applied per API key (or per user or IP when unauthenticated), with higher limits on higher plans. Responses include:

| Header | Meaning |
|---|---|
| `X-RateLimit-Limit` | Requests allowed in the window |
| `X-RateLimit-Remaining` | Requests left |
| `X-RateLimit-Reset` | Seconds until the window resets |
| `Retry-After` | Seconds to wait (on `429`) |

On `429` the body has `code: "RATE_LIMIT_EXCEEDED"` (compress) or `rate_limit_exceeded` (proxy). Back off and retry after `Retry-After`.

## Monthly quota

Each plan includes a monthly request quota (the Free plan includes 500 requests per month). See [curtly.dev/#pricing](https://curtly.dev/#pricing) for current plans.

When the quota is used up, requests continue only if you have a **prepaid balance**, which is deducted per extra request. Otherwise the API returns `429` with `QUOTA_EXCEEDED` / `quota_exceeded`, including `limit`, `used` and `prepaidBalance`. Responses served from overage carry `X-Curtly-Quota-Mode: overage`.

## Handling failures safely

- On any non-2xx response from `/compress`, send your **original prompt** to the model instead. Compression is an optimization, never a hard dependency.
- If `X-Curtly-Integrity` is `warning`, treat the compressed text as untrusted and use the original.
- Retry `429` and `5xx` with exponential backoff and jitter.
