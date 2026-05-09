# Global Codex Guidelines

## Git 提交规范

commit message 使用：

```text
type(scope): subject
```

要求：

- `type` 使用标准 convention 类型
- `scope` 表示职责范围，不直接使用包名
- `subject` 使用简洁中文描述，本次提交的内容
- commit 首行尽量不超过 72 个字符
- 破坏性变更需包含 `BREAKING CHANGE:`

示例：

```text
feat(control): 增加急停状态锁存逻辑
fix(config): 修正默认参数加载顺序
```

除非用户明确要求，否则不要主动执行：

```bash
git commit
git push
git rebase
```
