# Threat Model: Global AI Agent Configurator for Windows

This document outlines the security architecture, attack surfaces, threat categorization (STRIDE), and mitigations for the **Global AI Agent Configurator**.

---

## 1. System Overview & Trust Boundaries

The configurator unifies configuration files, rules, skills, and MCP servers across 19+ AI coding assistants on Windows.

### Key Components:
1. **Central Root (`%USERPROFILE%\.agents`)**: The primary storage for skills, rules, sub-agents, hooks, and `mcp.json`.
2. **Setup Scripts (`CyrusAsha_GlobalAgents.ps1`, `CyrusAsha_SetupGlobalAgents.cmd`)**: Administrative PowerShell scripts configuring Junctions and cloning repositories.
3. **Workspace Initializer (`init-project-files.ps1`)**: Project-level script creating local `.agents` Junctions and injecting instruction files.
4. **Third-Party Repositories (39 Repos)**: External Git sources cloned to provide modular skills and agents.
5. **AI Agent Run-times**: Desktop IDEs and CLI agents interacting with workspace code and MCP servers.

---

## 2. STRIDE Threat Analysis

| Threat Category | Potential Threat | Risk Level | Mitigation in Place |
| :--- | :--- | :---: | :--- |
| **Spoofing** | Compromised upstream repository supplying malicious skills under a legit name. | Medium | Fixed list of explicit HTTPS Git URLs in `$ReposList`. Clones use pinned shallow depth (`--depth 1`). |
| **Tampering** | Accidental or malicious overwrite of custom developer files during workspace sync. | Low | Managed-block architecture (`<!-- GLOBAL-AI-AGENTS:START -->`). The script only updates delimited blocks; user code outside the block is strictly preserved. |
| **Repudiation** | Lack of traceability when autonomous agents execute slash commands or modify files. | Low | Checkpoint logging via `~/.agents/session-state.md` and pre-compact hooks recording session activity. |
| **Information Disclosure** | Committing MCP credentials, API tokens, or session state to public GitHub repositories. | High | Comprehensive `.gitignore` excluding `.agents/`, `session-state.md`, `*.token`, `.env*`, and local secrets. `mcp.json` is stored in `%USERPROFILE%`, not in the project repo. |
| **Denial of Service** | Infinite symlink/junction loops causing tools or git scanners to hang or consume excessive memory. | Low | Standard NTFS Directory Junctions are created targeting absolute paths; circular references are prevented by explicit source-to-target path mapping. |
| **Elevation of Privilege** | Untrusted code execution when running the PowerShell script with Administrator rights. | Medium | Administrative rights are strictly isolated to creating Junctions and PowerShell profile registration. ExecutionPolicy is scoped to `-Scope CurrentUser` or `-Scope Process`. |

---

## 3. Attack Surfaces & Specific Mitigations

### 3.1 NTFS Junctions & File System Links
- **Risk**: Deleting a Junction with recursive delete commands (`rm -rf` or Explorer `Shift+Delete`) may inadvertently traverse the junction and erase central user files.
- **Mitigation**: Documented in `README.md` and `SECURITY.md` to unlink via `rmdir .agents` without `/s`. `.gitignore` explicitly prevents Git from tracking Junction targets.

### 3.2 Supply Chain & Skill Repository Sync
- **Risk**: Third-party repositories could contain unsafe code or prompt injections.
- **Mitigation**: Clones are restricted to verified public repositories. Repositories are cloned to a temporary directory (`$env:TEMP`) and only specified subfolders (`skills/`, `rules/`, `agents/`, `commands/`, `hooks/`) are selectively copied.

### 3.3 Credential Storage (`mcp.json`)
- **Risk**: AI tools reading `mcp.json` might expose API keys if logged or uploaded.
- **Mitigation**: `mcp.json` is created with placeholder mock tokens and kept outside project directories in the user profile root.
