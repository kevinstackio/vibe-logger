# VibeLogger

每次 Claude Code session 结束自动生成日志，记录分支、提交、改动文件。

## 日志

日志写到当前项目的 `.vibe-logs/`，每次 session 一个文件：

```
.vibe-logs/
├── README.md                  ← 自动生成，说明文件
├── 2026-04-19_15-30-42.md
└── 2026-04-21_22-48-17.md
```

## 安装

### 上架后（即将支持）

```
/plugin install github:kevinstackio/vibe-logger
```

### 手动安装（当前可用）

```bash
curl -fsSL https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/install.sh | bash
```

安装后无需任何配置，session 结束自动记录。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/kevinstackio/vibe-logger/main/install.sh | bash -s uninstall
```

## 常用命令

在 CC 对话中直接说：

| 命令 | 作用 |
|------|------|
| `log session` | 手动记录当前 session |
| `disable vibe logger` | 关闭当前项目的自动记录 |
| `enable vibe logger` | 重新开启当前项目的自动记录 |

## 说明

- 日志按项目隔离，写到各自的 `.vibe-logs/`
- 建议在 `.gitignore` 中加入 `.vibe-logs/`
