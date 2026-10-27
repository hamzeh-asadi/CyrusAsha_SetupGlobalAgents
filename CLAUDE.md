<!-- GLOBAL-AI-AGENTS:START -->
# Global AI Agent Knowledge & Orchestration Index

CRITICAL INSTRUCTION FOR CLAUDE CODE

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

If `.agents/` is missing, run in PowerShell from the project root:

    Initialize-AgentWorkspace
    # aliases: agents-init    ai-init    init-agents    init-needed-files

Do not ignore this index. Treat `.agents/` as the single source of truth.
<!-- GLOBAL-AI-AGENTS:END -->

# Claude Code Project Guide: CyrusAsha_SetupGlobalAgents

## 1. Project Context
This codebase maintains the **Global AI Agent Configurator for Windows**, automating the configuration of 19+ AI coding tools through NTFS Directory Junctions and modular skills from 22 open-source repositories.

Claude Code's personal home directory (`~/.claude`) is directly junctioned to this system:
- `~/.claude/skills` -> `~/.agents/skills`
- `~/.claude/rules` -> `~/.agents/rules`
- `~/.claude/commands` -> `~/.agents/commands` (enabling `/CyrusAsha_*` slash commands in Claude Code)
- `~/.claude/mcp.json` -> `~/.agents/mcp.json`

## 2. Common Development & Verification Commands
- **Launch Setup (One-Click)**:
  `.\CyrusAsha_SetupGlobalAgents.cmd`
- **Execute Orchestrator Directly**:
  `powershell.exe -ExecutionPolicy Bypass -File .\CyrusAsha_GlobalAgents.ps1`
- **Lint PowerShell Scripts with PSScriptAnalyzer**:
  `pwsh -Command "Invoke-ScriptAnalyzer -Path .\ -Recurse -Severity Error, Warning"`
- **Test Workspace Initializer**:
  `powershell.exe -Command ". .\CyrusAsha_GlobalAgents.ps1; Initialize-AgentWorkspace -Path . -Full"`
- **Validate Junction Status**:
  `cmd.exe /c "dir /a .agents"`

## 3. PowerShell Code Style & Standards
- **Verb-Noun Naming**: Use official PowerShell approved verbs (`Get-`, `Set-`, `New-`, `Update-`, `Install-`).
- **Parameter Validation**: Explicitly type parameters and use `[Parameter(Mandatory)]` where required.
- **Error Handling**: Use `try / catch` blocks with `-ErrorAction Stop` for critical operations (e.g. junction creation, file writing).
- **Encoding**: Always specify `-Encoding UTF8` when reading or writing files via `Get-Content` or `Set-Content`.
- **Delimited Updates**: Modifications to user project files must strictly occur inside `Update-ManagedBlock` or `Update-GaMarkedSection`.
- **No PowerShell 7 Exclusives**: Maintain backward compatibility with Windows PowerShell 5.1 (avoid `??`, `||`, `&&` in scripts).

## 4. Key Security Boundaries
- Never commit `.agents` (enforced via `.gitignore`).
- Never overwrite `mcp.json` if it already exists in the user profile (user API keys must be preserved).
- Always ensure all slash commands in `.agents/commands/` are mirrored with both `CyrusAsha_*` and short alias names.
