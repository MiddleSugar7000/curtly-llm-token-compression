"""OpenAI SDK through the Curtly proxy. Requires CURTLY_API_KEY and OPENAI_API_KEY."""
import os

from openai import OpenAI

client = OpenAI(
    base_url="https://curtly.dev/api/v1",
    api_key=os.environ["CURTLY_API_KEY"],
)

resp = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Explain what a token bucket rate limiter does."}],
    extra_headers={
        "X-Provider": "openai",
        "X-Provider-Key": os.environ["OPENAI_API_KEY"],
        "X-Curtly-Mode": "auto",
    },
)
print(resp.choices[0].message.content)
