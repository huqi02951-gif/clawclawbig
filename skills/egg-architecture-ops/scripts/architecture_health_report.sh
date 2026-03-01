#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/.openclaw/audits/architecture_health_report.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

sys_id=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="系统简报-日报") | .id' | head -n1)
news_id=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="AI新闻日报") | .id' | head -n1)

sys_run=$(openclaw cron runs --id "$sys_id" --limit 1 --expect-final 2>/dev/null || echo '{"entries":[]}')
news_run=$(openclaw cron runs --id "$news_id" --limit 1 --expect-final 2>/dev/null || echo '{"entries":[]}')
news_cfg=$(openclaw cron list --json | jq -r '.jobs[] | select(.id=="'"$news_id"'") | .payload.model // "(default)"' 2>/dev/null || echo "(default)")
news_actual=$(echo "$news_run" | jq -r '.entries[0].model // "no_run"')
news_fallback_reason=""
if [[ "$news_actual" != "google/gemini-2.5-flash" && "$news_actual" != "gemini-2.5-flash" && "$news_actual" != "no_run" ]]; then
  if [ -f "$HOME/.openclaw/audits/news_model_enforcer.log" ]; then
    news_fallback_reason=$(tail -n 20 "$HOME/.openclaw/audits/news_model_enforcer.log" | grep -E 'fallback news model=' | tail -n1 | sed 's/.*reason=//')
  fi
fi

sys_model=$(echo "$sys_run" | jq -r '.entries[0].model // "no_run"')
news_model=$(echo "$news_run" | jq -r '.entries[0].model // "no_run"')
sys_status=$(echo "$sys_run" | jq -r '.entries[0].status // "no_run"')
news_status=$(echo "$news_run" | jq -r '.entries[0].status // "no_run"')

bindings=$(openclaw agents list --bindings --json)

# bus guard merge
bus_out=$("$HOME/.openclaw/workspace/skills/egg-architecture-ops/scripts/department_bus_guard.sh" 2>/dev/null || true)
bus_issues='[]'
if [ -f "$HOME/.openclaw/audits/department_bus_guard_latest.json" ]; then
  bus_issues=$(jq -c '.issues // []' "$HOME/.openclaw/audits/department_bus_guard_latest.json")
fi

issues=()
[[ "$sys_status" != "ok" ]] && issues+=("系统简报任务异常:$sys_status")
[[ "$news_status" != "ok" ]] && issues+=("新闻日报任务异常:$news_status")
[[ "$news_model" != "google/gemini-2.5-flash" && "$news_model" != "gemini-2.5-flash" && "$news_model" != "gpt-5.2-codex" ]] && issues+=("新闻日报模型偏差:$news_model")
[[ "$sys_model" != "gpt-5.2-codex" && "$sys_model" != "openai-codex/gpt-5.2-codex" ]] && issues+=("系统简报模型偏差:$sys_model")

# merge bus issues
if [ "$bus_issues" != "[]" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && issues+=("$line")
  done < <(echo "$bus_issues" | jq -r '.[]')
fi

{
  echo "{";
  echo "  \"timestamp\": \"$TS\",";
  echo "  \"sysBrief\": {\"jobId\": \"$sys_id\", \"status\": \"$sys_status\", \"model\": \"$sys_model\"},";
  echo "  \"newsBrief\": {\"jobId\": \"$news_id\", \"status\": \"$news_status\", \"model\": \"$news_model\", \"configuredModel\": \"$news_cfg\", \"fallbackReason\": \"$news_fallback_reason\"},";
  echo "  \"bindings\": $bindings,";
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
