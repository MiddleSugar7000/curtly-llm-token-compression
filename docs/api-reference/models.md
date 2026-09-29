# `GET /api/v1/models`

Returns an OpenAI-style model list so SDKs and tools that call `models.list()` work against Curtly.

```bash
curl https://curtly.dev/api/v1/models -H "Authorization: Bearer $CURTLY_API_KEY"
```

```json
{
  "object": "list",
  "data": [
    { "id": "gpt-4o", "object": "model", "created": 1700000000, "owned_by": "openai" }
  ]
}
```

The list is built from a built-in registry of common and frontier models and, when reachable, a dynamically fetched list that is cached for one hour. A model appearing here does not mean your upstream account has access to it; access is determined by your provider key.

See also [models and tokenizers](../models-and-tokenizers.md).
