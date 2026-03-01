---
name: egg-architecture-ops
description: Enforce and operate the 全是蛋公司 Telegram multi-group architecture with deterministic group/topic routing, model tiering, cron automation, backup checks, and architecture health reports. Use when configuring or repairing group/topic responsibilities, model assignments, cron delivery targets, fallback behavior, or when auditing execution quality/cost/security across 蛋工作、蛋创作、全是蛋指挥中心.
---

Apply the architecture in this order.

## 1) Apply deterministic routing + model policy

Run:

```bash
scripts/apply_architecture_now.sh
```

This command:
- applies agent list + bindings
- enforces group/topic routing for 3 groups and key topics
- enforces stable response policy (`open + requireMention`)
- aligns cron models/targets:
  - 系统简报-日报 -> topic:7 -> gpt-5.2-codex
  - AI新闻日报 -> topic:12 -> gemini-1.5-flash (fallback observed -> tracked in reports)
- keeps 新闻日报与系统简报分离，禁止互相覆盖

## 2) Verify architecture health

Also run model enforcement before health check when optimizing 新闻日报成本/稳定性:

```bash
scripts/news_model_enforcer.sh
```


Run:

```bash
scripts/architecture_health_report.sh
scripts/model_hit_trend.sh
```

Read output:
- `~/.openclaw/audits/architecture_health_report.json`
- `~/.openclaw/audits/model_hit_trend_latest.json`
- check `issues[]` and model hit rate (especially AI新闻日报 flash 命中率)

If `issues[]` is non-empty, run step 1 again and re-check.

## 3) Use the canonical map

Use both references as source of truth:
- `references/group-topic-model-map.md`
- `references/io-contracts.md`

Run bus guard + contract gate:

```bash
scripts/department_bus_guard.sh
scripts/data_hub_admission_gate.sh
```

Validate separation between 新闻日报(topic12) and 系统简报(topic7), model configs, fallback-risk threshold, and onboarding contract completeness.

Use `references/group-topic-model-map.md` as source of truth for:
- each group mission
- each topic role
- model tier per topic
- automation ownership

## 4) Operating rule

- Keep `main` for high-stakes architecture and final arbitration.
- Keep repetitive/news/data-ingest tasks in lower tiers.
- Keep outputs incremental (avoid repeated full reposts).
- Do not merge “系统简报” and “新闻日报” into one cron job.
- Enforce department capability boundaries and onboarding contract before enabling new topics.

## 5) Department training rollout

Use iterative prompts for continuous self-improvement and reusable knowledge capture:
- `/home/daisy/.openclaw/workspace/skills/egg-architecture-ops/references/iterative-prompt.zh.md`
- `/home/daisy/.openclaw/workspace/skills/egg-architecture-ops/references/iterative-prompt.en.md`

After each major fix, update both prompt files and sync changes to Git.

## 6) Department training rollout details

Use these workspace playbooks for onboarding and training:
- `/home/daisy/.openclaw/workspace/DEPARTMENT_OPERATING_MODEL.md`
- `/home/daisy/.openclaw/workspace/DEPARTMENT_TRAINING_AND_ROLLOUT.md`

Execution checklist:
1. run `scripts/data_hub_admission_gate.sh`
2. run `scripts/department_bus_guard.sh`
3. run `scripts/architecture_health_report.sh`
4. verify `issues[]` is empty before production rollout
