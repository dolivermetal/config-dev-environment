[CmdletBinding()]
param(
    [string[]]$Versions = @('14','17','21','25','26'),
    [string]$InstallRoot = "$env:USERPROFILE\opt\java",
    [string]$TempDir = "$PSScriptRoot\tmp",
    [switch]$SkipSetDefault
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-Uri {
    param([Parameter(Mandatory = $true)][string]$Major)

    $ga = $null
    $manualFileName = $null

    switch ($Major) {
        '14' {
            $manualFileName = 'jdk-14.0.2_windows-x64_bin.zip'
            break
        }
        '17' {
            $manualFileName = 'jdk-17.0.19_windows-x64_bin.zip'
            break
        }
        '21' {
            $ga = "https://download.oracle.com/java/21/archive/jdk-21.0.10_windows-x64_bin.zip"
            break
        }
        '25' {
            $ga = "https://download.oracle.com/java/25/archive/jdk-25.0.2_windows-x64_bin.zip"
            break
        }
        '26' {
            $ga = "https://download.oracle.com/java/26/archive/jdk-26_windows-x64_bin.zip"
            break
        }
        default {
            throw "Versão $Major não possui URL de download para Java."
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($manualFileName)) {
        return [PSCustomObject]@{
            Uri            = $ga
            ManualFileName = $manualFileName
        }
    }

    try {
        Invoke-WebRequest -Uri $ga -Method Head -UseBasicParsing -TimeoutSec 25 | Out-Null
        return [PSCustomObject]@{
            Uri            = $ga
            ManualFileName = $manualFileName
        }
    }
    catch {
        Write-Warning "Sem artefato GA para Java $Major."
        throw "Nao foi possivel resolver URL de download para Java $Major"
    }
}

function Get-ExtractedJdkDirectory {
    param([Parameter(Mandatory = $true)][string]$ExtractRoot)

    $candidate = Get-ChildItem -Path $ExtractRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^jdk-\d+' } |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Diretorio JDK nao encontrado em $ExtractRoot"
    }

    return $candidate.FullName
}

New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host '====================================================================='
Write-Host 'INSTALANDO JAVA OPENJDK NO WINDOWS'
Write-Host '====================================================================='
Write-Host ''

$installedVersions = @()

foreach ($version in $Versions) {
    if ($version -notmatch '^\d+$') {
        Write-Warning "Versao invalida ignorada: $version"
        continue
    }

    $targetDir = Join-Path $InstallRoot "jdk-$version"
    $javaExe = Join-Path $targetDir 'bin\java.exe'

    if (Test-Path -Path $javaExe) {
        Write-Host ("Java {0} ja esta instalado em {1}" -f $version, $targetDir)
        $installedVersions += $version
        continue
    }

    $downloadSpec = Resolve-Uri -Major $version
    $uri = $downloadSpec.Uri
    $manualFileName = $downloadSpec.ManualFileName

    if ([string]::IsNullOrWhiteSpace($manualFileName)) {
        $zipPath = Join-Path $TempDir "jdk-$version.zip"
    }
    else {
        $zipPath = Join-Path $TempDir $manualFileName
    }

    $extractPath = Join-Path $TempDir "extract-jdk-$version"
    $cleanupZipAfterInstall = $false

    Write-Host ("Instalando Java {0}..." -f $version)
    Write-Host ("Download: {0}" -f $uri)

    if (Test-Path -Path $extractPath) { Remove-Item -Path $extractPath -Recurse -Force }

    if (Test-Path -Path $zipPath) {
        Write-Host ("Arquivo encontrado em tmp: {0}" -f $zipPath)
    }
    elseif (-not [string]::IsNullOrWhiteSpace($manualFileName)) {
        Write-Warning ("Arquivo {0} nao encontrado em tmp." -f $manualFileName)
        Write-Warning ("Para Java {0}, o download deve ser feito manualmente em:" -f $version)
        Write-Warning 'https://www.oracle.com/java/technologies/downloads/archive'
        continue
    }
    else {
        Invoke-WebRequest -Uri $uri -OutFile $zipPath -UseBasicParsing
        $cleanupZipAfterInstall = $true
    }

    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $jdkDir = Get-ExtractedJdkDirectory -ExtractRoot $extractPath

    if (Test-Path -Path $targetDir) {
        Remove-Item -Path $targetDir -Recurse -Force
    }

    Move-Item -Path $jdkDir -Destination $targetDir

    if (-not (Test-Path -Path $javaExe)) {
        throw "Falha ao instalar Java $version. Executavel nao encontrado em $javaExe"
    }

    if ($cleanupZipAfterInstall -and (Test-Path -Path $zipPath)) {
        Remove-Item -Path $zipPath -Force
    }
    Remove-Item -Path $extractPath -Recurse -Force

    Write-Host ("Java {0} instalado com sucesso em {1}" -f $version, $targetDir)
    $installedVersions += $version
}

$manifest = [PSCustomObject]@{
    installRoot = $InstallRoot
    versions    = ($installedVersions | Sort-Object { [int]$_ } -Unique)
    updatedAt   = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
}

$manifestPath = Join-Path $InstallRoot 'java-versions.json'
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host ''
Write-Host ("Manifesto atualizado: {0}" -f $manifestPath)

if (-not $SkipSetDefault -and $installedVersions.Count -gt 0) {
    $defaultVersion = $installedVersions | Sort-Object { [int]$_ } -Descending | Select-Object -First 1
    Write-Host ("Definindo Java {0} como padrao do usuario..." -f $defaultVersion)

    & (Join-Path $PSScriptRoot 'set-java-version.ps1') -Version $defaultVersion -InstallRoot $InstallRoot
}

Write-Host ''
Write-Host 'Instalacao do Java concluida.' -ForegroundColor Green
