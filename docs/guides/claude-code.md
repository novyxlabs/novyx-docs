---
title: Claude Code + Novyx
description: Add persistent memory and automatic context persistence to Claude Code with Novyx MCP and Novyx Hygiene.
---

# Claude Code + Novyx

Two tools for Claude Code: **novyx-mcp** gives your agents persistent memory, and **novyx-hygiene** keeps your sessions alive across `/compact`, `/clear`, and restarts.

## Novyx MCP Server — Persistent Memory

Add persistent memory to Claude Code via the MCP protocol. One command to install, 23 tools available immediately.

### Install

```bash
claude mcp add novyx-memory -- uvx novyx-mcp
```

Or add to `~/.claude/mcp.json` manually:

```json
{
  "mcpServers": {
    "novyx-memory": {
      "command": "uvx",
      "args": ["novyx-mcp"]
    }
  }
}
```

### Local-First Mode (No API Key)

By default, novyx-mcp uses a local SQLite database at `~/.novyx/local.db`. No signup, no API key, no network calls. Memory works instantly.

### Cloud Mode (API Key)

Set `NOVYX_API_KEY` to enable cloud sync, audit trails, rollback, and sharing across machines:

```json
{
  "mcpServers": {
    "novyx-memory": {
      "command": "uvx",
      "args": ["novyx-mcp"],
      "env": {
        "NOVYX_API_KEY": "nram_your_key_here"
      }
    }
  }
}
```

Get a free API key at [novyxlabs.com](https://novyxlabs.com) (5,000 memories, no credit card).

### Available Tools (23)

| Tool | What It Does |
|------|-------------|
| `remember` | Store a memory with optional tags, importance, source |
| `recall` | Semantic search across all memories |
| `forget` | Delete a memory by ID |
| `list_memories` | List memories with filtering |
| `rollback` | Undo a memory operation with cryptographic proof |
| `audit` | View the audit trail for any memory |
| `add_triple` | Add a knowledge graph triple (subject-predicate-object) |
| `query_triples` | Query the knowledge graph |
| `link_memories` | Create semantic links between memories |
| `create_space` | Create a context space for organizing memories |
| `share_space` | Share a context space with another user |
| `cortex_run` | Run autonomous memory maintenance |
| `cortex_insights` | Get AI-generated insights from memory patterns |
| `replay_timeline` | View memory timeline for time-travel debugging |
| `replay_snapshot` | Point-in-time snapshot of memory state |
| `replay_diff` | Compare memory state between two points |
| `replay_lifecycle` | Track a single memory's full history |
| `memory_stats` | Usage statistics |
| And more... | 23 tools total |

### Shared Memory Across Agents

When multiple Claude Code agents share the same API key, they share memory. Agent 1 stores context, Agent 2 can recall it — even in different sessions. This is how Blake Heron (Novyx founder) runs 6+ parallel Claude Code agents as a coordinated team.

---

## Novyx Hygiene — Automatic Context Persistence

**The problem:** Context fills up. You `/compact` or `/clear`. Now Claude has amnesia. The manual workaround is export → clear → paste → re-establish. Every time.

**Novyx Hygiene makes this automatic.**

### Install

```bash
pip install novyx-hygiene
hygiene install
```

That's it. From now on:

1. **Before `/compact`**: Hygiene auto-saves your session (task, decisions, files, git state)
2. **After compact/clear/resume**: Hygiene injects your context back into Claude automatically
3. **On disk**: A `.claude/hygiene.md` file keeps Claude oriented between sessions

No commands to remember. No context to paste. Claude just knows where you left off.

### Commands

```bash
hygiene install              # Wire up Claude Code hooks (run once)
hygiene install --user       # Install for all projects
hygiene save <task>          # Manually save session state
hygiene resume               # Print most recent session context
hygiene score                # Check context health (A-F grade)
hygiene list                 # List all saved sessions
hygiene config set api_key X # Enable cloud sync (optional)
hygiene uninstall            # Remove hooks
```

### What Gets Saved

Every session snapshot captures:
- **Task description** — what you're working on
- **Key decisions** — architectural choices, tradeoffs
- **Status** — where you left off
- **Git state** — branch, modified/staged/untracked files, recent commits
- **Working directory** — so you resume in the right place
- **Timestamp** — for freshness scoring

### Context Health Scoring

```bash
$ hygiene score
Context Health: B (80/100)
========================================

Issues:
  - 12 files in flight
  - Changes span 5 top-level directories — possible mixed concerns

Tips:
  - Consider committing completed work before continuing
  - Consider splitting into focused sessions
```

### How Hooks Work

After `hygiene install`, your `.claude/settings.local.json` gets:

```json
{
  "hooks": {
    "PreCompact": [
      { "hooks": [{ "type": "command", "command": "hygiene save --auto --quiet", "timeout": 10 }] }
    ],
    "SessionStart": [
      { "matcher": "compact", "hooks": [{ "type": "command", "command": "hygiene inject", "timeout": 5 }] },
      { "matcher": "clear", "hooks": [{ "type": "command", "command": "hygiene inject", "timeout": 5 }] },
      { "matcher": "resume", "hooks": [{ "type": "command", "command": "hygiene inject", "timeout": 5 }] }
    ]
  }
}
```

- **PreCompact** runs before compaction, capturing your current state
- **SessionStart** runs after compact/clear/resume, injecting your last session context
- Hooks are additive — they won't overwrite your existing hooks

### Cloud Sync (Optional)

By default, sessions are saved locally to `~/.novyx_hygiene/sessions/`. Add a Novyx API key for cloud persistence and cross-machine sync:

```bash
pip install novyx-hygiene[novyx]
hygiene config set api_key nram_your_key_here
```

---

## Using Both Together

The best setup uses both:
- **novyx-mcp** for persistent memory (what your agents know)
- **novyx-hygiene** for session persistence (where you left off)

```bash
# Install MCP server for persistent memory
claude mcp add novyx-memory -- uvx novyx-mcp

# Install Hygiene for session persistence
pip install novyx-hygiene
hygiene install
```

Memory persists across agents. Sessions persist across compactions. Nothing gets lost.
