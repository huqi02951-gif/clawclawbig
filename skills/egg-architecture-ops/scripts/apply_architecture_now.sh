#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.openclaw/openclaw.json"
[ -f "$CFG" ] || { echo "openclaw.json not found"; exit 1; }

node - <<'NODE'
const fs=require('fs'),os=require('os');
const f=os.homedir()+'/.openclaw/openclaw.json';
const c=JSON.parse(fs.readFileSync(f,'utf8'));

c.agents=c.agents||{};
c.agents.defaults=c.agents.defaults||{};
c.agents.defaults.model=c.agents.defaults.model||{};
c.agents.defaults.model.primary='openai-codex/gpt-5.3-codex';
c.agents.defaults.model.fallbacks=[
  'openai-codex/gpt-5.2-codex',
  'google/gemini-1.5-pro',
  'google/gemini-1.5-flash'
];
c.agents.defaults.models=c.agents.defaults.models||{};
for (const m of ['openai-codex/gpt-5.3-codex','openai-codex/gpt-5.2-codex','google/gemini-1.5-pro','google/gemini-1.5-flash']) {
  c.agents.defaults.models[m]=c.agents.defaults.models[m]||{};
}

const ws=(c.agents.defaults.workspace)||os.homedir()+'/.openclaw/workspace';
c.agents.list=[
  {id:'main',default:true,workspace:ws,model:{primary:'openai-codex/gpt-5.3-codex',fallbacks:['openai-codex/gpt-5.2-codex']}},
  {id:'bank_codex',workspace:os.homedir()+'/.openclaw/workspace-bank',model:{primary:'openai-codex/gpt-5.3-codex',fallbacks:['openai-codex/gpt-5.2-codex']}},
  {id:'creative_pro',workspace:os.homedir()+'/.openclaw/workspace-creative',model:{primary:'google/gemini-1.5-pro',fallbacks:['openai-codex/gpt-5.2-codex']}},
  {id:'inbox_flash',workspace:os.homedir()+'/.openclaw/workspace-inbox',model:{primary:'google/gemini-1.5-flash',fallbacks:['openai-codex/gpt-5.2-codex']}},
];

c.bindings=[
  {agentId:'bank_codex', match:{channel:'telegram',peer:{kind:'group',id:'-1003718768220:topic:2'}}},
  {agentId:'inbox_flash',match:{channel:'telegram',peer:{kind:'group',id:'-1003718768220:topic:3'}}},
  {agentId:'bank_codex', match:{channel:'telegram',peer:{kind:'group',id:'-1003718768220:topic:6'}}},
  {agentId:'bank_codex', match:{channel:'telegram',peer:{kind:'group',id:'-1003718768220'}}},

  {agentId:'creative_pro',match:{channel:'telegram',peer:{kind:'group',id:'-1003898347494:topic:9'}}},
  {agentId:'creative_pro',match:{channel:'telegram',peer:{kind:'group',id:'-1003898347494:topic:10'}}},
  {agentId:'creative_pro',match:{channel:'telegram',peer:{kind:'group',id:'-1003898347494'}}},

  {agentId:'creative_pro',match:{channel:'telegram',peer:{kind:'group',id:'-1003559989927:topic:7'}}},
  {agentId:'inbox_flash',match:{channel:'telegram',peer:{kind:'group',id:'-1003559989927:topic:8'}}},
  {agentId:'inbox_flash',match:{channel:'telegram',peer:{kind:'group',id:'-1003559989927:topic:12'}}},
  {agentId:'inbox_flash',match:{channel:'telegram',peer:{kind:'group',id:'-1003559989927'}}},
];

// 响应稳定策略：open + mention gate
c.channels=c.channels||{};
c.channels.telegram=c.channels.telegram||{};
c.channels.telegram.groupPolicy='open';
for (const gid of Object.keys(c.channels.telegram.groups||{})) {
  const g=c.channels.telegram.groups[gid];
  g.groupPolicy='open';
  g.requireMention=true;
  if (g.topics) {
    for (const tid of Object.keys(g.topics)) {
      g.topics[tid].groupPolicy='open';
      g.topics[tid].requireMention=true;
      g.topics[tid].enabled=true;
    }
  }
}

fs.writeFileSync(f,JSON.stringify(c,null,2));
console.log('openclaw.json architecture mapping applied');
NODE

pm2 restart CEO-Hu >/dev/null

# cron model alignment
sys_id=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="系统简报-日报") | .id' | head -n1)
news_id=$(openclaw cron list --json | jq -r '.jobs[] | select(.name=="AI新闻日报") | .id' | head -n1)

if [ -n "${sys_id:-}" ]; then
  openclaw cron edit "$sys_id" --to "-1003559989927:topic:7" --model openai-codex/gpt-5.2-codex --thinking off >/dev/null
fi
if [ -n "${news_id:-}" ]; then
  openclaw cron edit "$news_id" --to "-1003559989927:topic:12" --model google/gemini-1.5-flash --thinking off >/dev/null
fi

echo "apply_architecture_now: done"
