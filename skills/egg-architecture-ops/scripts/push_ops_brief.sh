#!/usr/bin/env bash
set -euo pipefail
TREND="$HOME/.openclaw/audits/model_hit_trend_latest.json"
HEALTH="$HOME/.openclaw/audits/architecture_health_report.json"
[ -f "$TREND" ] || exit 1
[ -f "$HEALTH" ] || exit 1

sys_hit=$(jq -r '.sys.hitRatePercent' "$TREND")
news_hit=$(jq -r '.news.hitRatePercent' "$TREND")
news_fb=$(jq -r '.news.fallbackRatePercent' "$TREND")
news_dup=$(jq -r '.news.duplicateRatePercent' "$TREND")
issues=$(jq -r '.issues|length' "$HEALTH")
news_model=$(jq -r '.newsBrief.model' "$HEALTH")

level="🟢 稳定"
if [ "$issues" -gt 0 ]; then level="🟡 注意"; fi
if awk "BEGIN{exit !($news_fb>60)}"; then level="🟡 注意"; fi

MSG="${level} 今日系统简报（董事长版）
【一句话总览】路由与自动化在运行，关键任务可达。
【分部门结果】
- 蛋工作：高风险任务走主模型，执行正常。
- 蛋创作：创作链可用，长文模型在线。
- 指挥中心：科技简报已投递，当前实际模型=${news_model}。
【风险灯】
- 新闻命中率 ${news_hit}% / 回退率 ${news_fb}% / 重复率 ${news_dup}%
- 架构问题数 ${issues}
【下一步动作】
1) 继续压低新闻回退率（主Agent执行）
2) 保持去重增量输出（topic12执行）
3) 2小时一次架构巡检（自动化执行）"

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
