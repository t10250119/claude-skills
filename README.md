# Claude Skills

Reusable Claude Code slash commands for development workflows.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Code Review | `/review` | Review uncommitted changes — correctness, security, performance |
| Coding | `/code <task>` | Implement a feature or fix with read-plan-code-verify workflow |
| R&D Agent | `/rd <task>` | Full R&D cycle: research, analyze, implement, verify, report |
| QA | `/qa <target>` | Test audit, test plan, write missing tests, report coverage gaps |

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
