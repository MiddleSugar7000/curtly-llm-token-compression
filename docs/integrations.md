# Integrations

Curtly exposes two integration points: the [compression endpoint](api-reference/compress.md) and an [OpenAI-compatible proxy](api-reference/chat-completions.md). Any client that lets you change the base URL can use the proxy.

Set your key once:

```bash
export CURTLY_API_KEY="ctly_live_..."
```

## Python (OpenAI SDK)

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://curtly.dev/api/v1",
    api_key=os.environ["CURTLY_API_KEY"],
)

resp = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a code analysis assistant."},
        {"role": "user", "content": "Analyze the database schema for missing indexes."},
    ],
    extra_headers={
        "X-Provider": "openai",
        "X-Provider-Key": os.environ["OPENAI_API_KEY"],
        "X-Curtly-Mode": "auto",
    },
)
print(resp.choices[0].message.content)
```

## Node.js / TypeScript (OpenAI SDK)

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://curtly.dev/api/v1",
  apiKey: process.env.CURTLY_API_KEY,
  defaultHeaders: {
    "X-Provider": "openrouter",
    "X-Provider-Key": process.env.OPENROUTER_API_KEY!,
  },
});

const res = await client.chat.completions.create({
  model: "deepseek/deepseek-chat",
  messages: [{ role: "user", content: "Generate an optimized SQL query." }],
});
console.log(res.choices[0].message.content);
```

If you saved your provider key in the Curtly dashboard, omit the `X-Provider*` headers.

## Compression only (any language)

Call `/compress`, then send `compressed` to any model yourself:

```python
import os, requests

r = requests.post(
    "https://curtly.dev/api/v1/compress",
    headers={"Authorization": f"Bearer {os.environ['CURTLY_API_KEY']}"},
    json={"prompt": long_prompt, "mode": "balanced", "model": "gpt-4o"},
    timeout=10,
)
data = r.json()
prompt = data["compressed"] if r.ok and data["stats"]["integrityPassed"] else long_prompt
```

## LangChain

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="https://curtly.dev/api/v1",
    api_key=os.environ["CURTLY_API_KEY"],
    model="gpt-4o",
    default_headers={"X-Provider": "openai", "X-Provider-Key": os.environ["OPENAI_API_KEY"]},
)
```

## Coding agents and other OpenAI-compatible tools

Tools that accept a custom OpenAI-compatible provider (base URL plus API key) can point at `https://curtly.dev/api/v1`. Use the `agent` mode via `/compress`, or `X-Curtly-Mode` headers on the proxy, to strip terminal noise from long tool loops. Check your tool's documentation for where to set custom headers.

## cURL

See the examples in the [compress](api-reference/compress.md#example) and [chat completions](api-reference/chat-completions.md#example) references.

Runnable copies live in [`examples/`](../examples).
