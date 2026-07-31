# Deprecated Image Layout

`highgo/` is the legacy directory layout for HighGo Database Docker images.

New image organization uses the version-based structure:

```
hgdb/
├── 4.5/
├── 6.0/
└── 9.0/
```

Migration mapping:

| Legacy path | New path |
| --- | --- |
| `highgo/hgdb-see` | `hgdb/4.5/see` |
| `highgo/hgdb-see-postgis` | `hgdb/4.5/see-postgis` |
| `highgo/hgdb-ee` | `hgdb/6.0/enterprise` |

The legacy directories are temporarily retained for compatibility. New development should use the `hgdb/` directory layout.
