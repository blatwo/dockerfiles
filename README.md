# HighGo Database Docker Images

本仓库用于构建 HighGo Database（HGDB）及相关组件的 Docker 镜像。

当前仓库仍保留历史目录结构，同时逐步迁移到按产品版本组织的新结构。旧路径继续可用，新镜像优先放在 `hgdb/`、`base/` 和 `tools/` 下维护。

## 目录

| 目录 | 说明 |
| --- | --- |
| `baseos/` | 基础操作系统镜像，历史路径，暂不删除 |
| `basetools/` | 基础工具镜像，历史路径，暂不删除 |
| `highgo/` | 历史 HGDB 镜像路径，见 `highgo/DEPRECATED.md` |
| `hgdb/` | 新的、按 HGDB 产品版本组织的镜像路径 |
| `ivorysql/` | IvorySQL 镜像 |
| `docs/` | 仓库规范和迁移说明 |
| `scripts/` | 构建与校验脚本 |
| `examples/` | 部署示例 |
| `tests/` | 镜像测试 |

## 当前 HGDB 版本入口

```text
hgdb/
├── 4.5/
│   ├── see/
│   └── see-postgis/
├── 6.0/
│   └── enterprise/
└── 9.0/
```

具体版本和 OS 变体位于对应产品目录下。迁移映射见 [`docs/image-migration-map.md`](docs/image-migration-map.md)。

## 本地校验

在 PowerShell 中执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_repository.ps1
```

该校验不需要 Docker，主要检查 Dockerfile 是否完整以及已规划的迁移目录是否存在。

## 重复执行目录迁移

如需从历史目录重新生成新目录，可执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\migrate_layout.ps1
```

预览而不修改文件：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\migrate_layout.ps1 -WhatIf
```

## 构建镜像

每个镜像目录都是独立的 Docker 构建上下文。例如：

```powershell
docker build -t hgdb-see:4.5.10 .\highgo\hgdb-see\hgdb-see-4.5.10\bookworm
```

迁移期间，历史 `highgo/` 路径和新 `hgdb/` 路径都保留，避免影响已有构建命令。

## 版本路线

| 版本 | 内容 |
| --- | --- |
| `v0.1.0` | 当前仓库基线 |
| `v0.2.0` | 文档、版本目录和兼容迁移基础 |
| `v0.3.0` | 镜像元数据和统一构建入口 |
| `v0.4.0` | 自动构建、冒烟测试和安全扫描 |
