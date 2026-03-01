# 方案B升级路径（预留）

1. 为5位委员各建 persistent session（thread=true, mode=session）
2. 将角色提示词固化到各委员会话首消息
3. 建立会话健康守护（上下文体积、漂移、失联重建）
4. 主席（main）通过 sessions_send 广播议题并收敛裁决
5. 每周做委员漂移校准（提示词更新+样例回放）
