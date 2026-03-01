# I/O Contracts (Department Hard Isolation)

## Topic 8 数据入口（执行层，信息中枢）
- Input: 原始数据（链接/文本/文件）
- Output: Ticket Envelope + Data Block（并驱动全局自动化调度）
- Extra Duty:
  - 监控 token/磁盘/内存压力
  - 执行入职校验（部门与员工契约）
  - 执行优先级路由（P0/P1/P2）
  - 超阈值触发压缩与降载策略
- Forbidden: 观点/决策/新闻复读

## Topic 12 科技简报（执行层）
- Input: 新闻候选
- Output: 新闻增量 + Ticket Envelope(to topic7)
- Forbidden: 系统结论/重复全文

## Topic 7 系统简报（汇总层）
- Input: 仅 topic8/topic12 envelope + 部门日报聚合
- Output: 领导可读简报（总览/分部门结果/风险灯/下一步动作）
- Forbidden: 原始抓取/新闻正文复读

## Topic 2/6 银行（专业层）
- Topic2: 沟通口径与行动
- Topic6: 风控链路与授信建议

## 临时加更一键触发（Topic8）
- 命令：`~/.openclaw/ops/news_breaking_trigger.sh "<原因>"`
- 目标：向Topic12下发加更指令（仅新增<=3条，禁止复读）
- 触发条件：监管处罚/重大融资/核心模型发布/突发安全事件
