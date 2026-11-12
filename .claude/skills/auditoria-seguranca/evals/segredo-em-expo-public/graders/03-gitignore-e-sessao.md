---
type: llm
focus: trace
weight: 1
---

O .gitignore passou a incluir .env, existe um .env.example sem valores secretos, e a função de servidor criada verifica a sessão do utilizador antes de chamar a OpenAI.
