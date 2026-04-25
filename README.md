# Claude Skills

Reusable Claude Code slash commands for development workflows.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Code Review | `/review` | Review uncommitted changes — correctness, security, performance |
| R&D / Build | `/rd <task>` | Unified entry for any code change: research → analyze → implement → verify → report. Scales rigor to task complexity (trivial fix to novel architecture) |
| QA | `/qa <target>` | Test audit, test plan, write missing tests, report coverage gaps |

## Subagents

The skills delegate exploration and analysis work to specialized subagents (installed to `.claude/agents/`):

| Agent | Used by | Purpose |
|-------|---------|---------|
| `code-explorer` | `/qa`, `/rd` | Read-only codebase mapper — files, entry points, data flow, conventions |
| `test-auditor` | `/qa`, `/rd` | Audits test coverage, flags weak/flaky tests, recommends additions (also runs in Verify to check new code is covered) |
| `solution-evaluator` | `/rd` | Compares 2-4 design options on correctness/complexity/risk/maintainability |
| `diff-critic` | `/rd` | Fresh-eye diff review for off-by-one, null risks, error path leaks, edge cases |
| `security-auditor` | `/review`, `/rd` | Security-focused review: injection, authz, secrets, SSRF, weak crypto |

## Installation

### Global (all projects)

```bash
./install.sh global
```

Skills are installed to `~/.claude/commands/` and available in every project.

### Per-project (copy)

```bash
./install.sh project /path/to/your/project
```

Skills are copied to `<project>/.claude/commands/`.

### Per-project (git submodule)

```bash
./install.sh submodule /path/to/your/project
```

Adds this repo as a submodule at `.claude-skills/` and copies commands to `.claude/commands/`.

### Windows

On Windows (Git Bash / MSYS2), the script defaults to copy mode. Use `--link` to force symlinks (may require admin privileges).

## Uninstall

```bash
./install.sh global --remove
./install.sh project /path/to/project --remove
```

## Adding New Skills

1. Create a new `.md` file in the repo root
2. Add the filename to the `SKILLS` array in `install.sh`
3. Re-run `install.sh` to deploy

## Adding New Subagents

1. Create a new `.md` file under `agents/` with frontmatter (`name`, `description`, `tools`, `model`)
2. Add the filename to the `AGENTS` array in `install.sh`
3. Re-run `install.sh` to deploy
