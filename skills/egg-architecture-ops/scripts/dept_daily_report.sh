#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/.openclaw/audits/dept_daily_report_latest.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# 基础运行数据（按agent近况近似映射部门执行）
status=$(openclaw status --deep)

bank_model=$(echo "$status" | grep -E 'agent:bank_codex:telegram:group:-1003718768220' -m1 | awk '{print $(NF-5)}' || true)
creative_model=$(echo "$status" | grep -E 'agent:creative_pro:telegram:group:-1003898347494' -m1 | awk '{print $(NF-5)}' || true)
hq_model=$(echo "$status" | grep -E 'agent:inbox_flash:telegram:group:-1003559989927' -m1 | awk '{print $(NF-5)}' || true)

# 关键任务状态
SYS_ID=$(openclaw cron list --json | jq -r '.jobs[]|select(.name=="系统简报-日报")|.id' | head -n1)
NEWS_ID=$(openclaw cron list --json | jq -r '.jobs[]|select(.name=="AI新闻日报")|.id' | head -n1)
SYS_RUN=$(openclaw cron runs --id "$SYS_ID" --limit 1 --expect-final 2>/dev/null || echo '{"entries":[]}')
NEWS_RUN=$(openclaw cron runs --id "$NEWS_ID" --limit 1 --expect-final 2>/dev/null || echo '{"entries":[]}')

sys_ok=$(echo "$SYS_RUN" | jq -r '.entries[0].status // "no_run"')
news_ok=$(echo "$NEWS_RUN" | jq -r '.entries[0].status // "no_run"')
sys_model=$(echo "$SYS_RUN" | jq -r '.entries[0].model // "no_run"')
news_model=$(echo "$NEWS_RUN" | jq -r '.entries[0].model // "no_run"')

# 部门-员工责任映射
cat > "$OUT" <<JSON
{
  "timestamp":"$TS",
  "departments":[
    {
      "name":"蛋工作",
      "groupId":"-1003718768220",
      "ownerAgent":"bank_codex",
      "employees":[
        {"topic":2,"name":"客户沟通专员","responsibility":"客户口径与推进动作"},
        {"topic":3,"name":"日常执行专员","responsibility":"低成本日常执行与信息整理"},
        {"topic":6,"name":"授信风控官","responsibility":"授信审查与风控建议"}
      ],
      "today":"执行正常，重点任务聚焦授信与沟通",
      "risk":"$([ "$bank_model" = "" ] && echo "需观测" || echo "可控")",
      "modelHint":"${bank_model:-openai-codex/gpt-5.3-codex}"
    },
    {
      "name":"蛋创作",
      "groupId":"-1003898347494",
      "ownerAgent":"creative_pro",
      "employees":[
        {"topic":9,"name":"小说编辑","responsibility":"长文成稿与逻辑打磨"},
        {"topic":10,"name":"灵感策展员","responsibility":"创意收敛与提纲"}
      ],
      "today":"创作链可用，适合中长文与策划任务",
      "risk":"$([ "$creative_model" = "" ] && echo "需观测" || echo "可控")",
      "modelHint":"${creative_model:-google/gemini-2.5-pro}"
    },
    {
      "name":"全是蛋指挥中心",
      "groupId":"-1003559989927",
      "ownerAgent":"inbox_flash",
      "employees":[
        {"topic":8,"name":"数据入口管家","responsibility":"数据清洗、打标、归档"},
        {"topic":12,"name":"科技简报员","responsibility":"新闻增量简报"},
        {"topic":7,"name":"系统简报官","responsibility":"管理层可读三段式汇总"}
      ],
      "today":"系统简报=${sys_ok}(${sys_model})，新闻日报=${news_ok}(${news_model})",
      "risk":"$([ "$sys_ok" = "ok" ] && [ "$news_ok" = "ok" ] && echo "可控" || echo "关注")",
      "modelHint":"${hq_model:-google/gemini-2.5-flash}"
    }
  ],
  "pairing":[
    {"a":"topic8 数据入口管家","b":"topic7 系统简报官","why":"数据->管理结论直连，减少复读"},
    {"a":"topic12 科技简报员","b":"topic7 系统简报官","why":"新闻增量直接转管理动作"},
    {"a":"topic6 授信风控官","b":"main 胡蛋蛋","why":"高风险结论进入主脑裁决"},
    {"a":"topic2 客户沟通专员","b":"topic6 授信风控官","why":"口径与风险一致性"}
  ]
}
JSON

echo "$OUT"
