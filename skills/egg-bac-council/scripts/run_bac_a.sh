#!/usr/bin/env bash
set -euo pipefail
ISSUE="${1:-}"
[ -n "$ISSUE" ] || { echo "usage: $0 <issue>"; exit 1; }
mkdir -p "$HOME/.openclaw/audits"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT_JSON="$HOME/.openclaw/audits/bac_latest.json"
OUT_MD="$HOME/.openclaw/audits/bac_latest.md"

cat > "$OUT_JSON" <<JSON
{
  "timestamp":"$TS",
  "issue":"$ISSUE",
  "mode":"A_on_demand",
  "members":["risk_council","growth_council","engineering_council","finops_council","ops_council"],
  "note":"Use OpenClaw sessions_spawn tool from main agent to execute 5-member parallel debate and fill decision fields."
}
JSON

cat > "$OUT_MD" <<MD
# BAC 方案A 会议纪要
时间: $TS
议题: $ISSUE

## 委员（5人）
- risk_council
- growth_council
- engineering_council
- finops_council
- ops_council

## 执行说明
请由主Agent通过 sessions_spawn 并行拉起5位委员，收集观点后由主Agent裁决。

## 主席裁决模板
- 结论:
- 执行路径:
- 风险:
- 回滚:
- 需领导定夺:
MD

echo "$OUT_JSON"
echo "$OUT_MD"
