[CmdletBinding(DefaultParameterSetName = 'Set')]
param(
    [Parameter(ParameterSetName = 'Set', Mandatory = $true)]
    [ValidatePattern('^\d+$')]
    [string]$Version,

    [Parameter(ParameterSetName = 'List', Mandatory = $true)]
    [switch]$List,

    [string]$InstallRoot = "$env:USERPROFILE\opt\java"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-InstalledJavaVersions {
    param([string]$Root)

    if (-not (Test-Path -Path $Root)) {
        return @()
    }

    $dirs = Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^jdk-(\d+)$' }

    return $dirs | ForEach-Object {
        [PSCustomObject]@{
            Version = ($_.Name -replace '^jdk-', '')
            Path    = $_.FullName
            JavaExe = Join-Path $_.FullName 'bin\java.exe'
        }
    } | Sort-Object { [int]$_.Version }
}

function Set-UserJavaEnvironment {
    param(
        [Parameter(Mandatory = $true)]
        [string]$JavaHome,
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $javaBin = Join-Path $JavaHome 'bin'
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) {
        $userPath = ''
    }

    $segments = $userPath -split ';' | Where-Object { $_ -and $_.Trim().Length -gt 0 }
    $rootRegex = '^' + [Regex]::Escape((Resolve-Path -Path $Root).Path) + '\\jdk-\d+\\bin$'

    $cleanSegments = @()
    foreach ($segment in $segments) {
        if ($segment -match $rootRegex) {
            continue
        }
        if ($segment -ieq '%JAVA_HOME%\bin') {
            continue
        }
        $cleanSegments += $segment
    }

    $newSegments = @($javaBin) + $cleanSegments
    $newPath = ($newSegments -join ';').Trim(';')

    [Environment]::SetEnvironmentVariable('JAVA_HOME', $JavaHome, 'User')
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

    $env:JAVA_HOME = $JavaHome
    $env:Path = $newPath
}

$installed = Get-InstalledJavaVersions -Root $InstallRoot

if ($PSCmdlet.ParameterSetName -eq 'List') {
    if ($installed.Count -eq 0) {
        Write-Host 'Nenhuma versao de Java instalada foi encontrada.' -ForegroundColor Yellow
        exit 0
    }

    Write-Host 'Versoes Java instaladas:' -ForegroundColor Cyan
    foreach ($item in $installed) {
        Write-Host ("- Java {0} -> {1}" -f $item.Version, $item.Path)
    }
    exit 0
}

$target = $installed | Where-Object { $_.Version -eq $Version } | Select-Object -First 1
if (-not $target) {
    throw "Java $Version nao encontrado em $InstallRoot. Execute install-java.ps1 primeiro."
}

if (-not (Test-Path -Path $target.JavaExe)) {
    throw "Executavel nao encontrado: $($target.JavaExe)"
}

Set-UserJavaEnvironment -JavaHome $target.Path -Root $InstallRoot

Write-Host ("JAVA_HOME configurado para: {0}" -f $target.Path) -ForegroundColor Green
Write-Host 'Validacao da versao ativa:' -ForegroundColor Cyan
& (Join-Path $target.Path 'bin\java.exe') -version
& (Join-Path $target.Path 'bin\javac.exe') -version
Write-Host ''
Write-Host 'Abra um novo terminal para que todas as aplicacoes usem a nova versao.' -ForegroundColor Yellow
