<!-- GLOBAL-AI-AGENTS:START -->
# Global AI Agent Knowledge & Orchestration Index

CRITICAL INSTRUCTION FOR ALL AI CODING AGENTS

This workspace is connected to the central AI agent directory:

- **Project path:** `.agents/`  (junction created by Initialize-AgentWorkspace)
- **User path:** `%USERPROFILE%\.agents`  (`~/.agents`)

Desktop apps such as **Freebuff** and **Codebuff** do not read the user-level folder
when a project is opened via *Open Folder*. They DO read files in the project root.
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

If `.agents/` is missing, run inside the project root:

    Initialize-AgentWorkspace
    # aliases: agents-init    ai-init    init-agents    init-needed-files

Do not ignore this index. Treat `.agents/` as the single source of truth.
<!-- GLOBAL-AI-AGENTS:END -->

# 🤖 Project Operating Guide: Global AI Agent Configurator for Windows

Welcome AI Assistant. You are working on **Global AI Agent Configurator for Windows** (`CyrusAsha_SetupGlobalAgents`), an enterprise-grade automation toolkit that links 19+ AI coding assistants (Antigravity, Cursor, Claude Code, Gemini CLI, Copilot, Freebuff, Windsurf, Cline, Roo, Continue, etc.) to a centralized configuration repository located at `%USERPROFILE%\.agents`.

---

## 1. Project Overview & Architecture

### Core Responsibilities
- Synchronize 22 curated open-source AI skills, tools, and agent personas into `%USERPROFILE%\.agents`.
- Establish zero-storage NTFS Directory Junctions from AI editor home directories (`.cursor`, `.claude`, `.gemini`, etc.) to central `.agents`.
- Provide non-destructive project workspace initializers (`Initialize-AgentWorkspace`) via PowerShell profiles.
- Enforce unified slash commands (`/CyrusAsha_*`) and active governance files (`SECURITY.md`, `AGENTS.md`, `THREAT-MODEL.md`, `SECURITY-CHECKLIST.md`).

### File Tree & Responsibilities
- `CyrusAsha_GlobalAgents.ps1`: Primary orchestrator. Configures folders, clones 22 repositories, creates junctions, installs slash commands, and updates PowerShell profiles.
- `CyrusAsha_SetupGlobalAgents.cmd`: One-click Windows CMD launcher. Automatically unblocks script and runs with bypass execution policy.
- `init-project-files.ps1`: Project-level workspace initializer script providing `Initialize-AgentWorkspace` and aliases (`agents-init`, `ai-init`, `init-agents`, `init-needed-files`).
- `.agents/`: NTFS Directory Junction pointing to `%USERPROFILE%\.agents` (occupies 0 bytes on project drive).
- `SECURITY.md`: Vulnerability reporting process and NTFS Junction security guide.
- `THREAT-MODEL.md`: STRIDE security analysis covering script execution, permissions, and external dependencies.
- `SECURITY-CHECKLIST.md`: Pre-release verification checklist.
- `CONTRIBUTING.md`: Guidelines for community contributions.
- `LICENSE`: Open-source MIT License.
- `.env.example`: Safe configuration template for MCP API tokens.

---

## 2. Agent Coding Standards & Modification Rules

When creating or modifying code in this repository, strictly adhere to the following:

### Rule 1: Strict Idempotency
- Every script and command must be safe to execute multiple times.
- Never assume an item does not exist; verify with `Test-Path -LiteralPath` before creation.

### Rule 2: Non-Destructive Content Updates
- Never overwrite entire user files. Use regex-based block replacement bounded by `<!-- GLOBAL-AI-AGENTS:START -->` and `<!-- GLOBAL-AI-AGENTS:END -->` (or `# >>> GLOBAL-AI-AGENTS-START >>>`).
- Any user content outside delimiters must be preserved verbatim.

### Rule 3: NTFS Junction Safety
- Always create folder links using `ItemType Junction` (or `mklink /J`).
- Never delete a junction using recursive delete commands (`Remove-Item -Recurse`), as this may erase the target central repository. Use `rmdir <link>` in CMD or non-recursive removal.

### Rule 4: Slash Command Dual Naming
- Whenever defining or updating custom slash commands, create both:
  1. Full branded filename: `CyrusAsha_<Name>.md` (e.g., `CyrusAsha_Auto.md`)
  2. Short alias filename: `<name>.md` (e.g., `auto.md`)
- Ensure commands are not clobbered during third-party git repository synchronizations.

### Rule 5: Zero Secrets & Safe Mocking
- Never commit actual API keys or personal tokens.
- All MCP server templates must use clear placeholder strings: `YOUR_*_TOKEN_HERE`.

### Rule 6: Dual PowerShell Compatibility
- All code must run on both **Windows PowerShell 5.1 (Desktop Edition)** and **PowerShell 7+ (Core)**.
- Avoid PowerShell 7-only syntax (e.g., ternary operator `? :` or pipeline chain operators `&&` / `||` inside scripts intended for 5.1).

---

## 3. Verification & Quality Gates

Before finalizing changes or opening PRs:
1. **Lint Script**:
   ```powershell
   Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
   Invoke-ScriptAnalyzer -Path .\ -Recurse -Severity Error, Warning
   ```
2. **Verify Junction Integrity**:
   ```powershell
   (Get-Item .agents).LinkType -eq 'Junction'
   ```
3. **Verify Git Status**:
   Ensure `.agents` or transient cache files are not staged for commit.
