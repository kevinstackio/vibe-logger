# VibeLogger

每次 vibe coding session 结束自动生成日志，记录分支、提交、改动文件。

## 日志

日志统一写到当前工作目录的 `.vibe-logs/YYYY-MM-DD_HH-MM-SS.md`。

```
.vibe-logs/
├── 2026-04-19_15-30-42.md
└── 2026-04-21_22-48-17.md
```

也可以随时手动触发：说 `log session` 即可。

## 安装

```
/plugin install github:kevinstackio/vibe-logger
```

安装后无需任何配置，关闭 session 自动记录。
