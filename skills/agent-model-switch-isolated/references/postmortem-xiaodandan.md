# Postmortem: xiaodandan 模型反复回退到 codex

根因：
1. 旧会话键 `agent:xiaodandan:telegram:direct:8448075744` 持续复用，覆盖新配置观感。
2. 目标 agent 目录迁移不完整，`agent/auth-profiles.json` 缺失或被旧流程重写。
3. 操作口径混乱（看旧session状态，不看当前run实测）。

修复原则：
- 单 agent 隔离变更
- 写入目标 agent 独立 auth-profiles.json
- 清理目标 agent 直聊 session 键
- 重启后用 `openclaw agent --agent <id> ... /status` 实测
