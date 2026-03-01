#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/.openclaw/audits/model_hit_trend_latest.json"
SYS_ID=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="系统简报-日报") | .id' | head -n1)
NEWS_ID=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="AI新闻日报") | .id' | head -n1)

calc(){
  local id="$1" target="$2" name="$3"
  local raw total hit fallback dup
  raw=$(openclaw cron runs --id "$id" --limit 20 --expect-final 2>/dev/null || echo '{"entries":[]}')
  total=$(echo "$raw" | jq '.entries|length')
  short=$(echo "$target" | awk -F/ '{print $NF}')
  hit=$(echo "$raw" | jq --arg t "$target" --arg s "$short" '[.entries[]|select((.model==$t) or (.model==$s) or (.model|ascii_downcase==($t|ascii_downcase)) or (.model|ascii_downcase==($s|ascii_downcase)))]|length')
  fallback=$(( total - hit ))
  dup=$(echo "$raw" | python3 - <<'PY'
import sys,json,re,hashlib
try:
 d=json.load(sys.stdin)
 arr=d.get('entries',[])
 seen=set(); dup=0
 for e in arr:
  s=(e.get('summary') or '')
  s=re.sub(r'\s+',' ',s).strip().lower()[:500]
  h=hashlib.sha1(s.encode()).hexdigest() if s else None
  if not h: continue
  if h in seen: dup+=1
  else: seen.add(h)
 print(dup)
except Exception:
 print(0)
PY
)
  python3 - <<PY
import json
name=${name@Q}; target=${target@Q}; total=$total; hit=$hit; fallback=$fallback; dup=int(${dup:-0})
hitRate= (hit/total*100) if total else 0
fbRate= (fallback/total*100) if total else 0
dupRate=(dup/total*100) if total else 0
print(json.dumps({"name":name,"target":target,"totalRuns":total,"hitRuns":hit,"fallbackRuns":fallback,"duplicateRuns":dup,"hitRatePercent":round(hitRate,2),"fallbackRatePercent":round(fbRate,2),"duplicateRatePercent":round(dupRate,2)}))
PY
}

sys=$(calc "$SYS_ID" "gpt-5.2-codex" "系统简报-日报")
news=$(calc "$NEWS_ID" "google/gemini-2.5-flash" "AI新闻日报")
jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --argjson sys "$sys" --argjson news "$news" '{timestamp:$ts,sys:$sys,news:$news}' > "$OUT"
echo "$OUT"
