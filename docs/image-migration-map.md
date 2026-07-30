# Docker 镜像迁移映射

## Current mapping

| Old path | Target path |
| --- | --- |
| `highgo/hgdb-see` | `hgdb/4.5/see` |
| `highgo/hgdb-see-postgis` | `hgdb/4.5/see-postgis` |
| `highgo/hgdb-ee` | `hgdb/6.0/enterprise` |
| Future HGDB 9.0 images | `hgdb/9.0/` |

## Migration strategy

1. Create target directory structure.
2. Verify Docker build compatibility.
3. Migrate images gradually.
4. Keep old paths during transition.

Do not remove historical paths until migration is complete.
