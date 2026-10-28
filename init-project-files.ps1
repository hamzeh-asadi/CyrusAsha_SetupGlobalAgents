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
            '7. Read and synchronize project domain context and conventions from `knowledge.md` (and `AGENTS.md`).',
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
                ('# ðŸ¤– Project Operating Guide: ' + $projName),
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
            ('# ðŸ¤– Project Operating Guide: ' + $projName),
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

    # 1) Junction .agents -> ~/.agents (Verify health, repair broken/stale junctions from OS reinstallation)
    $LocalAgents = Join-Path $ProjectPath '.agents'
    $needsJunction = $true
    $existingItem = Get-Item -LiteralPath $LocalAgents -Force -ErrorAction SilentlyContinue

    if ($null -ne $existingItem) {
        $isReparse = [bool]($existingItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        if ($isReparse) {
            $currentTarget = $existingItem.Target
            if ($currentTarget -is [array]) { $currentTarget = $currentTarget[0] }

            $targetAccessible = $false
            try { $targetAccessible = Test-Path -LiteralPath $LocalAgents -ErrorAction Stop } catch { $targetAccessible = $false }

            if (($currentTarget -eq $CentralDir) -and $targetAccessible) {
                Write-Host ('  [OK]     ' + $LocalAgents + ' -> ' + $CentralDir + ' (Healthy Junction)') -ForegroundColor DarkGray
                $needsJunction = $false
            } else {
                Write-Host ('  [REPAIR] Stale or inaccessible .agents junction found (Target: ' + $currentTarget + '). Re-linking...') -ForegroundColor DarkYellow
                cmd /c rmdir "`"$LocalAgents`"" > $null 2>&1
                $needsJunction = $true
            }
        } else {
            # Regular directory: if empty, replace with junction
            $subItems = Get-ChildItem -LiteralPath $LocalAgents -Force -ErrorAction SilentlyContinue
            if ($null -eq $subItems -or $subItems.Count -eq 0) {
                Write-Host ('  [REPAIR] Empty .agents directory found. Replacing with junction...') -ForegroundColor DarkYellow
                Remove-Item -LiteralPath $LocalAgents -Force -Recurse -ErrorAction SilentlyContinue
                $needsJunction = $true
            } else {
                Write-Host ('  [WARN]   ' + $LocalAgents + ' is a non-empty regular folder. Preserving existing contents.') -ForegroundColor DarkYellow
                $needsJunction = $false
            }
        }
    }

    if ($needsJunction) {
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
