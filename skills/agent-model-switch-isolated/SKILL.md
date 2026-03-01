---
name: agent-model-switch-isolated
description: Safely switch one isolated agent to a target model/provider and dedicated API key without affecting main or other department agents. Use for frequent per-agent model/key changes (e.g., xiaodandan).
---

Use this skill when you need to change model/key for one agent only.

Run:
```bash
scripts/switch_to_google.sh <agentId> <googleApiKey> [model]
```

Default model: `google/gemini-2.5-flash`

Hard guarantees:
- only edits target agent
- never edits `main`, `bank_codex`, `creative_pro`, `inbox_flash`
- resets target direct session to avoid old override cache
- restarts service and prints verification command

Governance mode (recommended):
- Key handling by main only
- Execution delegation to Topic8 (data ingress)
- Final acceptance by main

Read references:
- `references/postmortem-xiaodandan.md`
- `references/checklist.md`
- `references/governance-and-rbac.md`
