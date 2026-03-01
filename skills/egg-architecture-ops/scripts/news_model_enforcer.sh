#!/usr/bin/env bash
set -euo pipefail
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
LOG="$HOME/.openclaw/audits/news_model_enforcer.log"
JOB_ID=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="AI新闻日报") | .id' | head -n1)
[ -n "$JOB_ID" ] || { echo "[$TS] missing AI新闻日报 job" >> "$LOG"; exit 1; }

# 优先看最近执行是否已有gemini命中（避免被旧1.5探测误导）
recent=$(openclaw cron runs --id "$JOB_ID" --limit 3 --expect-final 2>/dev/null || echo '{"entries":[]}')
hit=$(echo "$recent" | jq '[.entries[] | select((.model=="gemini-2.5-flash") or (.model=="google/gemini-2.5-flash"))] | length')

if [ "$hit" -gt 0 ]; then
  openclaw cron edit "$JOB_ID" --model google/gemini-2.5-flash --thinking off >/dev/null 2>&1 || true
  echo "[$TS] keep news model=google/gemini-2.5-flash (recent hit=$hit)" >> "$LOG"
  exit 0
fi

# 未命中时，做google provider探测（仅作保守降级依据）
set -a; [ -f "$HOME/.openclaw/.env" ] && source "$HOME/.openclaw/.env"; set +a
probe=$(openclaw models status --probe --probe-provider google --json 2>/dev/null || echo '{}')
status=$(echo "$probe" | jq -r '.auth.probes.results[0].status // "unknown"')
err=$(echo "$probe" | jq -r '.auth.probes.results[0].error // ""' | tr '\n' ' ')

if [ "$status" = "ok" ]; then
  openclaw cron edit "$JOB_ID" --model google/gemini-2.5-flash --thinking off >/dev/null 2>&1 || true
  echo "[$TS] set news model=google/gemini-2.5-flash (probe ok)" >> "$LOG"
else
  openclaw cron edit "$JOB_ID" --model openai-codex/gpt-5.2-codex --thinking off >/dev/null 2>&1 || true
  echo "[$TS] fallback news model=gpt-5.2-codex (probe=$status reason=$err)" >> "$LOG"
fi
