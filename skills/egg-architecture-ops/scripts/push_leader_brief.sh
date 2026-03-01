#!/usr/bin/env bash
set -euo pipefail
R="$HOME/.openclaw/audits/dept_daily_report_latest.json"
[ -f "$R" ] || exit 1

summary(){ jq -r "$1" "$R"; }

d1=$(summary '.departments[0].today')
d2=$(summary '.departments[1].today')
d3=$(summary '.departments[2].today')
r1=$(summary '.departments[0].risk')
r2=$(summary '.departments[1].risk')
r3=$(summary '.departments[2].risk')

p1=$(summary '.pairing[0].a + " ↔ " + .pairing[0].b + "（" + .pairing[0].why + "）"')
p2=$(summary '.pairing[1].a + " ↔ " + .pairing[1].b + "（" + .pairing[1].why + "）"')
p3=$(summary '.pairing[2].a + " ↔ " + .pairing[2].b + "（" + .pairing[2].why + "）"')

MSG="📊 领导日简报（部门责任版）
【蛋工作】$d1｜风险:$r1
负责人：bank_codex；员工：T2客户沟通/T3日常执行/T6授信风控

【蛋创作】$d2｜风险:$r2
负责人：creative_pro；员工：T9小说编辑/T10灵感策展

【指挥中心】$d3｜风险:$r3
负责人：inbox_flash；员工：T8数据入口/T12科技简报/T7系统简报

【跨部门结对子建议】
1) $p1
2) $p2
3) $p3

【领导追责定位】
- 授信问题找：蛋工作-T6
- 简报重复/错投找：指挥中心-T7/T12
- 数据归档错误找：指挥中心-T8"

TOKEN=$(python3 - <<'PY'
import json, os
p=os.path.expanduser('~/.openclaw/openclaw.json')
try:
 j=json.load(open(p)); print(j.get('channels',{}).get('telegram',{}).get('botToken',''))
except Exception:
 print('')
PY
)
[ -n "$TOKEN" ] || exit 0
curl -sS -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d "chat_id=-1003559989927" \
  -d "message_thread_id=7" \
  --data-urlencode "text=$MSG" >/dev/null || true
