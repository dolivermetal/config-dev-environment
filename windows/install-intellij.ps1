[CmdletBinding()]
param(
    [string]$Version = '2026.1',
    [string]$InstallRoot = "$env:USERPROFILE\opt\idea",
    [string]$TempDir = "$PSScriptRoot\tmp"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-StartMenuShortcut {
    param(
        [Parameter(Mandatory = $true)][string]$TargetExe,
        [Parameter(Mandatory = $true)][string]$ShortcutName,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$IconLocation
    )

    $startMenuPrograms = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    New-Item -ItemType Directory -Path $startMenuPrograms -Force | Out-Null

    $shortcutPath = Join-Path $startMenuPrograms ($ShortcutName + '.lnk')

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $TargetExe
    $shortcut.WorkingDirectory = $WorkingDirectory
    $shortcut.IconLocation = $IconLocation
    $shortcut.Save()

    return $shortcutPath
}

New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

$archiveName = "idea-$Version.win.zip"
$downloadUrl = "https://download.jetbrains.com/idea/$archiveName"
$zipPath = Join-Path $TempDir $archiveName
$extractPath = Join-Path $TempDir "extracted-idea-$Version"
$targetDir = Join-Path $InstallRoot "idea-$Version"

Write-Host '====================================================================='
Write-Host 'INSTALANDO INTELLIJ IDEA NO WINDOWS'
Write-Host '====================================================================='
Write-Host ''

if (Test-Path -Path (Join-Path $targetDir 'bin\idea64.exe')) {
    Write-Host ("IntelliJ IDEA $Version ja esta instalado em $targetDir")
}
else {
    Write-Host ("Baixando IntelliJ IDEA $Version...")
    Write-Host ("URL: $downloadUrl")

    if (Test-Path -Path $zipPath) { Remove-Item -Path $zipPath -Force }
    if (Test-Path -Path $extractPath) { Remove-Item -Path $extractPath -Recurse -Force }

    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    if (-not $extractPath) {
        throw "Diretorio do IntelliJ nao encontrado apos extracao em $extractPath"
    }

    if (Test-Path -Path $targetDir) {
        Remove-Item -Path $targetDir -Recurse -Force
    }

    Move-Item -Path $extractPath -Destination $targetDir

    Remove-Item -Path $zipPath -Force
    Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue

    if (-not (Test-Path -Path (Join-Path $targetDir 'bin\idea64.exe'))) {
        throw "Falha na instalacao: idea64.exe nao encontrado em $targetDir\bin"
    }

    Write-Host ("IntelliJ IDEA $Version instalado em $targetDir") -ForegroundColor Green
    
    $exePath = Join-Path $targetDir 'bin\idea64.exe'
    $iconPath = Join-Path $targetDir 'bin\idea.ico'
    $workingDir = Join-Path $targetDir 'bin'
    if (-not (Test-Path -Path $iconPath)) {
        $iconPath = $exePath
    }
    
    $shortcutName = "IntelliJ IDEA Community $Version"
    $shortcutPath = New-StartMenuShortcut -TargetExe $exePath -ShortcutName $shortcutName -WorkingDirectory $workingDir -IconLocation $iconPath
    
    Write-Host ''
    Write-Host ("Atalho criado no Menu Iniciar: {0}" -f $shortcutPath)
}