[CmdletBinding()]
param(
    [switch]$ForceInstallPoshGit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "====================================================================="
Write-Host "CONFIGURANDO POWERSHELL PROFILE PARA EXIBIR BRANCH DO GIT"
Write-Host "====================================================================="

$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profilePath

if (-not (Test-Path -Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path -Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
    Write-Host "Profile criado em: $profilePath"
}

$startMarker = '# >>> custom-powershell >>>'
$endMarker = '# <<< custom-powershell <<<'

$profileContent = Get-Content -Path $profilePath -Raw

if ($profileContent -match [regex]::Escape($startMarker)) {
    Write-Host "Configuracao do PowerShell personalizada ja existe no profile. Pulando adicao."
}
else {
    Write-Host "Adicionando configuracao personalizada de prompt e autocomplete de git ao profile do PowerShell..."

    $gitProfileBlock = @'

# >>> custom-powershell >>>
# Inicia na pasta do usuario
Set-Location $env:USERPROFILE

# Prompt customizado com branch git atual e autocomplete para git.
function global:prompt {
    $currentPath = (Get-Location).Path
    $branch = $null

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $branch = $null
        }
    }

    Write-Host "$env:USERNAME@$env:COMPUTERNAME" -ForegroundColor Green -NoNewline
    Write-Host ":$currentPath" -ForegroundColor Blue -NoNewline

    if ($branch) {
        Write-Host " ($branch)" -ForegroundColor Yellow -NoNewline
    }

    return '> '
}

# Carrega posh-git quando disponivel (prompt rico e autocomplete de git).
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}
elseif (-not (Get-Command Register-GitBasicCompletion -ErrorAction SilentlyContinue)) {
    # Fallback basico de autocomplete de subcomandos git.
    Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        $subcommands = @(
            'add', 'bisect', 'branch', 'checkout', 'cherry-pick', 'clone',
            'commit', 'diff', 'fetch', 'grep', 'init', 'log', 'merge',
            'mv', 'pull', 'push', 'rebase', 'remote', 'reset', 'restore',
            'revert', 'rm', 'show', 'stash', 'status', 'switch', 'tag'
        )

        $subcommands |
            Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
}
# <<< custom-powershell <<<
'@

    Add-Content -Path $profilePath -Value $gitProfileBlock
    Write-Host "Configuracao de prompt/autocomplete do git adicionada ao profile."
}

Write-Host ""
Write-Host "====================================================================="
Write-Host "CONFIGURANDO AUTOCOMPLETE GIT (POSH-GIT)"
Write-Host "====================================================================="

$canInstallModules = $null -ne (Get-Command Install-Module -ErrorAction SilentlyContinue)
$hasPoshGit = $null -ne (Get-Module -ListAvailable -Name posh-git)

if ($ForceInstallPoshGit -or -not $hasPoshGit) {
    if ($canInstallModules) {
        try {
            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
            }

            if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
                Register-PSRepository -Default
            }

            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

            Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
            Write-Host "posh-git instalado com sucesso."
            $hasPoshGit = $true
        }
        catch {
            Write-Warning "Nao foi possivel instalar posh-git automaticamente: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Install-Module nao esta disponivel nesta sessao."
    }
}
else {
    Write-Host "posh-git ja esta instalado."
}

if ($hasPoshGit) {
    try {
        Import-Module posh-git -ErrorAction Stop
        Write-Host "Autocomplete de git habilitado com posh-git na sessao atual."
    }
    catch {
        Write-Warning "posh-git esta instalado, mas nao foi possivel importar agora: $($_.Exception.Message)"
    }
}
else {
    Write-Warning "Autocomplete avancado nao foi habilitado via posh-git. O fallback basico no profile continuara disponivel."
}

Write-Host ""
Write-Host "Concluido."
Write-Host "Para aplicar no terminal atual, execute:"
Write-Host ". `$PROFILE.CurrentUserAllHosts"
