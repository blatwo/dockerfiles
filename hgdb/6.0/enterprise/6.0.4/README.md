# HGDB 6.0.4 Enterprise

该目录用于迁移 `highgo/hgdb-ee/hgdb-ee-6.0.4` 镜像。

目标结构：

```
hgdb/6.0/enterprise/6.0.4/
├── centos7-x86_64/
├── bullseye-x86_64/
└── bullseye-slim/
```

迁移原则：

- 保留原有 `highgo/` 目录，避免影响历史构建路径。
- 新目录按“产品版本 → Release → OS 变体”组织。
- 后续逐步迁移 Dockerfile、入口脚本和构建资源。
