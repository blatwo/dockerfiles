# HighGo Database Docker Images

本仓库用于构建瀚高数据库（HighGo Database，HGDB）相关 Docker 镜像。

当前仓库从个人 Dockerfile 集合逐步演进为企业级数据库镜像工程仓库。

## 当前内容

包括：

- HGDB 数据库镜像；
- HGDB 相关工具镜像；
- 数据库扩展镜像；
- 基础环境镜像。

## 仓库演进规划

版本规划：

| 版本 | 目标 |
| --- | --- |
| v0.1.0 | 初始版本基线 |
| v0.2.0 | 仓库结构规范化、文档完善 |
| v0.3.0 | 镜像版本元数据管理 |
| v0.4.0 | 标准化构建流程 |
| v1.0.0 | 企业级 HGDB Docker 镜像体系 |

## 目录规划

后续逐步向以下结构演进：

```
dockerfiles/
├── base/        # 基础镜像
├── hgdb/        # HGDB 镜像
├── tools/       # 工具组件
├── examples/    # 部署示例
├── scripts/     # 构建脚本
├── tests/       # 镜像测试
└── docs/        # 工程文档
```

## 设计目标

构建稳定、安全、可重复构建、易于交付、长期可维护的数据库容器镜像体系。

## 贡献

欢迎提交 Issue 和 Pull Request，共同完善 HGDB Docker 镜像工程。