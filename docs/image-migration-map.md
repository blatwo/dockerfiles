# Docker 镜像迁移映射

## 已确认的迁移范围

| 历史路径 | 新路径 | 处理方式 |
| --- | --- | --- |
| `highgo/hgdb-ee/hgdb-ee-6.0.4` | `hgdb/6.0/enterprise/6.0.4` | 复制，保留旧路径 |
| `highgo/hgdb-see/hgdb-see-4.5.7` | `hgdb/4.5/see/4.5.7` | 复制，保留旧路径 |
| `highgo/hgdb-see/hgdb-see-4.5.8` | `hgdb/4.5/see/4.5.8` | 复制，保留旧路径 |
| `highgo/hgdb-see/hgdb-see-4.5.10` | `hgdb/4.5/see/4.5.10` | 复制，保留旧路径 |
| `highgo/hgdb-see-postgis/4.5-3.4.0` | `hgdb/4.5/see-postgis/4.5-3.4.0` | 复制，保留旧路径 |
| `highgo/hgdb-see-postgis/4.5.10-3.4.0` | `hgdb/4.5/see-postgis/4.5.10-3.4.0` | 复制，保留旧路径 |

## 暂不迁移

- `highgo/hgdb-ee/hgdb-ee-v9-Oracle`
- `highgo/hgdb-ee/HighGo4.7.5-se`
- `baseos/`、`basetools/` 和 `ivorysql/`

这些目录的产品版本或兼容关系尚未形成统一模型，先保持原状。

## 兼容规则

`highgo/` 是历史构建入口，迁移完成前不得删除或重命名。新镜像维护和新文档引用优先使用 `hgdb/`。
