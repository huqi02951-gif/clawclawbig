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
- Save useful rules into references and sync to git.

## Upgrade reserve (方案B)
Use `references/upgrade-path-b.md` to migrate to persistent committee sessions.
