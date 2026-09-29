# Authentication

Base URL: `https://curtly.dev/api/v1`

## API keys

Create keys in the [Curtly dashboard](https://curtly.dev/dashboard). Keys start with `ctly_live_`. The plaintext key is shown once at creation; Curtly stores only a SHA-256 hash.

Send the key in either header:

```http
Authorization: Bearer ctly_live_xxxxxxxx
```

```http
X-Curtly-Key: ctly_live_xxxxxxxx
```

## Scopes and expiry

| Scope | Allows |
|---|---|
| `full` | Compression and proxy (default when no scope is set) |
| `compress_only` | Compression and proxy |
| Read-only metrics | Dashboard metrics only; requests to the API return `403` |

Keys can carry an expiry (for example 30 days, 90 days or 1 year). Expired or revoked keys return `401`.

Each key also has an AI-compression setting (`enabled`, `disabled`, `neutral`), described in [compression modes](../compression-modes.md#ai-assisted-compression).

## Upstream provider key (proxy endpoint)

`POST /chat/completions` forwards to *your* LLM provider, so Curtly needs that provider's key. Options:

1. **Saved in the dashboard** under Settings > Providers.
2. **Inline in the bearer value**, separated by a colon: `Authorization: Bearer ctly_live_xxx:sk-or-yyy`.
3. **Per request header**: `X-Provider-Key: sk-...`.

Providers: `openrouter`, `openai`, `anthropic`, `groq`, or `custom` with `X-Provider-Base-Url`. Select with `X-Provider: <id>`; otherwise Curtly infers it from the key prefix (`sk-or-` OpenRouter, `sk-ant-` Anthropic, `gsk_` Groq, otherwise OpenAI). A key sent inline or per request is used for that call and is not persisted.

## Browser and same-origin use

Requests from the Curtly web app itself authenticate by session. Everything else (cURL, SDKs, other origins) must send an API key; otherwise `/compress` returns `401` with code `UNAUTHORIZED_API_KEY_REQUIRED`.

## CORS

Both endpoints answer `OPTIONS` and allow cross-origin requests. Never ship a Curtly key in public browser code; call the API from your server.
