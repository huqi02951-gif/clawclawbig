---
name: egg-bac-council
description: Run the 全是蛋公司 BAC 委员会 in on-demand mode (方案A) with 5 council members, produce a leadership decision brief, and preserve upgrade path to persistent committee mode (方案B).
---

## Purpose
On-demand (方案A) 5-member committee for high-value decisions:
- risk_council
- growth_council
- engineering_council
- finops_council
- ops_council

Chair: main 胡蛋蛋.

## Run (方案A)

```bash
scripts/run_bac_a.sh "<议题>"
```

Outputs:
- `~/.openclaw/audits/bac_latest.json`
- `~/.openclaw/audits/bac_latest.md`

## Governance
- Trigger only for P0/P1 issues.
- Output format fixed: 结论 / 路径 / 风险 / 回滚 / 需定夺.
- Before delegation, always report a short owner-mapping suggestion (任务→最适合的部门/Topic).
- Chair focuses on decision/judgment; execution tasks must be delegated to the right department topic.
- Save useful rules into references and sync to git.

## Model assignment for 5 subagents
Use `references/subagent-model-map.md` as the source of truth.

Execution rule:
- Spawn 5 subagents with role-specific primary models.
- If a member fails or returns low-confidence, rerun that member with fallback model.

## Upgrade reserve (方案B)
Use `references/upgrade-path-b.md` to migrate to persistent committee sessions.
