# Security and privacy

This page describes how Curtly handles data and credentials. For the legal terms, see the [Privacy Policy](https://curtly.dev/privacy) and [Terms of Service](https://curtly.dev/terms), which take precedence over this summary.

## Data handling

- **Prompt content is processed in memory.** Compression runs per request. The usage log records operational metadata: token counts (before, after, saved), saved percentage, latency and, for overage, cost. It does not record the prompt or response text.
- **Not used for training.** Curtly does not use customer prompts or responses to train models.
- **Upstream providers.** On the proxy endpoint your (compressed) messages are sent to the provider you choose, under that provider's own data terms.

## Credentials

- **Curtly API keys** are stored as SHA-256 hashes. Plaintext is shown once at creation. Keys can be scoped, given an expiry and revoked.
- **Provider keys.** A provider key sent inline (`ctly_live_...:sk-...`) or via `X-Provider-Key` is used for that request and not persisted. Keys saved in the dashboard are stored encrypted.
- **Custom upstream URLs** are validated before use.

## Platform protections

- HTTPS in transit.
- Per-minute sliding-window rate limits and monthly quotas.
- Web application firewall rules and bot defenses in front of the API.
- Standard HTTP security headers.

## Recommendations for your side

- Keep Curtly and provider keys server-side; never embed them in client code.
- Use the narrowest scope and shortest expiry that works.
- Keep the integrity check in your pipeline and fall back to the original prompt on `warning` or on errors.
- Do not send secrets in prompts to any LLM service, Curtly included.

## Reporting a vulnerability

Email **support@curtly.dev** with details. Please do not open public issues for security reports.
