# Compression modes

Curtly has four engine modes. Choose per request with the `mode` body field on `/compress`, or with the `X-Curtly-Mode` header on either endpoint. The header takes precedence over the body.

## Engine modes

| Mode | `X-Curtly-Mode` header | Body `mode` | Behavior |
|---|---|---|---|
| Conservative | `fast` | `conservative` | Lowest risk. Deterministic only, AI-assisted step forced off. Lowest latency. |
| Balanced | `auto` (or omitted) | `balanced` | Default. Deterministic compression with Safe Vault protection. |
| Aggressive | `aggressive` | `aggressive` | Stronger pruning for maximum savings. Higher risk of dropping nuance. |
| Agent | `agent` (compress endpoint only) | `agent` | Tuned for coding-agent context: terminal noise, tool output, repeated file passes. |

Resolution order on `/compress`: `X-Curtly-Mode` header, then body `mode`, then your account default, then `balanced`.

The proxy endpoint accepts `fast`, `aggressive` or anything else (treated as balanced).

## AI-assisted compression

Separate from the mode, an optional AI-assisted step can distill prose further. It is **off unless enabled**:

- Header `X-Curtly-Compress-Input: true | false`.
- Per-key setting `enabled | disabled | neutral` in the dashboard. `disabled` always wins; `enabled` runs it unless the header says `false`; `neutral` requires the header to be `true`.
- `fast` mode always disables it.
- Very short non-system messages skip it automatically.

## Output brevity

Independent of input compression, the proxy injects an output directive. Control it with:

| Header | Values | Effect |
|---|---|---|
| `X-Curtly-Brevity` | `lite`, `full`, `ultra`, `off` | Strength of the brevity directive |
| `X-Curtly-Output-Efficiency` | `false` | Disables the directive entirely |

## Choosing a mode

| Situation | Suggested |
|---|---|
| Production prompts where correctness is critical | `conservative` / `fast` |
| General use, RAG, support transcripts | `balanced` |
| Cost-driven batch jobs where you can validate outputs | `aggressive` |
| Coding agents with long tool loops | `agent` |
