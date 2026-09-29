# Safe Vault

The Safe Vault is the part of Curtly that keeps compression from damaging things that must stay exact.

## The problem

Naive prompt compressors (regex-based filler removal, stop-word deletion, embedding-based summarizers) treat everything as prose. That can silently change a variable name, drop a JSON key, collapse indentation in Python, or rewrite a URL. The model then answers a subtly different question.

## The approach

Before any compression runs, Curtly extracts protected entities and replaces each with a unique placeholder. Compression only ever sees placeholders and prose. Afterwards the originals are restored unchanged.

Protected by default:

| Entity | Examples |
|---|---|
| Markdown code fences | ` ```python ... ``` ` |
| Inline code | `` `getUserById` ``, `` `src/app.ts` `` |
| JSON payloads | keys, booleans, numbers, nested objects |
| SQL statements | `SELECT`, `INSERT`, `UPDATE`, schema definitions |
| Resource identifiers | URLs, IP addresses, file paths |
| Template variables | `{{user_name}}`, `${token}` |

## Controls

On [`POST /api/v1/compress`](api-reference/compress.md) you can toggle protection per request:

| Field | Default | Effect |
|---|---|---|
| `protectCodeBlocks` | `true` | Lock code fences and inline code |
| `protectJson` | `true` | Lock JSON payloads |
| `protectVariables` | `true` | Lock template variables |

Account-level defaults can also be set in the dashboard.

## Verification

Every response carries an integrity result: `stats.integrityPassed` in the body and `X-Curtly-Integrity: passed | warning` in the headers. A `warning` means at least one protected entity could not be confirmed in the output, and you should treat that response as untrusted and fall back to your original prompt.

## Code-aware pruning

For prompts that contain source code, Curtly can also remove content that carries no meaning for a model, such as license headers and decorative divider comments, while preserving docstrings, type annotations and logic. In Curtly's live benchmark, a heavily commented TypeScript sample compressed by about half in Balanced mode ([details](benchmarks.md)).

## Honest limits

- The vault protects *what it recognizes*. Unusual embedded formats may be treated as prose.
- Protecting more (the default) means less compression on code- and JSON-heavy inputs. That is the intended trade-off.
- Always keep the integrity check in your pipeline for high-stakes prompts.
