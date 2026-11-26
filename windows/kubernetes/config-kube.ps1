[CmdletBinding()]
param(
    [string]$InstallDir = "$env:USERPROFILE\opt\kube",
    [string]$TempDir = "$PSScriptRoot\tmp"
)

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host '====================================================================='
Write-Host 'INSTALANDO KUBECTL OIDC LOGIN NO WINDOWS'
Write-Host '====================================================================='
Write-Host ''

# Baixando o plugin diretamente do repositório no Windows
$VERSION = (Invoke-RestMethod https://api.github.com/repos/int128/kubelogin/releases/latest).tag_name

$zipPath = Join-Path $TempDir "kubelogin_windows_amd64.zip"
$extractPath = Join-Path $TempDir "extract-kubelogin"

Invoke-WebRequest -Uri "https://github.com/int128/kubelogin/releases/download/$VERSION/kubelogin_windows_amd64.zip" -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Rename-Item (Join-Path $extractPath "kubelogin.exe") "kubectl-oidc_login.exe"
Move-Item (Join-Path $extractPath "kubectl-oidc_login.exe") $InstallDir -Force

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

if (($userPath -split ';') -notcontains $InstallDir) {
    [Environment]::SetEnvironmentVariable(
        'Path',
        "$userPath;$InstallDir",
        'User'
    )
}

Remove-Item -Path $TempDir -Recurse -Force