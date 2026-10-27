# Pre-Release & Deployment Security Checklist

This checklist must be reviewed before committing, tagging, or releasing any updates to the **Global AI Agent Configurator** repository on GitHub.

---

## 1. Secrets & Credentials Sanitization
- [ ] **No Hardcoded Tokens**: Verify that `CyrusAsha_GlobalAgents.ps1`, `CyrusAsha_SetupGlobalAgents.cmd`, and documentation contain **only** placeholder tokens (e.g., `YOUR_*_TOKEN_HERE`).
- [ ] **No User-Specific Paths**: Check that no hardcoded personal usernames or local secrets remain in committed scripts.
- [ ] **Environment Template**: Verify `.env.example` provides safe mock values with no production credentials.
- [ ] **Git Secret Scan**: Run a local secret scan (e.g. `gitleaks` or `git diff`) before pushing.

---

## 2. File System & Link Architecture
- [ ] **Junction Exclusion in Git**: Confirm `.agents` and `.agents/` are listed in `.gitignore` so no linked files or 200+ MB directories are tracked.
- [ ] **Non-Destructive Overwrites**: Verify that `Update-ManagedBlock` preserves all user-authored content outside the `<!-- GLOBAL-AI-AGENTS:START -->` markers.
- [ ] **Reparse Point Validation**: Ensure junctions are verified using `Test-Path -LiteralPath` before creation to avoid accidental overwrites.
- [ ] **Path Handling**: Check that all PowerShell file operations use `Join-Path` or double-quoted paths to accommodate spaces in usernames and paths.

---

## 3. PowerShell Security & Execution
- [ ] **Execution Policy**: Scripts do not alter machine-wide ExecutionPolicy (`-Scope Process` or `-Scope CurrentUser` only).
- [ ] **Error Handling**: `$ErrorActionPreference` is handled gracefully without crashing active user sessions.
- [ ] **Unblock-File Safety**: `CyrusAsha_SetupGlobalAgents.cmd` unblocks only its sibling script, avoiding wide filesystem unblocking.
- [ ] **No Arbitrary Remote Code Execution**: Ensure no `Invoke-Expression` (`iex`) is executed against unvalidated remote URLs.

---

## 4. Governance & Repository Hygiene
- [ ] **License**: `LICENSE` file (MIT) is present and attributed.
- [ ] **Security Policy**: `SECURITY.md` is present with contact information and vulnerability reporting process.
- [ ] **Threat Model**: `THREAT-MODEL.md` is updated for any new components or integrations.
- [ ] **Agent Instructions**: `AGENTS.md` and related index files reflect the current version.
- [ ] **Clean Git Working Tree**: Verify with `git status` that untracked temporary files (`*.tmp`, `.log`, `.session.json`) are absent.
