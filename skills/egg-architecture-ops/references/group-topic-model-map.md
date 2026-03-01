# Group / Topic / Model / Automation Matrix

## 部门1：💻 蛋工作（group: -1003718768220）

- Topic 2 客户沟通
  - 角色：高情商客户经理
  - 模型：`openai-codex/gpt-5.3-codex`
  - 自动化：按需触发（不定时）
- Topic 6 授信项目
  - 角色：CPA级风控官
  - 模型：`openai-codex/gpt-5.3-codex`
  - 自动化：按需触发（不定时）
- Topic 3 日常工作
  - 角色：低成本执行专员（关键词触发高压升级）
  - 模型：`google/gemini-2.5-flash`（命中风控关键词时升级至 `openai-codex/gpt-5.3-codex`）
  - 自动化：可选日清任务（建议 1 次/天）

## 部门2：🎨 蛋创作（group: -1003898347494）

- Topic 9 小说
  - 角色：风格化小说编辑
  - 模型：`google/gemini-2.5-pro`（回退 `openai-codex/gpt-5.2-codex`）
  - 自动化：可选章节质检（建议 1 次/天）
- Topic 10 日常想法
  - 角色：灵感策展编辑
  - 模型：`google/gemini-2.5-pro`（回退 `openai-codex/gpt-5.2-codex`）
  - 自动化：日增量简报（去重）

## 部门3：🥚 全是蛋指挥中心（group: -1003559989927）

- Topic 8 数据入口
  - 角色：极速数据管家
  - 模型：`google/gemini-2.5-flash`（回退 `openai-codex/gpt-5.2-codex`）
  - 自动化：可选清洗任务（高频）
- Topic 7 系统简报
  - 角色：首席裁决官
  - 模型：`openai-codex/gpt-5.2-codex`
  - 自动化：系统简报-日报（08:30 Asia/Shanghai）
- Topic 12 科技简报
  - 角色：AI新闻助手
  - 模型：`google/gemini-2.5-flash`（回退 `openai-codex/gpt-5.2-codex`）
  - 自动化：AI新闻日报（08:30 Asia/Shanghai）

## 全局自动化

- 夜巡：23:50（`ceo_night_audit.sh`）
- 进程自愈：每10分钟
- 配置守护：每5分钟
- 自动备份：02:20
- 架构控制巡检：每2小时（模型命中率、任务状态、备份状态）
