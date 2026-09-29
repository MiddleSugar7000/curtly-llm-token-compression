# Models and tokenizers

Different model families split text into tokens differently, so the same prompt has a different token count, and therefore a different cost, per family. Curtly counts tokens with the family that matches your target model and reports it as `stats.tokenizerUsed`.

## Tokenizer families

| Family | Approx. vocabulary | Typical models | Notes |
|---|---|---|---|
| OpenAI `o200k_base` | ~200k | GPT-4o and newer GPT families | Efficient on code and multilingual text |
| Legacy `cl100k_base` | ~100k | GPT-4, GPT-3.5 | Legacy counting |
| Claude BPE | ~65k | Anthropic Claude models | Smaller vocabulary; structured code and JSON tend to use more tokens |
| DeepSeek / Llama 128k BPE | ~100k – 128k | DeepSeek, Llama 3.x | Byte-level BPE |
| Google SentencePiece | ~256k | Gemini models | Large vocabulary |
| Qwen BPE | ~152k | Qwen models | Bilingual and code-oriented |
| GLM BPE | ~152k | Zhipu GLM models | |
| Mistral Tekken | ~131k | Mistral models | |

Vocabulary sizes are approximate. Token counts for non-OpenAI families are estimates produced by Curtly's tokenizer layer, not the vendor's official counters, so use provider usage data for billing reconciliation.

## Why output tokens matter

Most providers price completion tokens at roughly 3x to 6x the price of prompt tokens. That is why Curtly has an [Output Brevity Governor](compression-modes.md#output-brevity) in addition to input compression: trimming a verbose answer can save more money than trimming the prompt.

## Choosing the tokenizer

- Pass `model` on `/compress` and Curtly selects the family.
- Or pass `tokenizer` explicitly to override.

See the [`/compress` reference](api-reference/compress.md).
