# Dockerfiles Repository Engineering Guide

## 目标

将当前 Dockerfile 集合逐步演进为企业级 HGDB Docker 镜像工程仓库。

## 后续规范

### 镜像目录

推荐：

```
hgdb/
├── <version>/
│   ├── enterprise/
│   ├── standard/
│   └── extensions/
```

### 每个镜像建议包含

- Dockerfile
- README.md
- VERSION
- entrypoint.sh
- healthcheck.sh

### 生命周期管理

每个镜像版本需要明确：

- HGDB 版本；
- 基础操作系统版本；
- 构建时间；
- 兼容环境；
- 升级和回滚方式。

## 改造原则

- 保持历史镜像兼容；
- 小步演进；
- 避免无必要重构；
- 优先提升可维护性和交付能力。
