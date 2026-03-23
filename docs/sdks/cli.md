---
title: "Novyx CLI — Command-Line Memory Management"
description: "Manage agent memories from the terminal. Store, search, rollback, audit, and export memories via the Novyx command-line interface."
---

# CLI

The Novyx CLI is included with the Python SDK. 24+ commands for managing memories, rollback, audit, and more.

## Installation

```bash
pip install novyx
```

## Setup

```bash
export NOVYX_API_KEY="nram_..."
```

Or pass `--api-key` to any command.

## Commands

### Memories

```bash
# Store a memory
novyx memories add "User prefers dark mode" --tags preferences,ui --importance 7

# List memories
novyx memories list --limit 20 --tags preferences

# Search semantically
novyx memories search "user preferences" --limit 5 --min-score 0.5

# Count memories
novyx memories count

# Delete a memory
novyx memories delete <memory-id> --yes
```

### Rollback

```bash
# Preview what would change
novyx rollback preview "2 hours ago"

# Execute rollback
novyx rollback "2 hours ago" --yes
```

### Audit

```bash
# View audit trail
novyx audit list --limit 20

# Verify hash chain integrity
novyx audit verify

# Export audit log
novyx audit export --format csv > audit.csv
```

### Context Spaces

```bash
# Create a space
novyx spaces create "project-alpha" --description "Alpha project memories"

# List spaces
novyx spaces list

# List memories in a space
novyx spaces memories <space-id>
```

### Stats & Health

```bash
# Memory statistics
novyx stats

# Dashboard (tier, usage, pressure)
novyx dashboard
```

### Eval

```bash
# Run health evaluation
novyx eval run

# CI/CD gate (exits non-zero if health below threshold)
novyx eval gate --min-score 70
```

## Output Formats

All list/search commands support `--format table` (default) and `--format json`:

```bash
novyx memories list --format json | jq '.memories[0]'
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `NOVYX_API_KEY` | Your API key |
| `NOVYX_BASE_URL` | Override API base URL |
