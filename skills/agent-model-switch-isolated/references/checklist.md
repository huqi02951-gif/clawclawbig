# 模型切换最简检查清单

1. 确认仅目标agent变更（禁止动 main/部门agent）
2. 写入目标agent独立google key
3. 清理目标agent直聊session键
4. 重启服务
5. 用目标agent发 `/status` 验证 provider/model
