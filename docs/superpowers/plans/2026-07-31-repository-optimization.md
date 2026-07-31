# Repository Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the repository's maintainability and discoverability while preserving all existing `highgo/` build paths.

**Architecture:** Keep `highgo/` as a compatibility tree and copy the confirmed HGDB image families into versioned `hgdb/` paths. Replace the currently corrupted project documentation with UTF-8 documentation, then add a dependency-free validation script for Dockerfile structure and migration targets.

**Tech Stack:** Markdown, PowerShell, Git, Docker CLI (optional for build verification).

## Global Constraints

- Do not delete or rename existing `highgo/` paths.
- Do not alter Dockerfile contents during migration.
- Keep the repository usable for a single maintainer.
- Validate all changed paths with Git and the repository validation script.

---

### Task 1: Establish a safe working branch

**Files:**
- No file changes.

- [ ] Create branch `codex/repository-optimization` from the clean `main` branch.
- [ ] Verify the branch and clean worktree.

### Task 2: Repair project documentation

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/repository-engineering.md`
- Modify: `docs/image-migration-map.md`

- [ ] Rewrite the four documents as valid UTF-8 Markdown with the actual repository paths and current version lines.
- [ ] Document that `highgo/` remains the compatibility path and `hgdb/` is the new maintenance path.
- [ ] Verify the files contain no replacement-character or mojibake markers.

### Task 3: Copy the confirmed HGDB image families

**Files:**
- Create: `hgdb/6.0/enterprise/6.0.4/`
- Create: `hgdb/4.5/see/4.5.7/`
- Create: `hgdb/4.5/see/4.5.8/`
- Create: `hgdb/4.5/see/4.5.10/`
- Create: `hgdb/4.5/see-postgis/4.5-3.4.0/`
- Create: `hgdb/4.5/see-postgis/4.5.10-3.4.0/`

- [ ] Copy source directories without changing their contents.
- [ ] Confirm every source Dockerfile has a corresponding target Dockerfile.
- [ ] Keep the old source directories intact.

### Task 4: Add repeatable repository validation

**Files:**
- Create: `scripts/validate_repository.ps1`
- Create: `.github/workflows/validate.yml`

- [ ] Validate that every tracked Dockerfile is non-empty and contains a `FROM` instruction.
- [ ] Validate the five migration roots exist and contain Dockerfiles.
- [ ] Make the script fail with actionable paths and exit code 1.
- [ ] Run the script locally and validate the workflow YAML is present.

### Task 5: Review the resulting diff

**Files:**
- No additional file changes expected.

- [ ] Run `git diff --check`.
- [ ] Run the repository validation script.
- [ ] Review `git status` and the migration file counts.
