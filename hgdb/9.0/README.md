# HGDB 9.0 Docker Images

## Overview

This directory is reserved for HighGo Database (HGDB) 9.0 series Docker images.

Current status:

- Directory baseline created.
- Image implementation will be added after version and product packaging information is confirmed.

## Planned structure

```
9.0/
├── enterprise/
├── extensions/
└── README.md
```

## Design principles

- Keep HGDB versions isolated.
- Support independent lifecycle management.
- Avoid mixing different product generations.
- Maintain reproducible Docker image builds.
