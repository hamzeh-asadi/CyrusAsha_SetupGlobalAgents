<!-- GLOBAL-AI-AGENTS:START -->
# Global AI Agent Knowledge & Orchestration Index

CRITICAL INSTRUCTION FOR FREEBUFF / CODEBUFF DESKTOP AND CLI

This workspace is connected to the central AI agent directory:

- **Project path:** `.agents/`  (junction created by Initialize-AgentWorkspace)
- **User path:** `%USERPROFILE%\.agents`  (`~/.agents`)

Desktop apps such as **Freebuff** and **Codebuff** do not read the user-level folder
when a project is opened via Open Folder. They DO read files in the project root.
That is why this file exists: it points you at `.agents/`.

## Mandatory pre-execution steps

Before planning, coding, refactoring, UI/UX, SEO, or security work, silently:

1. Read and enforce `.agents/rules/00-auto-orchestrator.md`
2. Read and enforce `.agents/rules/security-architect.md`
3. Scan `.agents/skills/` and load the most relevant `SKILL.md` playbooks
4. Adopt a specialist persona from `.agents/agents/` when the domain is specific
5. Use MCP servers from `.agents/mcp.json`
6. Honor slash-command playbooks in `.agents/commands/`:
   `/CyrusAsha_Auto` `/CyrusAsha_Skills` `/CyrusAsha_Rules` `/CyrusAsha_Agents` `/CyrusAsha_Hooks` `/CyrusAsha_Commands` `/CyrusAsha_Audit-Security` `/CyrusAsha_Compact` 
7. Read and synchronize project domain context and conventions from `knowledge.md` (and `AGENTS.md`).

If `.agents/` is missing, run in PowerShell from the project root:

    Initialize-AgentWorkspace
    # aliases: agents-init    ai-init    init-agents    init-needed-files

Do not ignore this index. Treat `.agents/` as the single source of truth.
<!-- GLOBAL-AI-AGENTS:END -->

# Freebuff & Codebuff Knowledge Base: CyrusAsha_SetupGlobalAgents

## 1. System Knowledge & Purpose
`CyrusAsha_SetupGlobalAgents` is a unified Windows configuration framework designed to eliminate configuration fragmentation across 20+ AI coding environments. Freebuff and Codebuff open workspaces in project roots, where they inspect local files. This repository bridges project folders to the single global source of truth at `%USERPROFILE%\.agents` and synchronizes 39 curated open-source repositories.

---

## 2. Windows NTFS Junction Deep-Dive & OS Reinstall Recovery
- **What is a Junction?**: An NTFS Directory Junction is a filesystem reparse point redirecting directory requests to an alternate target on the same machine.
- **Physical Size**: A Junction in a project directory (`.agents/`) occupies **0 bytes of physical disk storage**.
- **Explorer Size Calculation**: Windows File Explorer traverses the junction pointer and totals the target directory contents (~350 MB from the 39 cloned repositories). This does NOT duplicate files or consume extra space on project partitions.
- **Safe Unlinking**: Never delete a Junction using `Shift+Delete` or recursive directory deletion. Use CMD `rmdir .agents` to safely remove the reparse point without modifying target files.
- **Windows OS Reinstall Resilience**: When Windows is reinstalled on `C:`, existing projects on secondary drives (`D:\`, `E:\`) retain old `.agents` reparse points that may point to missing user profiles or have stale SIDs. `Initialize-AgentWorkspace` automatically validates the health and target of `.agents`. If broken, dangling, or pointing to a previous installation, it safely removes the stale junction pointer and re-links it to the current user's `%USERPROFILE%\.agents`.

---

## 3. Orchestration Pipeline Stages
1. **Directory Preparation**: Creates `%USERPROFILE%\.agents\{skills,rules,agents,commands,hooks}`.
2. **Global Rules Deployment**: Generates `00-auto-orchestrator.md` and `security-architect.md`.
3. **Master Instruction Generation**: Writes managed blocks to central instruction files (`knowledge.md`, `AGENTS.md`, etc.).
4. **Slash Command Deployment**: Generates both branded (`CyrusAsha_<Name>.md`) and alias (`<name>.md`) files.
5. **Lifecycle Hooks**: Sets up `pre-compact.ps1` for conversation compaction.
6. **MCP Server Setup**: Installs `mcp.json` with 7 standard servers (GitHub, Filesystem, Brave, Supabase, DuckDB, GSC, Playwright) without overwriting existing tokens.
7. **Ecosystem Repository Sync**: Shallow-clones 39 open-source repos into `$env:TEMP` and extracts skills/rules/agents/commands.
8. **Resource Aggregation**: Scans existing agent installations to aggregate legacy user skills.
9. **Agent Home Linking**: Connects 20+ AI IDE home folders via Junctions.
10. **Global Command Registration**: Writes `init-project-files.ps1` and injects wrapper functions into PowerShell `$PROFILE`.

---

## 4. Supported Agents & Target Paths
| Agent / IDE | Path on Windows | Connection Method |
| :--- | :--- | :--- |
| **Hermes Agent** | `%USERPROFILE%\.hermes` | Directory Junction |
| **OpenCode** | `%USERPROFILE%\.config\opencode` | Directory Junction |
| **Antigravity** | `%USERPROFILE%\.antigravity` & `.gemini\antigravity` | Directory Junction |
| **Free-Pi CLI** | `%USERPROFILE%\.free-pi` & `.free-pi\agent` | Directory Junction |
| **VS Copilot** | `%USERPROFILE%\.copilot` | Directory Junction |
| **Freebuff / Codebuff** | `%USERPROFILE%\.freebuff` & `%APPDATA%\freebuff` | Directory Junction |
| **Claude Code** | `%USERPROFILE%\.claude` | Directory Junction |
| **Cursor** | `%USERPROFILE%\.cursor` | Directory Junction |
| **Codex CLI** | `%USERPROFILE%\.codex` | Directory Junction |
| **Gemini CLI** | `%USERPROFILE%\.gemini` | Directory Junction |
| **Windsurf / Codeium** | `%USERPROFILE%\.windsurf` & `%APPDATA%\Codeium` | Directory Junction |
| **Cline / Roo Code** | `%USERPROFILE%\.cline` & `%USERPROFILE%\.roo` | Directory Junction |
| **Continue.dev** | `%USERPROFILE%\.continue` | Directory Junction |
| **Trae / Junie / Goose** | `%USERPROFILE%\.trae` / `.junie` / `.goose` | Directory Junction |
| **Amazon Q / Aider** | `%USERPROFILE%\.amazonq` & `%USERPROFILE%\.aider` | Directory Junction |
