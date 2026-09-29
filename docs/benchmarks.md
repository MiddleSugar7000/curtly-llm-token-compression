# Benchmarks and methodology

These are results from Curtly's own benchmark harness, published here with their limitations. They are **not independent audits**. Compression results depend on your prompts, so measure on your own traffic.

**Common setup:** upstream model `cohere/north-mini-code:free` via OpenRouter, Curtly running locally (gateway timing excludes network to curtly.dev), September 2026. Token counts use several tokenizer families (see [models and tokenizers](models-and-tokenizers.md)).

## 1. Agent-style coding tasks (5 tasks)

Input reduction measured in characters, Balanced mode, comparing raw prompts with Curtly-processed prompts.

| Task | Char reduction | Gateway latency | Upstream latency, raw → Curtly |
|---|---|---|---|
| Next.js hydration error fix | 21.7% | 28.9 ms | 648 → 227 ms |
| FastAPI connection-pool leak | 25.6% | 12.3 ms | 283 → 253 ms |
| Rust borrow-checker conflict | 46.3% | 5.7 ms | 332 → 233 ms |
| Multi-turn agent tool schemas | 39.3% | 5.6 ms | 293 → 306 ms |
| OAuth2 PKCE middleware | 12.6% | 4.1 ms | 240 → 307 ms |

Across the five tasks, the code produced with compressed prompts kept valid syntax and passed the task's assertions. Upstream latency improved on three tasks and was slightly worse on two; single-run latencies on a free model are noisy and should not be read as a speedup claim.

## 2. Compression and output brevity across 6 workloads

Mixed workloads (coding, RAG, support, DevOps, JSON extraction, security audit), comparing a raw run with a Curtly run including the Output Brevity Governor.

| Metric | Result |
|---|---|
| Total tokens (prompt + completion), raw | 8,685 |
| Total tokens, with Curtly | 4,133 |
| Net reduction | **52.4%** |
| Completion-token reduction | **70.1%** |
| Prompt-token reduction | **about 0%** (net, in this run) |

Read this carefully: in this run nearly all of the savings came from **shorter answers**, not from shorter prompts. Some prompts were already dense, and adding the brevity directive offset small input savings. Per-workload prompt savings ranged from 0% to 43%.

Multi-tokenizer view of *prompt* reduction on the same workloads (deterministic engine only):

| Workload | o200k | Claude BPE |
|---|---|---|
| Rate limiter (code) | −49.6% | −49.3% |
| Raft consensus QA (RAG) | −85.7% | −85.7% |
| Billing SLA dispute (support) | −82.7% | −83.1% |
| Kubernetes OOM RCA (DevOps) | −90.7% | −90.4% |
| JSON extraction | −14.1% | −26.5% |
| Express security audit | −3.9% | −4.5% |

## 3. Live HTTP API run (5 workloads)

Measures the real `/compress` and `/chat/completions` endpoints over HTTP.

| Metric | Result |
|---|---|
| Character reduction | 9.6% – 22.5% |
| Engine overhead (`X-Curtly-Latency-Ms`) | 1.2 – 2.4 ms |
| `/compress` HTTP round trip | 12 – 44 ms |
| End-to-end proxy vs direct call | **slower** in this run |

In this run the end-to-end proxy path was slower than calling the free upstream model directly, because the direct baseline returned very short answers while the proxied runs generated longer ones. This is included deliberately: if your baseline is already fast and terse, a proxy hop will not make it faster.

## What these results do and do not show

- Prompt-heavy content with repetition (RAG chunks, support threads, boilerplate, terminal output) compresses well.
- Dense code and JSON compress little because they are protected on purpose.
- Output brevity can cut completion tokens sharply, which matters because completion tokens cost more per token.
- All runs use one small free model and small samples. Quality-equivalence judgments were made by Curtly's own harness.
- No claim here should be read as a guaranteed percentage for your workload.

## Reproduce it on your data

1. Take 50 to 100 real prompts from your logs.
2. Run each through `POST /api/v1/compress` and record `originalTokens`, `finalTokens` and `integrityPassed`.
3. Run raw and compressed prompts through your real model and compare answers with your own evaluation.
4. Compare total cost including completion tokens.
