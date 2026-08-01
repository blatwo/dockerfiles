# Dockerfiles 仓库工程规范

## 目标

在不破坏历史构建路径的前提下，将 Dockerfile 集合逐步演进为可追踪、可验证、易交付的 HGDB 镜像仓库。

## 目录原则

- 一个产品版本目录对应一条可维护的版本线。
- 具体镜像按“产品版本 → 产品形态 → 发布版本 → OS 变体”组织。
- 历史目录只做兼容，不在其中新增镜像。

推荐结构：

```text
hgdb/
├── 4.5/
│   ├── see/<release>/<os>/
│   └── see-postgis/<release>/<os>/
├── 6.0/
│   └── enterprise/<release>/<os>/
└── 9.0/
```

## 单个镜像目录

一个可构建目录至少应包含：

- `Dockerfile`
- `README.md`
- 构建所需的入口脚本、配置文件和证书文件

后续版本可补充：

- `VERSION` 或等价元数据文件
- `healthcheck.sh`
- 独立的构建和冒烟测试入口

## 兼容迁移

迁移采用复制而不是删除：

1. 在 `hgdb/` 创建新路径。
2. 原样复制 Dockerfile 和构建上下文。
3. 用校验脚本确认源、目标都完整。
4. 在 `highgo/` 保留旧路径，并标记为 deprecated。
5. 新功能只进入新路径。

迁移命令由 `scripts/migrate_layout.ps1` 维护。脚本只执行复制，不执行删除；复制完成后应运行 `scripts/validate_repository.ps1`。

## 质量门槛

每次结构或 Dockerfile 变更至少执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_repository.ps1
git diff --check
```

涉及镜像行为变更时，再执行对应 Docker build 和运行冒烟测试。
