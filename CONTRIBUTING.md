# Contributing to Global AI Agent Configurator

Thank you for your interest in improving the **Global AI Agent Configurator for Windows**! Contributions from the open-source and AI development community are welcome.

---

## How You Can Contribute

1. **Add New Skills**: Suggest or integrate new high-value `SKILL.md` playbooks.
2. **Add Sub-Agents**: Contribute specialist AI persona definitions to `~/.agents/agents/`.
3. **Add MCP Servers**: Propose useful, stable Model Context Protocol servers to `mcp.json`.
4. **Support More AI Agents / IDEs**: Add detection and junction paths for emerging AI editors.
5. **Fix Bugs & Improve Scripts**: Optimize PowerShell logic, junction handling, or error recovery.

---

## Submitting Changes

### 1. Fork and Clone
```bash
git clone https://github.com/<your-username>/CyrusAsha_SetupGlobalAgents.git
cd CyrusAsha_SetupGlobalAgents
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/add-new-skill-or-agent
```

### 3. Guidelines for PowerShell Scripts
- **Idempotency**: Scripts must be safe to run multiple times without causing duplicate entries or errors.
- **Non-Destructive**: Never overwrite or delete user files directly. Always use the managed block pattern (`Update-ManagedBlock`) with start/end markers.
- **Cross-Version Support**: Scripts should run smoothly on both **Windows PowerShell 5.1** and **PowerShell 7+**.
- **No Hardcoded Secrets**: Ensure all token parameters remain mock values.

### 4. Test Locally
Run the modified script in a test environment:
```powershell
.\CyrusAsha_SetupGlobalAgents.cmd
```
Verify that all junctions are created properly and no errors are raised.

### 5. Open a Pull Request
- Provide a clear description of your changes and why they benefit the ecosystem.
- Reference any relevant issues or feature requests.

---

## Code of Conduct

Please maintain a respectful, constructive, and inclusive environment for all contributors and users.
