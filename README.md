# Diego's Skills

Custom skills for [Claude Code](https://docs.anthropic.com/claude/claude-code) and [OpenAI Codex CLI](https://developers.openai.com/codex/cli).

Both tools use the same `SKILL.md` format, so each skill folder installs into both:

- Claude Code: `~/.claude/skills/<name>/`
- Codex: `~/.codex/skills/<name>/`

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/WinnerWang971119/my_skills/main/install.sh | bash
```

### Windows (PowerShell — preferred on Windows)

```powershell
iwr -useb https://raw.githubusercontent.com/WinnerWang971119/my_skills/main/install.ps1 | iex
```

Re-run anytime to pull the latest version. The installer overwrites existing skills with the same name.

> **Tip:** `curl ... | bash` and `iwr ... | iex` execute remote scripts directly. To inspect first:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/WinnerWang971119/my_skills/main/install.sh | less
> ```

## Skills included

- `plan` — structured planning before implementation
- `execute` — executes a plan via parallel sub-agents
- `structured-debug` — structured bug investigation workflow

## Layout

```
my_skills/
├── install.sh
├── install.ps1
├── README.md
├── plan/
│   └── SKILL.md
├── execute/
│   └── SKILL.md
└── structured-debug/
    └── SKILL.md
```

Any folder at the repo root containing a `SKILL.md` will be installed. Folders starting with `.` and `node_modules/` are skipped.
