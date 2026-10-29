<!-- GLOBAL-AI-AGENTS:START -->
# Global AI Agent Knowledge & Orchestration Index

CRITICAL INSTRUCTION FOR GEMINI CLI

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
   `/CyrusAsha_Auto` `/CyrusAsha_Skills` `/CyrusAsha_Rules` `/CyrusAsha_Agents` `/CyrusAsha_Hooks` `/CyrusAsha_Commands` `/CyrusAsha_Audit-Security` `/CyrusAsha_Compact` `/CyrusAsha_Compress` 
7. Read and synchronize project domain context and conventions from `knowledge.md` (and `AGENTS.md`).

If `.agents/` is missing, run in PowerShell from the project root:

    Initialize-AgentWorkspace
    # aliases: agents-init    ai-init    init-agents    init-needed-files

Do not ignore this index. Treat `.agents/` as the single source of truth.
<!-- GLOBAL-AI-AGENTS:END -->

# Google Gemini CLI & Antigravity Guide: CyrusAsha_SetupGlobalAgents

## 1. Environment & Architecture Overview
This project configures and manages the universal AI agent environment on Windows.
When running within **Antigravity** or **Gemini CLI**:
- `%USERPROFILE%\.gemini` and `%USERPROFILE%\.gemini\antigravity` are linked to the central `%USERPROFILE%\.agents` directory.
- `skills/`, `rules/`, and `commands/` are automatically available in this workspace via the local `.agents` Junction.

## 2. Terminal & Sandbox Guidelines for Windows
- **Filesystem Access**: In standard sandbox mode on Windows, PowerShell process isolation may restrict execution outside drive `C:`. Use built-in filesystem tools (`read_file`, `write_file`, `edit_file`) for all operations across drives (such as `D:\MyHdd\...`).
- **Elevated Execution**: Windows Junction creation and profile changes require elevated user approval or `-ExecutionPolicy Bypass`. The launcher `CyrusAsha_SetupGlobalAgents.cmd` handles this cleanly for end users.

## 3. Core Directives for Gemini / Antigravity
1. **Rule Enforcement**: Always adhere to `.agents/rules/00-auto-orchestrator.md` and `.agents/rules/security-architect.md`.
2. **Managed Block Safety**: Any edits to project-level instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `knowledge.md`) must preserve the `<!-- GLOBAL-AI-AGENTS:START -->` delimiter block while maintaining the rich project context outside it.
3. **Slash Commands**: Execute or recommend `/CyrusAsha_*` slash commands from `.agents/commands/` for multi-stage workflows.
4. **Zero-Waste Storage**: Confirm that `.agents` in project roots remains a Junction (0 physical bytes) and is never duplicated or committed to Git.
5. **Context Density**: Always keep reasoning and chat output maximally concise and compressed.
