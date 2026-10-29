# Security Policy

## Supported Versions

Security updates and patches are actively maintained for the following versions:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | :white_check_mark: | Active (Current Master Edition) |
| < 1.0.0 | :x:                | Deprecated |

---

## Reporting a Vulnerability

We take the security of the Global AI Agent Configurator seriously. If you discover a security vulnerability or security-related issue in this project, please report it responsibly:

1. **Private Report**: Do **not** open a public GitHub issue for security vulnerabilities.
2. **Contact**: Reach out to the maintainer directly via GitHub Security Advisories or via Telegram at [@Asadi_hamzeh](https://t.me/Asadi_hamzeh).
3. **Information to Include**:
   - Description of the vulnerability.
   - Proof of Concept (PoC) or reproducible steps.
   - Impact assessment on the host operating system or agent environment.
   - Suggested remediation or patch (if available).

You can expect an initial acknowledgment within 48 hours and a coordinated disclosure timeline.

---

## Security Architecture & Best Practices

This project manages multi-agent configurations, Windows Junctions, and MCP servers. Keep the following security principles in mind:

### 1. PowerShell Script Execution
- The setup script interacts with Windows filesystem structures (NTFS Junctions) and user profiles.
- Review `CyrusAsha_GlobalAgents.ps1` before executing with administrative privileges.
- Always run scripts from trusted, verified sources.

### 2. Secret Management (`mcp.json`)
- The central `mcp.json` file is stored in `%USERPROFILE%\.agents\mcp.json` and is **never** committed to version control.
- Never hardcode personal access tokens (GitHub PAT, Brave API keys, Supabase tokens, etc.) into repository files or commits.
- All tokens provided in the template code are safe mock placeholders (`YOUR_*_TOKEN_HERE`).

### 3. NTFS Junction Safety
- Directory Junctions created in project roots (`.agents/`) point to `%USERPROFILE%\.agents`.
- To unlink or remove a local `.agents` junction without deleting central data, use `rmdir .agents` (never use recursive delete or `Shift+Delete` in File Explorer).
- `.gitignore` is configured to prevent committing Junction targets or contents to Git.

### 4. Upstream Repository Sourcing
- When syncing external skill and agent repositories (the 40 curated open-source tools), shallow clones (`--depth 1`) are fetched from verified GitHub repositories.
- Periodic code audits should be performed on downloaded skills before executing external tools or prompts.
