# Frequently asked questions

## What is Curtly?
Curtly is a hosted LLM prompt compression API and OpenAI-compatible proxy. It reduces the tokens you send to a model (input compression) and the tokens the model returns (output brevity directive), which lowers API cost and can reduce latency.

## Is Curtly open source?
No. This repository contains documentation only. Curtly is a proprietary hosted service at [curtly.dev](https://curtly.dev).

## How do I reduce OpenAI or Claude API costs with Curtly?
Either call [`POST /api/v1/compress`](api-reference/compress.md) and send the compressed prompt to your model, or set your SDK's base URL to `https://curtly.dev/api/v1` and use the [proxy](api-reference/chat-completions.md). Output brevity applies on the proxy.

## How much will I save?
It depends on the prompt. Repetitive prose, RAG chunks, support threads and terminal output can shrink dramatically; dense code and JSON shrink little because they are protected. See the [benchmarks](benchmarks.md), which include cases with no input savings.

## Will it break my code, JSON or SQL?
Code, JSON, SQL, URLs, paths and template variables are locked in the [Safe Vault](safe-vault.md) before compression and restored afterwards. Every response reports an integrity result. Use it.

## Does it change the meaning of my prompt?
Conservative and Balanced modes aim to remove redundancy, not facts. Aggressive mode trades more risk for more savings. Validate on your own data before using Aggressive in production. See [compression modes](compression-modes.md).

## Does it work with prompt caching?
Live runs kept system prompts stable across turns so provider prefix caching continued to apply. Confirm cache-hit metrics with your own provider.

## What latency does it add?
The engine overhead reported in benchmarks was a few milliseconds in deterministic modes. Network time to the hosted API is additional. The optional AI-assisted step adds more. See [benchmarks](benchmarks.md).

## Which providers does the proxy support?
OpenRouter, OpenAI, Anthropic, Groq, and any OpenAI-compatible endpoint via a custom base URL. You bring your own provider key. See [authentication](api-reference/authentication.md).

## Does it support streaming?
Yes, on the proxy endpoint.

## Which tokenizers are supported?
OpenAI `o200k_base` and `cl100k_base`, Claude BPE, DeepSeek/Llama 128k, Gemini SentencePiece, Qwen, GLM and Mistral families. See [models and tokenizers](models-and-tokenizers.md).

## Does Curtly store or train on my prompts?
Usage logs store token counts and latency, not prompt text, and Curtly does not train on customer data. See [security and privacy](security-and-privacy.md).

## What is the maximum prompt size?
`/compress` accepts up to 50,000 characters per request.

## Is there a free plan?
Yes, with a monthly request quota. See [curtly.dev/#pricing](https://curtly.dev/#pricing) for current plans and limits.

## What should I do if compression fails?
Send your original prompt. Treat Curtly as an optimization layer, never a hard dependency. See [errors and limits](api-reference/errors-and-limits.md).
