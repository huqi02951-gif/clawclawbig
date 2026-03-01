#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/.openclaw/audits/department_bus_guard_latest.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jobs=$(openclaw cron list --json)
news_to=$(echo "$jobs" | jq -r '.jobs[] | select(.name=="AI新闻日报") | .delivery.to // ""')
sys_to=$(echo "$jobs" | jq -r '.jobs[] | select(.name=="系统简报-日报") | .delivery.to // ""')
news_model_cfg=$(echo "$jobs" | jq -r '.jobs[] | select(.name=="AI新闻日报") | .payload.model // ""')
sys_model_cfg=$(echo "$jobs" | jq -r '.jobs[] | select(.name=="系统简报-日报") | .payload.model // ""')

issues=()
[[ "$news_to" != "-1003559989927:topic:12" ]] && issues+=("新闻日报目标topic错误:$news_to")
[[ "$sys_to" != "-1003559989927:topic:7" ]] && issues+=("系统简报目标topic错误:$sys_to")
[[ "$news_model_cfg" != "google/gemini-2.5-flash" ]] && issues+=("新闻日报模型配置偏差:$news_model_cfg")
[[ "$sys_model_cfg" != "openai-codex/gpt-5.2-codex" ]] && issues+=("系统简报模型配置偏差:$sys_model_cfg")

# fallback threshold from trend report
trend="$HOME/.openclaw/audits/model_hit_trend_latest.json"
if [ -f "$trend" ]; then
  fb=$(jq -r '.news.fallbackRatePercent // 0' "$trend")
  if awk "BEGIN{exit !($fb>70)}"; then
    issues+=("新闻日报回退率过高:${fb}%")
  fi
fi

{
  echo "{";
  echo "  \"timestamp\": \"$TS\",";
  echo "  \"news_to\": \"$news_to\",";
  echo "  \"sys_to\": \"$sys_to\",";
  echo "  \"news_model_cfg\": \"$news_model_cfg\",";
  echo "  \"sys_model_cfg\": \"$sys_model_cfg\",";
  printf '  "issues": [';
  if [ ${#issues[@]} -gt 0 ]; then
    for i in "${!issues[@]}"; do
      printf '%s"%s"' "$( [ $i -gt 0 ] && echo ',' )" "${issues[$i]}"
    done
  fi
  echo "]";
  echo "}";
} > "$OUT"

echo "$OUT"
