#!/usr/bin/env bash
set -euo pipefail
AGENT_ID="${1:?usage: switch_to_google.sh <agentId> <googleApiKey> [model]}"
API_KEY="${2:?usage: switch_to_google.sh <agentId> <googleApiKey> [model]}"
MODEL="${3:-google/gemini-2.5-flash}"

case "$AGENT_ID" in
  main|bank_codex|creative_pro|inbox_flash)
    echo "blocked: protected agent id $AGENT_ID" >&2; exit 2;;
esac

BASE="/home/daisy/.openclaw/agents/${AGENT_ID}"
AUTH="$BASE/agent/auth-profiles.json"
SESS="$BASE/sessions/sessions.json"
CFG="/home/daisy/.openclaw/openclaw.json"

mkdir -p "$(dirname "$AUTH")"
cat > "$AUTH" <<JSON
{
  "version": 1,
  "profiles": {
    "google:default": {"type": "api_key", "provider": "google", "key": "$API_KEY"}
  },
  "lastGood": {"google": "google:default"},
  "usageStats": {}
}
JSON
chmod 600 "$AUTH"

python3 - <<PY
import json
p='$CFG'
j=json.load(open(p))
for a in j.get('agents',{}).get('list',[]):
    if a.get('id')=='$AGENT_ID':
        a['model']= '$MODEL'
json.dump(j,open(p,'w'),ensure_ascii=False,indent=2)
print('config_updated')
PY

python3 - <<PY
import json, os
p='$SESS'
if os.path.exists(p):
    j=json.load(open(p))
    keys=[k for k in list(j.keys()) if k.startswith('agent:$AGENT_ID:telegram:direct:') or k.startswith('telegram:slash:')]
    for k in keys: j.pop(k,None)
    json.dump(j,open(p,'w'),ensure_ascii=False,indent=2)
    print('sessions_removed',len(keys))
else:
    print('no_sessions')
PY

pm2 restart CEO-Hu --update-env >/dev/null

echo "done: $AGENT_ID -> $MODEL"
echo "verify: openclaw agent --agent $AGENT_ID --to <your_id> --channel telegram --message '/status' --deliver --json"
