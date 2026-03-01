# BAC 委员会 Subagent 模型映射（V1）

## 委员与模型
- risk_council（风控）
  - primary: openai-codex/gpt-5.3-codex
  - fallback: openai-codex/gpt-5.2-codex
- growth_council（增长）
  - primary: openai-codex/gpt-5.2-codex
  - fallback: google/gemini-2.5-flash
- engineering_council（工程）
  - primary: openai-codex/gpt-5.3-codex
  - fallback: openai-codex/gpt-5.2-codex
- finops_council（成本）
  - primary: google/gemini-2.5-flash
  - fallback: openai-codex/gpt-5.2-codex
- ops_council（运营）
  - primary: google/gemini-2.5-flash
  - fallback: openai-codex/gpt-5.2-codex

## 触发规则
- P0/P1 议题自动触发 5 委员并行辩论。
- 主席（main）统一裁决并输出：结论/路径/风险/回滚/需定夺。

## 升级策略
- 任一委员返回“能力不足”或“证据不足”时，自动升级到 fallback 模型并补一轮输出。
