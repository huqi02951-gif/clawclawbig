#!/usr/bin/env bash
set -euo pipefail
ISSUE="${1:-}"
[ -n "$ISSUE" ] || { echo "usage: $0 <issue>"; exit 1; }
mkdir -p "$HOME/.openclaw/audits"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT_JSON="$HOME/.openclaw/audits/bac_latest.json"
OUT_MD="$HOME/.openclaw/audits/bac_latest.md"

run_member(){
  local role="$1" prompt="$2"
  openclaw sessions spawn --runtime subagent --mode run --model openai-codex/gpt-5.2-codex --task "你是${role}。议题：${ISSUE}。${prompt}。仅输出：结论(1句)+3条要点+1条风险。" --json
}

risk=$(run_member "risk_council" "从合规与最坏场景评估")
growth=$(run_member "growth_council" "从增长收益评估")
eng=$(run_member "engineering_council" "从实现复杂度与回滚评估")
finops=$(run_member "finops_council" "从成本与资源评估")
ops=$(run_member "ops_council" "从协同与执行SLA评估")

# 简单汇总（由脚本模板归档，实际裁决仍由main在会话中完成）
cat > "$OUT_JSON" <<JSON
{
  "timestamp":"$TS",
  "issue":$(python3 - <<PY
import json
print(json.dumps('$ISSUE',ensure_ascii=False))
PY
),
  "members":{
    "risk":$risk,
    "growth":$growth,
    "engineering":$eng,
    "finops":$finops,
    "ops":$ops
  }
}
JSON

cat > "$OUT_MD" <<MD
# BAC 方案A 会议纪要
时间: $TS
议题: $ISSUE

## 委员输出已生成
- risk_council
- growth_council
- engineering_council
- finops_council
- ops_council

## 主席裁决模板（main填充）
- 结论:
- 执行路径:
- 风险:
- 回滚:
- 需领导定夺:
MD

echo "$OUT_JSON"
echo "$OUT_MD"
