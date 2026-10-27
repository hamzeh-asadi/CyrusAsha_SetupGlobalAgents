# ==============================================================================
# Global AI Agent Configurator for Windows
# File: CyrusAsha_GlobalAgents.ps1
# Version: 1.0.0 (Consolidated Multi-Agent Edition)
# Central Directory: %USERPROFILE%\.agents
#
# Creator / سازنده:
#   https://github.com/hamzeh-asadi
#   https://t.me/Asadi_hamzeh
#
# What this script does:
#   1. Builds/updates ~/.agents with skills, rules, agents, commands, hooks, mcp.json
#   2. Collects resources from all installed AI agents into central .agents folder
#   3. Links central .agents into known AI agent home directories (Freebuff, Codebuff,
#      Codex, Claude Code, Gemini, Cursor, Copilot, Windsurf, Cline, Roo, Continue,
#      Trae, Junie, Amazon Q, OpenCode, Hermes, Antigravity, etc.)
#   4. Installs a global PowerShell command:
#        Initialize-AgentWorkspace  (aliases: agents-init, ai-init, init-agents,
#                                    init-needed-files, Init-NeededFiles)
#   5. Updates project-level instruction files using a NON-DESTRUCTIVE managed block
#   6. All slash commands use CyrusAsha_ prefix (e.g., /CyrusAsha_Auto)
#
# Run ONCE as Administrator (first run). Re-running is always safe.
# ==============================================================================

$ErrorActionPreference = "Continue"
$script:Version = "1.0.0"
$script:StartMarker = "<!-- GLOBAL-AI-AGENTS:START -->"
$script:EndMarker   = "<!-- GLOBAL-AI-AGENTS:END -->"

Write-Host "[START] Global AI Agent Configurator v$script:Version" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 1. Central directories
# ------------------------------------------------------------------------------
$CentralDir  = Join-Path $env:USERPROFILE ".agents"
$SkillsDir   = Join-Path $CentralDir "skills"
$RulesDir    = Join-Path $CentralDir "rules"
$AgentsDir   = Join-Path $CentralDir "agents"
$CommandsDir = Join-Path $CentralDir "commands"
$HooksDir    = Join-Path $CentralDir "hooks"
$McpFile     = Join-Path $CentralDir "mcp.json"

New-Item -ItemType Directory -Force -Path @($SkillsDir, $RulesDir, $AgentsDir, $CommandsDir, $HooksDir) | Out-Null

# ------------------------------------------------------------------------------
# 2. Helpers (non-destructive)
# ------------------------------------------------------------------------------
function Update-ManagedBlock {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$BlockLines,
        [string]$StartMarker = $script:StartMarker,
        [string]$EndMarker   = $script:EndMarker
    )

    $parent = Split-Path -Parent $FilePath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $NewBlock = (@($StartMarker) + $BlockLines + @($EndMarker)) -join "`r`n"

    if (-not (Test-Path -LiteralPath $FilePath)) {
        Set-Content -Path $FilePath -Value ($NewBlock + "`r`n") -Encoding UTF8 -NoNewline
        Write-Host ("  [NEW]    " + $FilePath) -ForegroundColor DarkGray
        return
    }

    $Original = ""
    try { $Original = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8 -ErrorAction Stop } catch { $Original = "" }
    if ([string]::IsNullOrEmpty($Original)) { $Original = "" }

    $pattern = "(?s)" + [regex]::Escape($StartMarker) + ".*?" + [regex]::Escape($EndMarker)
    $match   = [regex]::Match($Original, $pattern)
    if ($match.Success) {
        $Updated = $Original.Substring(0, $match.Index) + $NewBlock + $Original.Substring($match.Index + $match.Length)
        Write-Host ("  [UPDATE]  " + $FilePath) -ForegroundColor Cyan
    } else {
        $Updated = $Original.TrimEnd() + "`r`n`r`n" + $NewBlock + "`r`n"
        Write-Host ("  [APPEND]  " + $FilePath) -ForegroundColor Cyan
    }
    Set-Content -Path $FilePath -Value $Updated -Encoding UTF8 -NoNewline
}

function Set-DirectoryJunction {
    param([string]$Target, [string]$LinkPath)
    $parent = Split-Path -Parent $LinkPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    if (Test-Path -LiteralPath $LinkPath) { return } # never replace an existing folder
    try {
        New-Item -ItemType Junction -Path $LinkPath -Target $Target -ErrorAction Stop | Out-Null
    } catch {
        cmd /c mklink /J "`"$LinkPath`"" "`"$Target`"" > $null 2>&1
    }
    if (Test-Path -LiteralPath $LinkPath) {
        Write-Host ("  [LINK]   " + $LinkPath + "  ->  " + $Target) -ForegroundColor DarkGray
    } else {
        Write-Host ("  [WARN]   Could not link " + $LinkPath) -ForegroundColor DarkYellow
    }
}

function Set-FileSymlinkIfMissing {
    param([string]$TargetFile, [string]$LinkPath)
    $parent = Split-Path -Parent $LinkPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    if (Test-Path -LiteralPath $LinkPath) { return }
    if (-not (Test-Path -LiteralPath $TargetFile)) { return }
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetFile -ErrorAction Stop | Out-Null
    } catch {
        Copy-Item -LiteralPath $TargetFile -Destination $LinkPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-DiscoveryMarkdown {
    param([string]$Audience = "generic")

    $header = switch ($Audience) {
        "freebuff" { "CRITICAL INSTRUCTION FOR FREEBUFF / CODEBUFF DESKTOP AND CLI" }
        "claude"   { "CRITICAL INSTRUCTION FOR CLAUDE CODE" }
        "gemini"   { "CRITICAL INSTRUCTION FOR GEMINI CLI" }
        "codex"    { "CRITICAL INSTRUCTION FOR OPENAI CODEX CLI" }
        "cursor"   { "CRITICAL INSTRUCTION FOR CURSOR" }
        "copilot"  { "CRITICAL INSTRUCTION FOR GITHUB COPILOT" }
        default    { "CRITICAL INSTRUCTION FOR ALL AI CODING AGENTS" }
    }

@"
# Global AI Agent Knowledge & Orchestration Index

$header

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
"@
}

# ------------------------------------------------------------------------------
# 3. Global rules (owned by this suite; regenerated each run)
# ------------------------------------------------------------------------------
$AutoRuleFile = Join-Path $RulesDir "00-auto-orchestrator.md"
Set-Content -Path $AutoRuleFile -Encoding UTF8 -Value @(
    '# Rule: Autonomous Agent Orchestration & Discovery Protocol',
    'Description: Always-on background protocol enabling the AI agent to automatically discover and apply skills, rules, sub-agents, hooks, and MCP tools without waiting for explicit slash commands.',
    '',
    '## 1. Automatic Context & Skill Routing (Pre-Response Phase):',
    'Before executing any complex coding, architecture, UI/UX, SEO, or security task, silently perform the following:',
    '- **Skill Matching**: Check `~/.agents/skills/` (or `.agents/skills/`) for relevant `SKILL.md` playbooks.',
    '- **Persona Adoption**: Check `~/.agents/agents/` and adopt the mindset of the most relevant specialist sub-agent.',
    '- **Rule Enforcement**: Always comply with active architectural and security constraints in `~/.agents/rules/`.',
    '- **MCP Utilization**: Proactively use configured MCP tools in `mcp.json` whenever external data or file manipulation is needed.',
    '',
    '## 2. Context Window Management:',
    '- Monitor conversation length. If context exceeds 75% capacity or a major milestone completes, automatically follow the `/CyrusAsha_Compact` protocol and log progress to `~/.agents/session-state.md`.',
    '',
    '## 3. Self-Verification:',
    '- Before finalizing code changes, verify compliance against loaded skills, linter rules, and security checklists.'
) | Out-Null
Write-Host "[OK] Rule: $AutoRuleFile" -ForegroundColor Cyan

$SecurityRuleFile = Join-Path $RulesDir "security-architect.md"
Set-Content -Path $SecurityRuleFile -Encoding UTF8 -Value @(
    '# Role: Senior Security & Software Architecture Lead',
    '',
    'When tasked with repository security review or generating standard repository documentation, assume the role of "Senior Security & Software Architecture Lead".',
    '',
    '### Core Responsibility:',
    'Inspect the root directory of the repository for the following 5 essential security and governance files:',
    '1. `SECURITY.md`',
    '2. `AGENTS.md`',
    '3. `.env.example`',
    '4. `THREAT-MODEL.md`',
    '5. `SECURITY-CHECKLIST.md`',
    '',
    '### Execution Protocol:',
    '1. Inspect the file tree and package manifest files.',
    '2. Report presence/absence status of each of the 5 files.',
    '3. For existing files: audit and propose improvements.',
    '4. For missing files: generate complete, production-ready, stack-tailored content.'
) | Out-Null
Write-Host "[OK] Rule: $SecurityRuleFile" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 4. Master instruction files in ~/.agents (managed-block update; never wipe extras)
# ------------------------------------------------------------------------------
$MasterKnowledge = Get-DiscoveryMarkdown -Audience "freebuff"
$MasterGeneric   = Get-DiscoveryMarkdown -Audience "generic"
$MasterClaude    = Get-DiscoveryMarkdown -Audience "claude"
$MasterGemini    = Get-DiscoveryMarkdown -Audience "gemini"
$MasterCodex     = Get-DiscoveryMarkdown -Audience "codex"

Update-ManagedBlock -FilePath (Join-Path $CentralDir "knowledge.md") -BlockLines @($MasterKnowledge)
Update-ManagedBlock -FilePath (Join-Path $CentralDir "AGENTS.md")    -BlockLines @($MasterGeneric)
Update-ManagedBlock -FilePath (Join-Path $CentralDir "CLAUDE.md")    -BlockLines @($MasterClaude)
Update-ManagedBlock -FilePath (Join-Path $CentralDir "GEMINI.md")    -BlockLines @($MasterGemini)
Update-ManagedBlock -FilePath (Join-Path $CentralDir "CODEX.md")     -BlockLines @($MasterCodex)

# Master Governance Templates in ~/.agents
$CentralSecurity = Join-Path $CentralDir "SECURITY.md"
if (-not (Test-Path -LiteralPath $CentralSecurity)) {
    Set-Content -Path $CentralSecurity -Encoding UTF8 -Value @(
        '# Security Policy',
        '',
        '## Supported Versions',
        '| Version | Supported | Status |',
        '| --- | :---: | --- |',
        '| 1.0.x | :white_check_mark: | Active (Current Master Edition) |',
        '| < 1.0.0 | :x: | Deprecated |',
        '',
        '## Reporting a Vulnerability',
        'Please report vulnerabilities responsibly to maintainers via private channels.',
        'Never open public issues for security vulnerabilities.'
    )
}

$CentralChecklist = Join-Path $CentralDir "SECURITY-CHECKLIST.md"
if (-not (Test-Path -LiteralPath $CentralChecklist)) {
    Set-Content -Path $CentralChecklist -Encoding UTF8 -Value @(
        '# Pre-Release & Deployment Security Checklist',
        '',
        '- [ ] No hardcoded secrets or production credentials in committed files.',
        '- [ ] .agents and local junction targets are listed in .gitignore.',
        '- [ ] Input validation and path sanitization applied to scripts.',
        '- [ ] Scripts tested with PSScriptAnalyzer with zero errors.'
    )
}

$CentralThreat = Join-Path $CentralDir "THREAT-MODEL.md"
if (-not (Test-Path -LiteralPath $CentralThreat)) {
    Set-Content -Path $CentralThreat -Encoding UTF8 -Value @(
        '# Threat Model (STRIDE Analysis)',
        '',
        '## 1. System Overview & Trust Boundaries',
        'Central repository (~/.agents) manages skills, rules, sub-agents, and MCP configurations across multi-agent environments.',
        '',
        '## 2. Key Mitigations',
        '- Managed-block non-destructive updates to prevent unauthorized file wipes.',
        '- Read-only junction structures in projects preventing recursive deletion.',
        '- Pinned shallow clones for third-party skill repositories.'
    )
}

$CentralContrib = Join-Path $CentralDir "CONTRIBUTING.md"
if (-not (Test-Path -LiteralPath $CentralContrib)) {
    Set-Content -Path $CentralContrib -Encoding UTF8 -Value @(
        '# Contributing Guidelines',
        '',
        'Contributions of new skills, rules, and agents are welcome.',
        'Ensure all scripts are idempotent, non-destructive, and free of hardcoded tokens.'
    )
}

Write-Host "[OK] Master instruction & governance files in $CentralDir" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 5. Slash commands
# ------------------------------------------------------------------------------
function Install-SlashCommands {
    param([string]$TargetCommandsDir = $CommandsDir)

    $commandDefinitions = @(
        @{
            Names = @("CyrusAsha_Auto.md", "auto.md")
            Content = @(
                '# Command: /CyrusAsha_Auto (alias: /auto)',
                'Description: Fully autonomous pipeline: Breaks goals into technical tasks, runs /CyrusAsha_Agents, /CyrusAsha_Skills, and /CyrusAsha_Rules logic in parallel, implements code, and performs security checks.',
                '',
                '## Protocol:',
                '1. Break objective into structured technical tasks.',
                '2. Automatically select expert persona from ~/.agents/agents/.',
                '3. Match and activate relevant playbooks from ~/.agents/skills/.',
                '4. Enforce security and architectural rules from ~/.agents/rules/.',
                '5. Leverage configured MCP tools from mcp.json when needed.',
                '6. Implement, test, lint, and run security verification before reporting.'
            )
        },
        @{
            Names = @("CyrusAsha_Skills.md", "skills.md")
            Content = @(
                '# Command: /CyrusAsha_Skills (alias: /skills)',
                'Description: Scan all installed global skills in ~/.agents/skills/, dynamically select relevant ones for the task, and execute a combined workflow.',
                '',
                '## Protocol:',
                '1. Index all SKILL.md playbooks in ~/.agents/skills/.',
                '2. Match user prompt and codebase stack against skill catalog.',
                '3. Load top 1-3 relevant skills (UI/UX, Backend, Security, SEO, TDD).',
                '4. Strictly follow the guidelines and patterns of loaded skills.'
            )
        },
        @{
            Names = @("CyrusAsha_Rules.md", "rules.md")
            Content = @(
                '# Command: /CyrusAsha_Rules (alias: /rules)',
                'Description: Scan and enforce all global project rules and architecture guidelines in ~/.agents/rules/ on the current codebase.',
                '',
                '## Protocol:',
                '1. Index all rule files in ~/.agents/rules/.',
                '2. Audit current codebase against 00-auto-orchestrator.md and security-architect.md.',
                '3. Report violations and refactor code for 100% compliance.'
            )
        },
        @{
            Names = @("CyrusAsha_Agents.md", "agents.md")
            Content = @(
                '# Command: /CyrusAsha_Agents (alias: /agents)',
                'Description: Scan, list, and delegate tasks to specialized sub-agents defined in ~/.agents/agents/.',
                '',
                '## Protocol:',
                '1. Index all persona files in ~/.agents/agents/.',
                '2. If requested, list all specialist personas with their domains.',
                '3. Select the best expert persona for current task and adopt that mindset.'
            )
        },
        @{
            Names = @("CyrusAsha_Audit-Security.md", "audit-security.md")
            Content = @(
                '# Command: /CyrusAsha_Audit-Security (alias: /audit-security)',
                'Description: Perform a full Senior Security Architect audit and create or complete the 5 standard governance files.',
                '',
                '## Protocol:',
                '1. Check repository root for: SECURITY.md, AGENTS.md, .env.example, THREAT-MODEL.md, SECURITY-CHECKLIST.md.',
                '2. Inspect stack, manifests, and dependencies.',
                '3. Present present/missing status table.',
                '4. Generate production-ready content for missing or inadequate files.'
            )
        },
        @{
            Names = @("CyrusAsha_Compact.md", "compact.md")
            Content = @(
                '# Command: /CyrusAsha_Compact (alias: /compact)',
                'Description: Compress conversation context, run pre-compact hook, and save state to ~/.agents/session-state.md.',
                '',
                '## Protocol:',
                '1. Run pre-compact.ps1 hook if present.',
                '2. Summarize goals, decisions, modified files, and next steps.',
                '3. Append checkpoint to ~/.agents/session-state.md.',
                '4. Retain only core rules, active skills, and checkpoint summary.'
            )
        },
        @{
            Names = @("CyrusAsha_Hooks.md", "hooks.md")
            Content = @(
                '# Command: /CyrusAsha_Hooks (alias: /hooks)',
                'Description: Manage, inspect, and trigger global lifecycle hooks located in ~/.agents/hooks/.',
                '',
                '## Protocol:',
                '1. List all scripts in ~/.agents/hooks/.',
                '2. Report trigger events, execution mode, and status.',
                '3. Safely execute a specified hook on demand.'
            )
        },
        @{
            Names = @("CyrusAsha_Commands.md", "commands.md")
            Content = @(
                '# Command: /CyrusAsha_Commands (alias: /commands)',
                'Description: Display an index and cheat-sheet of all available custom slash commands in ~/.agents/commands/.',
                '',
                '## Available Slash Commands:',
                '| Command | Alias | Purpose |',
                '| :--- | :--- | :--- |',
                '| `/CyrusAsha_Auto` | `/auto` | Fully autonomous end-to-end execution pipeline |',
                '| `/CyrusAsha_Skills` | `/skills` | Dynamically load relevant skills from skills/ |',
                '| `/CyrusAsha_Rules` | `/rules` | Scan and enforce global project rules |',
                '| `/CyrusAsha_Agents` | `/agents` | Delegate tasks to specialist sub-agents |',
                '| `/CyrusAsha_Audit-Security` | `/audit-security` | Security audit & 5 governance files |',
                '| `/CyrusAsha_Compact` | `/compact` | Save checkpoint & compact context |',
                '| `/CyrusAsha_Hooks` | `/hooks` | Inspect & run lifecycle hooks |',
                '| `/CyrusAsha_Commands` | `/commands` | Display cheat-sheet & recommendations |'
            )
        }
    )

    foreach ($cmd in $commandDefinitions) {
        foreach ($filename in $cmd.Names) {
            $cmdPath = Join-Path $TargetCommandsDir $filename
            Set-Content -Path $cmdPath -Value $cmd.Content -Encoding UTF8
        }
    }
}

Install-SlashCommands -TargetCommandsDir $CommandsDir
Write-Host "[OK] Slash commands in $CommandsDir" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 6. Lifecycle hook
# ------------------------------------------------------------------------------
$PreCompactHookFile = Join-Path $HooksDir "pre-compact.ps1"
if (-not (Test-Path -LiteralPath $PreCompactHookFile)) {
    Set-Content -Path $PreCompactHookFile -Encoding UTF8 -Value @(
        'param ([string]$SessionId = "default")',
        '$StateFile = Join-Path $env:USERPROFILE ".agents\session-state.md"',
        '$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"',
        '$StateHeader = "<!-- Session State Checkpoint - $Timestamp | Session: $SessionId -->"',
        'Add-Content -Path $StateFile -Value $StateHeader -Encoding UTF8'
    )
}

# ------------------------------------------------------------------------------
# 7. mcp.json (create only if missing - never overwrite user secrets)
# ------------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $McpFile)) {
    $DefaultMcp = @'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:\\Projects"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "YOUR_BRAVE_SEARCH_API_KEY_HERE" }
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest", "--access-token", "YOUR_SUPABASE_PAT_TOKEN_HERE"]
    },
    "duckdb": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-duckdb", "C:\\Data\\local_database.duckdb"]
    },
    "google-search-console": {
      "command": "npx",
      "args": ["-y", "@aminforou/mcp-gsc"],
      "env": {
        "GSC_CLIENT_EMAIL": "YOUR_GSC_CLIENT_EMAIL_HERE",
        "GSC_PRIVATE_KEY": "YOUR_GSC_PRIVATE_KEY_HERE"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}
'@
    Set-Content -Path $McpFile -Value $DefaultMcp -Encoding UTF8
    Write-Host "[OK] Created central mcp.json (fill in your tokens)." -ForegroundColor Cyan
} else {
    Write-Host "[SKIP] mcp.json already exists - left untouched." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# 8. Sync skill & agent repositories (optional, requires git)
# ------------------------------------------------------------------------------
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "`n[FETCH] Downloading and updating skill repositories..." -ForegroundColor Yellow
    $ReposList = @(
        @{ Name = "everything-claude-code";         Url = "https://github.com/WorldFlowAI/everything-claude-code.git" },
        @{ Name = "taste-skill";                    Url = "https://github.com/Leonxlnx/taste-skill.git" },
        @{ Name = "ui-ux-pro-max-skill";            Url = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git" },
        @{ Name = "tastecode";                      Url = "https://github.com/vishalx0707/tastecode.git" },
        @{ Name = "Anthropic-Cybersecurity-Skills"; Url = "https://github.com/mukul975/Anthropic-Cybersecurity-Skills.git" },
        @{ Name = "Claude-Code-SEO-skills";         Url = "https://github.com/VibeWithClaude/Claude-Code-SEO-skills.git" },
        @{ Name = "geo-optimizer-skill";            Url = "https://github.com/Auriti-Labs/geo-optimizer-skill.git" },
        @{ Name = "claude-seo";                     Url = "https://github.com/AgriciDaniel/claude-seo.git" },
        @{ Name = "strix";                          Url = "https://github.com/usestrix/strix.git" },
        @{ Name = "ruflo";                          Url = "https://github.com/ruvnet/ruflo.git" },
        @{ Name = "agency-agents";                  Url = "https://github.com/msitarzewski/agency-agents.git" },
        @{ Name = "deer-flow";                      Url = "https://github.com/bytedance/deer-flow.git" },
        @{ Name = "diagram-design";                 Url = "https://github.com/cathrynlavery/diagram-design.git" },
        @{ Name = "awesome-claude-design";          Url = "https://github.com/VoltAgent/awesome-claude-design.git" },
        @{ Name = "skills-emilkowalski";            Url = "https://github.com/emilkowalski/skills.git" },
        @{ Name = "img2threejs";                    Url = "https://github.com/img2threejs/img2threejs.git" },
        @{ Name = "Agent-Memory";                   Url = "https://github.com/Threesided-Studios/Agent-Memory.git" },
        @{ Name = "OpenViking";                     Url = "https://github.com/volcengine/OpenViking.git" },
        @{ Name = "browser-use";                    Url = "https://github.com/browser-use/browser-use.git" },
        @{ Name = "agent-reach";                    Url = "https://github.com/EdisonChenAI/agent-reach.git" },
        @{ Name = "Scrapegraph-ai";                 Url = "https://github.com/ScrapeGraphAI/Scrapegraph-ai.git" },
        @{ Name = "awesome-harness-engineering";    Url = "https://github.com/yenanjing/awesome-harness-engineering.git" }
    )
    foreach ($Repo in $ReposList) {
        $TempRepoDir = Join-Path $env:TEMP $Repo.Name
        try {
            if (Test-Path (Join-Path $TempRepoDir ".git")) {
                Write-Host "  -> Updating: $($Repo.Name)..." -ForegroundColor Cyan
                git -C $TempRepoDir pull --quiet
            } else {
                if (Test-Path $TempRepoDir) { Remove-Item -Recurse -Force $TempRepoDir }
                Write-Host "  -> Cloning: $($Repo.Name)..." -ForegroundColor Cyan
                git clone --depth 1 --quiet $Repo.Url $TempRepoDir
            }
            foreach ($sub in @("skills", "rules", "agents", "commands", "hooks")) {
                $src = Join-Path $TempRepoDir $sub
                if (Test-Path $src) {
                    $dest = Join-Path $CentralDir $sub
                    Copy-Item -Recurse -Force "$src\*" $dest -ErrorAction SilentlyContinue
                }
            }
            if (Test-Path (Join-Path $TempRepoDir "SKILL.md")) {
                $DestFolder = Join-Path $SkillsDir $Repo.Name
                New-Item -ItemType Directory -Force -Path $DestFolder | Out-Null
                Copy-Item -Recurse -Force -Path "$TempRepoDir\*" -Destination $DestFolder -Exclude ".git" -ErrorAction SilentlyContinue
            }
        } catch {
            Write-Host "  [WARN] $($Repo.Name): $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }
} else {
    Write-Host "[WARN] git not found on PATH - skipped repository fetch." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# 8.5. Collect resources from existing agent installations into central .agents
#    (Gathers skills/rules/agents/commands/hooks/mcp.json from known agent homes)
# ------------------------------------------------------------------------------
Write-Host "`n[COLLECT] Gathering existing resources from installed AI agents into ~/.agents..." -ForegroundColor Yellow

$CollectSources = @(
    (Join-Path $env:USERPROFILE ".freebuff"),
    (Join-Path $env:USERPROFILE ".codebuff"),
    (Join-Path $env:APPDATA     "freebuff"),
    (Join-Path $env:LOCALAPPDATA "freebuff"),
    (Join-Path $env:USERPROFILE ".claude"),
    (Join-Path $env:USERPROFILE ".cursor"),
    (Join-Path $env:USERPROFILE ".codex"),
    (Join-Path $env:USERPROFILE ".gemini"),
    (Join-Path $env:USERPROFILE ".windsurf"),
    (Join-Path $env:USERPROFILE ".cline"),
    (Join-Path $env:USERPROFILE ".roo"),
    (Join-Path $env:USERPROFILE ".continue"),
    (Join-Path $env:USERPROFILE ".amazonq"),
    (Join-Path $env:USERPROFILE ".trae"),
    (Join-Path $env:USERPROFILE ".hermes"),
    (Join-Path $env:USERPROFILE ".config\opencode"),
    (Join-Path $env:USERPROFILE ".antigravity"),
    (Join-Path $env:USERPROFILE ".copilot")
) | Select-Object -Unique

$CollectSubDirs = @("skills", "rules", "agents", "commands", "hooks")

foreach ($SourceBase in $CollectSources) {
    if (-not (Test-Path -LiteralPath $SourceBase)) { continue }
    Write-Host "  -> Scanning: $SourceBase" -ForegroundColor Cyan

    foreach ($sub in $CollectSubDirs) {
        $SrcSub = Join-Path $SourceBase $sub
        $DstSub = Join-Path $CentralDir $sub
        if (Test-Path -LiteralPath $SrcSub) {
            Copy-Item -Recurse -Force "$SrcSub\*" $DstSub -ErrorAction SilentlyContinue
        }
    }

    $SrcMcp = Join-Path $SourceBase "mcp.json"
    if (Test-Path -LiteralPath $SrcMcp -PathType Leaf) {
        if (-not (Test-Path -LiteralPath $McpFile)) {
            Copy-Item -LiteralPath $SrcMcp -Destination $McpFile -Force -ErrorAction SilentlyContinue
            Write-Host "    [COPIED] mcp.json from $SourceBase" -ForegroundColor DarkGray
        }
    }

    # Also collect knowledge.md / AGENTS.md / CLAUDE.md / GEMINI.md if present
    foreach ($fname in @("knowledge.md", "AGENTS.md", "CLAUDE.md", "GEMINI.md", "CODEX.md")) {
        $SrcFile = Join-Path $SourceBase $fname
        if (Test-Path -LiteralPath $SrcFile -PathType Leaf) {
            $DstFile = Join-Path $CentralDir $fname
            if (-not (Test-Path -LiteralPath $DstFile)) {
                Copy-Item -LiteralPath $SrcFile -Destination $DstFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Write-Host "[OK] Resource collection complete." -ForegroundColor Cyan

# Re-apply CyrusAsha slash commands to guarantee they are never overwritten by cloned repos
Install-SlashCommands -TargetCommandsDir $CommandsDir

# ------------------------------------------------------------------------------
# 9. Link central tree into known agent home directories
# ------------------------------------------------------------------------------
Write-Host "`n[LINK] Attaching ~/.agents to known agent homes..." -ForegroundColor Yellow

$AgentHomes = @(
    (Join-Path $env:USERPROFILE ".hermes"),
    (Join-Path $env:USERPROFILE ".config\opencode"),
    (Join-Path $env:USERPROFILE ".opencode"),
    (Join-Path $env:USERPROFILE ".antigravity"),
    (Join-Path $env:USERPROFILE ".copilot"),
    (Join-Path $env:USERPROFILE ".freebuff"),
    (Join-Path $env:USERPROFILE ".codebuff"),
    (Join-Path $env:APPDATA     "freebuff"),
    (Join-Path $env:LOCALAPPDATA "freebuff"),
    (Join-Path $env:APPDATA     "Freebuff"),
    (Join-Path $env:LOCALAPPDATA "Programs\freebuff"),
    (Join-Path $env:APPDATA     "codebuff"),
    (Join-Path $env:LOCALAPPDATA "codebuff"),
    (Join-Path $env:USERPROFILE ".claude"),
    (Join-Path $env:USERPROFILE ".cursor"),
    (Join-Path $env:USERPROFILE ".codex"),
    (Join-Path $env:USERPROFILE ".config\codex"),
    (Join-Path $env:USERPROFILE ".gemini"),
    (Join-Path $env:USERPROFILE ".config\gemini"),
    (Join-Path $env:USERPROFILE ".windsurf"),
    (Join-Path $env:USERPROFILE ".codeium"),
    (Join-Path $env:USERPROFILE ".continue"),
    (Join-Path $env:USERPROFILE ".cline"),
    (Join-Path $env:USERPROFILE ".roo"),
    (Join-Path $env:USERPROFILE ".goose"),
    (Join-Path $env:USERPROFILE ".amazonq"),
    (Join-Path $env:USERPROFILE ".trae"),
    (Join-Path $env:USERPROFILE ".aider"),
    (Join-Path $env:APPDATA     "Cursor"),
    (Join-Path $env:APPDATA     "Codeium\Windsurf")
) | Select-Object -Unique

foreach ($AgentBase in $AgentHomes) {
    Set-DirectoryJunction     -Target $SkillsDir   -LinkPath (Join-Path $AgentBase "skills")
    Set-DirectoryJunction     -Target $RulesDir    -LinkPath (Join-Path $AgentBase "rules")
    Set-DirectoryJunction     -Target $AgentsDir   -LinkPath (Join-Path $AgentBase "agents")
    Set-DirectoryJunction     -Target $CommandsDir -LinkPath (Join-Path $AgentBase "commands")
    Set-DirectoryJunction     -Target $HooksDir    -LinkPath (Join-Path $AgentBase "hooks")
    Set-FileSymlinkIfMissing  -TargetFile $McpFile -LinkPath (Join-Path $AgentBase "mcp.json")
}

# Instruction files inside agent homes: inject pointer, never wipe user memory
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".claude\CLAUDE.md") -BlockLines @($MasterClaude)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".codex\AGENTS.md")  -BlockLines @($MasterCodex)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".codex\instructions.md") -BlockLines @($MasterCodex)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".gemini\GEMINI.md") -BlockLines @($MasterGemini)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".freebuff\knowledge.md") -BlockLines @($MasterKnowledge)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".codebuff\knowledge.md") -BlockLines @($MasterKnowledge)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".freebuff\AGENTS.md") -BlockLines @($MasterGeneric)
Update-ManagedBlock -FilePath (Join-Path $env:USERPROFILE ".codebuff\AGENTS.md") -BlockLines @($MasterGeneric)

if ($env:APPDATA) {
    Update-ManagedBlock -FilePath (Join-Path $env:APPDATA "freebuff\knowledge.md") -BlockLines @($MasterKnowledge)
    Update-ManagedBlock -FilePath (Join-Path $env:APPDATA "freebuff\AGENTS.md")    -BlockLines @($MasterGeneric)
    Update-ManagedBlock -FilePath (Join-Path $env:APPDATA "codebuff\knowledge.md") -BlockLines @($MasterKnowledge)
    Update-ManagedBlock -FilePath (Join-Path $env:APPDATA "codebuff\AGENTS.md")    -BlockLines @($MasterGeneric)
}

# ------------------------------------------------------------------------------
# 10. Remove leftover v6.x Explorer context-menu (user requested NO right-click)
# ------------------------------------------------------------------------------
Write-Host "`n[CLEANUP] Removing Explorer context-menu leftovers (if any)..." -ForegroundColor Yellow
foreach ($key in @(
    "HKCU:\Software\Classes\Directory\shell\LinkGlobalAIAgents",
    "HKCU:\Software\Classes\Directory\Background\shell\LinkGlobalAIAgents"
)) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ("  [REMOVED] " + $key) -ForegroundColor DarkGray
    }
}

# ------------------------------------------------------------------------------
# 11. Write init-project-files.ps1 (the global command implementation)
# ------------------------------------------------------------------------------
$InitScriptPath = Join-Path $CentralDir "init-project-files.ps1"

$InitScript = @'
#Requires -Version 5.1
<#
.SYNOPSIS
    Create or update AI-agent files in a project. Never deletes existing content.

.DESCRIPTION
    Desktop apps (Freebuff, Codebuff) and many CLIs (Codex, Claude Code, Gemini,
    Cursor, Copilot) do not read %USERPROFILE%\.agents when you open a folder from
    the GUI. They read files in the project root. This command:

      1. Junctions  <project>\.agents  ->  %USERPROFILE%\.agents   (if missing)
      2. Creates or UPDATES AGENTS.md, knowledge.md, CLAUDE.md, GEMINI.md
         using a marked block. Anything you wrote outside that block is kept.
      3. Points every agent at .agents/rules, .agents/skills, .agents/mcp.json
      4. Appends .agents/ to .gitignore
      5. Ensures governance files (SECURITY.md, SECURITY-CHECKLIST.md, THREAT-MODEL.md,
         CONTRIBUTING.md, .env.example) exist and are stack-tailored.

.PARAMETER Path
    Project root. Defaults to the current directory.

.PARAMETER Full
    Also write extra adapters: .cursorrules, .clinerules, .windsurfrules,
    CONVENTIONS.md, .github/copilot-instructions.md, .cursor/rules/*.mdc

.EXAMPLE
    Initialize-AgentWorkspace
.EXAMPLE
    agents-init
.EXAMPLE
    ai-init
.EXAMPLE
    init-needed-files D:\MyHdd\VS-Project\MyApp
.EXAMPLE
    Initialize-AgentWorkspace -Path . -Full
#>
function Initialize-AgentWorkspace {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = (Get-Location).Path,

        [switch]$Full
    )

    $ErrorActionPreference = 'Continue'
    $StartMarker = '<!-- GLOBAL-AI-AGENTS:START -->'
    $EndMarker   = '<!-- GLOBAL-AI-AGENTS:END -->'
    $HashStart   = '# >>> GLOBAL-AI-AGENTS-START >>>'
    $HashEnd     = '# <<< GLOBAL-AI-AGENTS-END <<<'

    try {
        $ProjectPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    } catch {
        Write-Host ('[ERROR] Path not found: ' + $Path) -ForegroundColor Red
        return
    }

    $CentralDir = Join-Path $env:USERPROFILE '.agents'
    if (-not (Test-Path -LiteralPath $CentralDir)) {
        Write-Host ('[ERROR] Central directory missing: ' + $CentralDir) -ForegroundColor Red
        Write-Host '        Run setup-global-agents.ps1 first.' -ForegroundColor Red
        return
    }

    Write-Host ('[INIT] Project: ' + $ProjectPath) -ForegroundColor Green

    function Get-GaDiscovery {
        param([string]$Audience = 'generic')
        $header = switch ($Audience) {
            'freebuff' { 'CRITICAL INSTRUCTION FOR FREEBUFF / CODEBUFF DESKTOP AND CLI' }
            'claude'   { 'CRITICAL INSTRUCTION FOR CLAUDE CODE' }
            'gemini'   { 'CRITICAL INSTRUCTION FOR GEMINI CLI' }
            'codex'    { 'CRITICAL INSTRUCTION FOR OPENAI CODEX CLI' }
            'cursor'   { 'CRITICAL INSTRUCTION FOR CURSOR' }
            'copilot'  { 'CRITICAL INSTRUCTION FOR GITHUB COPILOT' }
            default    { 'CRITICAL INSTRUCTION FOR ALL AI CODING AGENTS' }
        }
        return @(
            '# Global AI Agent Knowledge & Orchestration Index',
            '',
            $header,
            '',
            'This workspace is connected to the central AI agent directory:',
            '',
            '- **Project path:** `.agents/`  (junction created by Initialize-AgentWorkspace)',
            '- **User path:** `%USERPROFILE%\.agents`  (`~/.agents`)',
            '',
            'Desktop apps such as **Freebuff** and **Codebuff** do not read the user-level folder',
            'when a project is opened via Open Folder. They DO read files in the project root.',
            'That is why this file exists: it points you at `.agents/`.',
            '',
            '## Mandatory pre-execution steps',
            '',
            'Before planning, coding, refactoring, UI/UX, SEO, or security work, silently:',
            '',
            '1. Read and enforce `.agents/rules/00-auto-orchestrator.md`',
            '2. Read and enforce `.agents/rules/security-architect.md`',
            '3. Scan `.agents/skills/` and load the most relevant `SKILL.md` playbooks',
            '4. Adopt a specialist persona from `.agents/agents/` when the domain is specific',
            '5. Use MCP servers from `.agents/mcp.json`',
            '6. Honor slash-command playbooks in `.agents/commands/`:',
            '   `/CyrusAsha_Auto` `/CyrusAsha_Skills` `/CyrusAsha_Rules` `/CyrusAsha_Agents` `/CyrusAsha_Hooks` `/CyrusAsha_Commands` `/CyrusAsha_Audit-Security` `/CyrusAsha_Compact` ',
            '',
            'If `.agents/` is missing, run in PowerShell from the project root:',
            '',
            '    Initialize-AgentWorkspace',
            '    # aliases: agents-init    ai-init    init-agents    init-needed-files',
            '',
            'Do not ignore this index. Treat `.agents/` as the single source of truth.'
        ) -join "`r`n"
    }

    function Get-GaProjectOperatingGuide {
        param([string]$TargetProjectPath)
        $projName = Split-Path -Leaf $TargetProjectPath
        $isConfigurator = (Test-Path (Join-Path $TargetProjectPath 'CyrusAsha_GlobalAgents.ps1')) -or ($projName -like '*CyrusAsha*')
        $isNode = Test-Path (Join-Path $TargetProjectPath 'package.json')
        $isPython = (Test-Path (Join-Path $TargetProjectPath 'requirements.txt')) -or (Test-Path (Join-Path $TargetProjectPath 'pyproject.toml'))
        $isDotNet = (Get-ChildItem -Path $TargetProjectPath -Filter '*.sln' -ErrorAction SilentlyContinue).Count -gt 0 -or (Get-ChildItem -Path $TargetProjectPath -Filter '*.csproj' -ErrorAction SilentlyContinue).Count -gt 0
        $isRust = Test-Path (Join-Path $TargetProjectPath 'Cargo.toml')
        $isGo = Test-Path (Join-Path $TargetProjectPath 'go.mod')

        if ($isConfigurator) {
            return @(
                '',
                ('# 🤖 Project Operating Guide: ' + $projName),
                '',
                ('This workspace contains **Global AI Agent Configurator for Windows** (`' + $projName + '`), linking 19+ AI coding assistants (Antigravity, Cursor, Claude Code, Gemini CLI, Copilot, Freebuff, Windsurf, Cline, Roo, Continue, etc.) to a centralized configuration repository located at `%USERPROFILE%\.agents`.'),
                '',
                '## 1. Project Architecture & Components',
                '- `CyrusAsha_GlobalAgents.ps1`: Primary orchestrator (Junctions, repo sync, slash commands, profile hooks).',
                '- `CyrusAsha_SetupGlobalAgents.cmd`: Bootstrap launcher with execution policy bypass.',
                '- `init-project-files.ps1`: Workspace initializer command (`Initialize-AgentWorkspace`).',
                '- `.agents/`: NTFS Directory Junction pointing to `%USERPROFILE%\.agents` (0 bytes physical disk storage).',
                '- Governance Files: `SECURITY.md`, `SECURITY-CHECKLIST.md`, `THREAT-MODEL.md`, `CONTRIBUTING.md`, `.env.example`.',
                '',
                '## 2. Agent Operating Guidelines',
                '- **Strict Idempotency**: All PowerShell commands must be safe to re-run without duplicate entries.',
                '- **Non-Destructive Overwrites**: Strictly use managed comment blocks (`Update-ManagedBlock`) to preserve user content.',
                '- **Junction Safety**: Always verify junction existence before creation. Never delete target trees during cleanup.',
                '- **Dual Command Naming**: Slash commands must be deployed as both `CyrusAsha_<Name>.md` and `<name>.md`.',
                '- **Zero Secrets**: All tokens in templates must remain placeholder mock strings (`YOUR_*_TOKEN_HERE`).',
                '',
                '## 3. Verification & Quality Gates',
                '- **PSScriptAnalyzer**: Run `Invoke-ScriptAnalyzer -Path .\ -Recurse -Severity Error, Warning`',
                '- **Junction Verification**: Run `(Get-Item .agents).LinkType -eq ''Junction''`'
            ) -join "`r`n"
        }

        $stackDesc = if ($isNode) { 'Node.js / TypeScript' } elseif ($isPython) { 'Python' } elseif ($isDotNet) { '.NET / C#' } elseif ($isRust) { 'Rust' } elseif ($isGo) { 'Go' } else { 'General Software' }

        return @(
            '',
            ('# 🤖 Project Operating Guide: ' + $projName),
            '',
            ('Welcome AI Assistant. You are working on **' + $projName + '** (' + $stackDesc + ').'),
            '',
            '## 1. Project Overview & Architecture',
            ('- Workspace Path: `' + $TargetProjectPath + '`'),
            ('- Primary Stack: ' + $stackDesc),
            '- Central AI Config: Linked via `.agents/` to `%USERPROFILE%\.agents`.',
            '',
            '## 2. Operating Guidelines for AI Agents',
            '- **Rule Compliance**: Enforce all project rules in `.agents/rules/` before modifying code.',
            '- **Skill Usage**: Check `.agents/skills/` for relevant architecture, UI/UX, security, and testing playbooks.',
            '- **Security First**: Review `SECURITY.md`, `SECURITY-CHECKLIST.md`, and `THREAT-MODEL.md` before making architectural changes.',
            '- **Clean Commits**: Ensure `.agents/`, local `.env` secrets, and temporary build files are never staged.'
        ) -join "`r`n"
    }

    function Update-GaMarkedSection {
        param(
            [string]$FilePath,
            [string]$Content,
            [string]$Start = $StartMarker,
            [string]$End   = $EndMarker,
            [string]$DefaultGuide = ''
        )
        $block  = $Start + "`r`n" + $Content.TrimEnd() + "`r`n" + $End
        $parent = Split-Path -Parent $FilePath
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        if (-not (Test-Path -LiteralPath $FilePath)) {
            $initialBody = $block + "`r`n"
            if (-not [string]::IsNullOrWhiteSpace($DefaultGuide)) {
                $initialBody += "`r`n" + $DefaultGuide.Trim() + "`r`n"
            }
            Set-Content -Path $FilePath -Value $initialBody -Encoding UTF8 -NoNewline
            Write-Host ('  [NEW]    ' + $FilePath) -ForegroundColor DarkGray
            return
        }
        $existing = $null
        try { $existing = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8 -ErrorAction Stop }
        catch { $existing = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue }
        if ([string]::IsNullOrEmpty($existing)) {
            $initialBody = $block + "`r`n"
            if (-not [string]::IsNullOrWhiteSpace($DefaultGuide)) {
                $initialBody += "`r`n" + $DefaultGuide.Trim() + "`r`n"
            }
            Set-Content -Path $FilePath -Value $initialBody -Encoding UTF8 -NoNewline
            Write-Host ('  [UPDATE] ' + $FilePath) -ForegroundColor DarkGray
            return
        }
        $pattern = '(?s)' + [regex]::Escape($Start) + '.*?' + [regex]::Escape($End)
        $match   = [regex]::Match($existing, $pattern)
        if ($match.Success) {
            $before = $existing.Substring(0, $match.Index)
            $after  = $existing.Substring($match.Index + $match.Length)
            if ([string]::IsNullOrWhiteSpace($before) -and [string]::IsNullOrWhiteSpace($after) -and (-not [string]::IsNullOrWhiteSpace($DefaultGuide))) {
                $updated = $block + "`r`n`r`n" + $DefaultGuide.Trim() + "`r`n"
            } else {
                $updated = $before + $block + $after
            }
            Write-Host ('  [UPDATE] ' + $FilePath) -ForegroundColor DarkGray
        } else {
            $updated = $existing.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
            Write-Host ('  [APPEND] ' + $FilePath) -ForegroundColor DarkGray
        }
        Set-Content -Path $FilePath -Value $updated -Encoding UTF8 -NoNewline
    }

    # 1) Junction .agents -> ~/.agents  (skip if anything already exists there)
    $LocalAgents = Join-Path $ProjectPath '.agents'
    if (-not (Test-Path -LiteralPath $LocalAgents)) {
        $linked = $false
        try {
            New-Item -ItemType Junction -Path $LocalAgents -Target $CentralDir -ErrorAction Stop | Out-Null
            $linked = $true
        } catch {
            cmd /c mklink /J "`"$LocalAgents`"" "`"$CentralDir`"" > $null 2>&1
            $linked = Test-Path -LiteralPath $LocalAgents
        }
        if ($linked) {
            Write-Host ('  [LINK]   ' + $LocalAgents + '  ->  ' + $CentralDir) -ForegroundColor DarkGray
        } else {
            Write-Host '  [WARN]   Could not create .agents junction (Developer Mode / permissions).' -ForegroundColor DarkYellow
        }
    } else {
        Write-Host ('  [KEEP]   ' + $LocalAgents + ' (already exists, left untouched)') -ForegroundColor DarkGray
    }

    # 2) Root instruction files that GUI apps actually open (with tailored project operating guides)
    $ProjectOperatingGuide = Get-GaProjectOperatingGuide -TargetProjectPath $ProjectPath
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'AGENTS.md')    -Content (Get-GaDiscovery -Audience 'generic') -DefaultGuide $ProjectOperatingGuide
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'knowledge.md') -Content (Get-GaDiscovery -Audience 'freebuff') -DefaultGuide $ProjectOperatingGuide
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'CLAUDE.md')    -Content (Get-GaDiscovery -Audience 'claude')   -DefaultGuide $ProjectOperatingGuide
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'GEMINI.md')    -Content (Get-GaDiscovery -Audience 'gemini')   -DefaultGuide $ProjectOperatingGuide

    # Cursor rule (lives in a subfolder - low clutter)
    $cursorRule = @(
        '---',
        'description: Discover the central .agents configuration (skills, rules, MCP)',
        'alwaysApply: true',
        '---',
        '',
        (Get-GaDiscovery -Audience 'cursor')
    ) -join "`r`n"
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.cursor\rules\global-agents.mdc') -Content $cursorRule

    # GitHub Copilot custom instructions
    Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.github\copilot-instructions.md') -Content (Get-GaDiscovery -Audience 'copilot')

    if ($Full) {
        $hashBody = (Get-GaDiscovery -Audience 'generic') -replace '(?m)^', '# '
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.cursorrules')    -Content $hashBody -Start $HashStart -End $HashEnd
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.clinerules')     -Content $hashBody -Start $HashStart -End $HashEnd
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.windsurfrules')  -Content $hashBody -Start $HashStart -End $HashEnd
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'CONVENTIONS.md')  -Content (Get-GaDiscovery -Audience 'generic')
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath 'CODEX.md')        -Content (Get-GaDiscovery -Audience 'codex')
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.codex\AGENTS.md') -Content (Get-GaDiscovery -Audience 'codex')
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.roo\rules\global-agents.md') -Content (Get-GaDiscovery -Audience 'generic')
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.continue\rules\global-agents.md') -Content (Get-GaDiscovery -Audience 'generic')
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.goosehints') -Content $hashBody -Start $HashStart -End $HashEnd
        Update-GaMarkedSection -FilePath (Join-Path $ProjectPath '.aider.conf.yml') -Content @(
            '# Aider reads CONVENTIONS.md; this flag keeps it explicit.',
            'read: CONVENTIONS.md'
        ) -join "`r`n" -Start $HashStart -End $HashEnd
    }

    # 3) .gitignore - append .agents/ only, never rewrite the file
    $giPath = Join-Path $ProjectPath '.gitignore'
    if (-not (Test-Path -LiteralPath $giPath)) {
        Set-Content -Path $giPath -Value "# Local junction to %USERPROFILE%.agents - do not commit the linked tree`r`n.agents/`r`n" -Encoding UTF8 -NoNewline
        Write-Host ('  [NEW]    ' + $giPath) -ForegroundColor DarkGray
    } else {
        $giText = Get-Content -LiteralPath $giPath -Raw -ErrorAction SilentlyContinue
        if ($giText -notmatch '(?m)^\s*\.agents/\s*$') {
            Add-Content -Path $giPath -Value "`r`n# Local junction to %USERPROFILE%.agents - do not commit the linked tree`r`n.agents/" -Encoding UTF8 -NoNewline
            Write-Host ('  [APPEND] ' + $giPath + '  (+ .agents/)') -ForegroundColor DarkGray
        } else {
            Write-Host ('  [KEEP]   ' + $giPath + ' (already ignores .agents/)') -ForegroundColor DarkGray
        }
    }

    # 4) Project Governance & Security Files (SECURITY.md, SECURITY-CHECKLIST.md, THREAT-MODEL.md, CONTRIBUTING.md, .env.example)
    $govFiles = @(
        @{
            Name = 'SECURITY.md'
            Default = @(
                '# Security Policy',
                '',
                '## Supported Versions',
                '| Version | Supported | Status |',
                '| --- | :---: | --- |',
                '| 1.0.x | :white_check_mark: | Active |',
                '',
                '## Reporting a Vulnerability',
                'Please report vulnerabilities responsibly to maintainers via private channels.',
                'Do not open public issues for security vulnerabilities.'
            ) -join "`r`n"
        },
        @{
            Name = 'SECURITY-CHECKLIST.md'
            Default = @(
                '# Pre-Release & Deployment Security Checklist',
                '- [ ] No hardcoded secrets or credentials committed.',
                '- [ ] Local .agents junction excluded from git tracking via .gitignore.',
                '- [ ] Safe input validation and parameter sanitization.',
                '- [ ] Linting and security tests executed with zero critical errors.'
            ) -join "`r`n"
        },
        @{
            Name = 'THREAT-MODEL.md'
            Default = @(
                '# Threat Model (STRIDE Analysis)',
                '## 1. System Overview & Trust Boundaries',
                'Multi-agent development environment connected to central configuration.',
                '## 2. Key Mitigations',
                '- Non-destructive managed blocks for user file updates.',
                '- Centralized credential handling and strict .gitignore enforcement.'
            ) -join "`r`n"
        },
        @{
            Name = 'CONTRIBUTING.md'
            Default = @(
                '# Contributing Guidelines',
                'Contributions of new skills, rules, and agents are welcome.',
                'Ensure all additions are idempotent, tested, and follow project standards.'
            ) -join "`r`n"
        },
        @{
            Name = '.env.example'
            Default = @(
                '# Environment Template',
                '# Safe mock values only - never commit real secrets',
                'API_KEY="mock_key_0000000000000000"'
            ) -join "`r`n"
        }
    )

    foreach ($gf in $govFiles) {
        $targetPath = Join-Path $ProjectPath $gf.Name
        if (-not (Test-Path -LiteralPath $targetPath)) {
            Set-Content -Path $targetPath -Value ($gf.Default.Trim() + "`r`n") -Encoding UTF8 -NoNewline
            Write-Host ('  [NEW]    ' + $targetPath) -ForegroundColor DarkGray
        } else {
            Write-Host ('  [KEEP]   ' + $targetPath + ' (already exists, left untouched)') -ForegroundColor DarkGray
        }
    }

    Write-Host '[OK] Agent files and governance ready. Nothing was deleted.' -ForegroundColor Green
}

# Aliases (idempotent)
$AliasNames = @('agents-init', 'ai-init', 'init-agents', 'init-needed-files', 'Init-NeededFiles')
foreach ($aliasName in $AliasNames) {
    try {
        if (-not (Get-Alias $aliasName -ErrorAction Stop)) {
            Set-Alias -Name $aliasName -Value Initialize-AgentWorkspace -Scope Global -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Set-Alias -Name $aliasName -Value Initialize-AgentWorkspace -Scope Global -Force -ErrorAction SilentlyContinue
    }
}
'@

Set-Content -Path $InitScriptPath -Value $InitScript -Encoding UTF8
Write-Host "[OK] Wrote $InitScriptPath" -ForegroundColor Cyan

# Load it in THIS session
. $InitScriptPath

# ------------------------------------------------------------------------------
# 12. Register the command in PowerShell $PROFILE (replace our block, keep the rest)
# ------------------------------------------------------------------------------
$WrapperBlock = @"

# >>> GLOBAL-AI-AGENTS-WRAPPER-START >>>
# Global AI Agents v$script:Version - command: Initialize-AgentWorkspace
# aliases: agents-init , ai-init , init-agents , init-needed-files , Init-NeededFiles
`$script:GlobalAgentsRoot = Join-Path `$env:USERPROFILE '.agents'
`$script:GlobalAgentsInit = Join-Path `$script:GlobalAgentsRoot 'init-project-files.ps1'
if (Test-Path -LiteralPath `$script:GlobalAgentsInit) {
    . `$script:GlobalAgentsInit
}
function Invoke-GlobalAgentsPreflight {
    try {
        if (Get-Command Initialize-AgentWorkspace -ErrorAction SilentlyContinue) {
            Initialize-AgentWorkspace -Path (Get-Location).Path | Out-Null
        }
    } catch { }
}
function freebuff {
    Invoke-GlobalAgentsPreflight
    `$real = Get-Command 'freebuff.*' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (`$real) { & `$real.Source @args } else { npx -y freebuff @args }
}
function codebuff {
    Invoke-GlobalAgentsPreflight
    `$real = Get-Command 'codebuff.*' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (`$real) { & `$real.Source @args } else { npx -y codebuff @args }
}
function codex {
    Invoke-GlobalAgentsPreflight
    `$real = Get-Command 'codex.*' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (`$real) { & `$real.Source @args } else {
        Write-Host 'codex executable not found on PATH.' -ForegroundColor Yellow
    }
}
# <<< GLOBAL-AI-AGENTS-WRAPPER-END <<<
"@

$ProfilePaths = @($PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost) | Where-Object { $_ } | Select-Object -Unique
foreach ($ProfPath in $ProfilePaths) {
    $ProfDir = Split-Path -Parent $ProfPath
    if (-not (Test-Path $ProfDir)) { New-Item -ItemType Directory -Force -Path $ProfDir | Out-Null }
    if (-not (Test-Path $ProfPath)) { New-Item -ItemType File -Force -Path $ProfPath | Out-Null }

    $existing = Get-Content -Path $ProfPath -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrEmpty($existing)) {
        Set-Content -Path $ProfPath -Value $WrapperBlock -Encoding UTF8 -NoNewline
        Write-Host ("[OK] Wrote profile: " + $ProfPath) -ForegroundColor Cyan
        continue
    }

    $wrapPattern = "(?s)# >>> GLOBAL-AI-AGENTS-WRAPPER-START >>>.*?# <<< GLOBAL-AI-AGENTS-WRAPPER-END <<<"
    $wrapMatch   = [regex]::Match($existing, $wrapPattern)
    if ($wrapMatch.Success) {
        $updated = $existing.Substring(0, $wrapMatch.Index) + $WrapperBlock.Trim() + $existing.Substring($wrapMatch.Index + $wrapMatch.Length)
        Set-Content -Path $ProfPath -Value $updated -Encoding UTF8 -NoNewline
        Write-Host ("[OK] Updated profile block: " + $ProfPath) -ForegroundColor Cyan
    } else {
        Add-Content -Path $ProfPath -Value $WrapperBlock -Encoding UTF8 -NoNewline
        Write-Host ("[OK] Appended profile block: " + $ProfPath) -ForegroundColor Cyan
    }
}

# ------------------------------------------------------------------------------
# 13. Optional: update existing workspace roots (update only, never delete)
# ------------------------------------------------------------------------------
Write-Host "`n[WORKSPACE] Updating known workspace roots (optional, non-destructive)..." -ForegroundColor Yellow
$WorkspaceRoots = @(
    "D:\MyHdd\VS-Project",
    "C:\Projects",
    (Join-Path $env:USERPROFILE "source\repos"),
    (Join-Path $env:USERPROFILE "Projects")
)
foreach ($Root in $WorkspaceRoots) {
    if (-not (Test-Path $Root)) { continue }
    Write-Host "  -> $Root" -ForegroundColor Cyan
    $ProjectDirs = Get-ChildItem -Path $Root -Directory -Depth 2 -ErrorAction SilentlyContinue | Where-Object {
        (Test-Path (Join-Path $_.FullName ".git")) -or
        (Test-Path (Join-Path $_.FullName "package.json")) -or
        (Test-Path (Join-Path $_.FullName "*.sln"))
    }
    foreach ($Proj in $ProjectDirs) {
        Initialize-AgentWorkspace -Path $Proj.FullName
    }
}

Write-Host ""
Write-Host "[SUCCESS] Global AI Agent Configurator v$script:Version complete." -ForegroundColor Green
Write-Host ("Central : " + $CentralDir) -ForegroundColor Cyan
Write-Host ""
Write-Host "Use this in any project folder (new PowerShell session, or already loaded here):" -ForegroundColor Yellow
Write-Host "    Initialize-AgentWorkspace" -ForegroundColor White
Write-Host "    agents-init" -ForegroundColor White
Write-Host "    ai-init" -ForegroundColor White
Write-Host "    init-needed-files" -ForegroundColor White
Write-Host "    init-needed-files -Full     # extra adapters (Cline, Windsurf, Aider, ...)" -ForegroundColor White
Write-Host ""
Write-Host "Nothing is deleted. Existing files are only updated inside the marked block." -ForegroundColor DarkGray