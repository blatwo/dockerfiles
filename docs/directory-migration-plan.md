# v0.2.0 Directory Migration Plan

## 目标

将当前 Dockerfile 集合逐步演进为 HighGo Database Docker 镜像工程仓库。

本阶段只设计目录规范，不立即移动现有文件，避免影响已有构建方式。

## 目标目录结构

```text
dockerfiles/
├── base/        # 基础操作系统和公共基础镜像
├── hgdb/        # HGDB 数据库镜像
├── tools/       # 工具组件和辅助镜像
├── examples/    # docker-compose、Kubernetes 部署示例
├── scripts/     # 构建、测试、发布脚本
├── tests/       # 镜像验证测试
└── docs/        # 工程文档
```

## 迁移原则

1. 不删除已有目录。
2. 新结构与旧结构并存过渡。
3. 每次迁移保持 Docker 构建可用。
4. 完成验证后再清理旧路径。

## 第一批迁移对象

优先迁移：

- HGDB 主数据库镜像；
- HGDB 工具镜像；
- Exporter 镜像。

## 后续步骤

1. 梳理当前镜像清单。
2. 确认每个镜像版本信息。
3. 创建标准镜像目录。
4. 增加 README 和构建说明。
5. 验证后合并旧目录。
