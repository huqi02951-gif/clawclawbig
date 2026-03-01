# 模型与APIKey治理（RBAC）

## 总原则
- APIKey只进入主脑（胡蛋蛋）处理链路。
- 业务配置与切模执行下沉到数据入口 Topic8。
- 任何变更必须“单agent隔离”，禁止影响 main/部门agent。

## 职责分离
1. 董事长：提出资源投入（新模型/新供应商）与目标agent。
2. 主脑（胡蛋蛋）：
   - 接收并安全部署 APIKey（仅目标agent）
   - 审批并下发执行单到 Topic8
   - 最终验收与风险复核
3. 数据入口 Topic8：
   - 执行模型切换、fallback设置、会话清理、验证回报
   - 更新运行台账与知识库
4. 部门agent：仅使用，不接触密钥。

## 最简流程（SOP）
1) 董事长发：目标agent + 目标模型 + 新key（仅主脑）
2) 主脑写入目标agent auth-profiles.json
3) Topic8执行切模与会话清理
4) Topic8回传 /status 证据
5) 主脑验收并归档

## 红线
- 禁止在群里明文扩散 key。
- 禁止修改 main/bank_codex/creative_pro/inbox_flash 的模型或鉴权。
- 禁止全量清会话，只能清目标agent会话。
