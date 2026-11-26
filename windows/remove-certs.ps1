[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    # Aliases (corp-*) a remover. Sem este parametro, o script apenas lista.
    [string[]]$Remove,
    [string[]]$JdkName,
    [string]$InstallRoot = "$env:USERPROFILE\opt\java",
    [string]$StorePass = 'changeit'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AliasPrefix = 'corp-'

function Invoke-KeytoolCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Keytool,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Keytool
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $escapedArgs = foreach ($arg in $Arguments) {
        if ($arg -match '[\s"]') {
            '"{0}"' -f ($arg -replace '"', '\"')
        }
        else {
            $arg
        }
    }

    $psi.Arguments = [string]::Join(' ', $escapedArgs)

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi

    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}

function Get-CorpAliasesFromKeystore {
    param(
        [Parameter(Mandatory = $true)][string]$Keytool,
        [Parameter(Mandatory = $true)][string]$StorePass
    )

    # -J-Duser.language=en forca saida em ingles para o parse ser estavel
    $result = Invoke-KeytoolCommand -Keytool $Keytool -Arguments @(
        '-J-Duser.language=en', '-list', '-cacerts', '-storepass', $StorePass
    )

    if ($result.ExitCode -ne 0) {
        throw ("keytool -list falhou: {0}" -f $result.StdErr.Trim())
    }

    $items = @()
    $current = $null

    foreach ($line in ($result.StdOut -split "\r?\n")) {
        $entry = [regex]::Match($line, '^(?<alias>[^,]+),.*trustedCertEntry')
        if ($entry.Success) {
            $current = [PSCustomObject]@{
                Alias       = $entry.Groups['alias'].Value.Trim()
                Fingerprint = ''
            }
            $items += $current
            continue
        }

        $fp = [regex]::Match($line, '\(SHA-?256\):\s*(?<fp>[0-9A-Fa-f:]+)')
        if ($fp.Success -and $null -ne $current) {
            $current.Fingerprint = $fp.Groups['fp'].Value
        }
    }

    return @($items | Where-Object { $_.Alias.StartsWith($AliasPrefix, [StringComparison]::OrdinalIgnoreCase) })
}

if (-not (Test-Path -Path $InstallRoot)) {
    throw "InstallRoot nao existe: $InstallRoot"
}

foreach ($alias in @($Remove)) {
    if ($alias -and -not $alias.StartsWith($AliasPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw ("Alias '{0}' recusado: so e permitido remover aliases com prefixo '{1}'." -f $alias, $AliasPrefix)
    }
}

$jdkDirs = @(
    Get-ChildItem -Path $InstallRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^jdk-\d+' } |
        Sort-Object Name
)

if ($JdkName) {
    $jdkDirs = @($jdkDirs | Where-Object { $JdkName -contains $_.Name })
}

if ($jdkDirs.Count -eq 0) {
    throw ("Nenhuma JDK encontrada em {0}" -f $InstallRoot)
}

$removed = 0
$notFound = 0
$failed = 0

foreach ($jdk in $jdkDirs) {
    $keytool = Join-Path $jdk.FullName 'bin\keytool.exe'

    Write-Host ''
    Write-Host ("Java: {0}" -f $jdk.Name)

    if (-not (Test-Path -Path $keytool)) {
        Write-Warning ("Keytool nao encontrado em {0}" -f $keytool)
        continue
    }

    try {
        $installed = @(Get-CorpAliasesFromKeystore -Keytool $keytool -StorePass $StorePass)
    }
    catch {
        Write-Warning ("{0}: {1}" -f $jdk.Name, $_.Exception.Message)
        $failed++
        continue
    }

    if (-not $Remove) {
        if ($installed.Count -eq 0) {
            Write-Host '  (nenhum certificado corp-*)'
        }
        foreach ($item in $installed) {
            Write-Host ("  {0}" -f $item.Alias)
            if ($item.Fingerprint) {
                Write-Host ("      SHA-256: {0}" -f $item.Fingerprint)
            }
        }
        continue
    }

    foreach ($alias in $Remove) {
        $match = $installed | Where-Object { $_.Alias -ieq $alias } | Select-Object -First 1
        if (-not $match) {
            Write-Host ("  [skip] {0} (nao encontrado)" -f $alias)
            $notFound++
            continue
        }

        if (-not $PSCmdlet.ShouldProcess(("{0} ({1})" -f $match.Alias, $jdk.Name), 'Remover certificado do cacerts')) {
            continue
        }

        $result = Invoke-KeytoolCommand -Keytool $keytool -Arguments @(
            '-delete', '-alias', $match.Alias, '-cacerts', '-storepass', $StorePass
        )

        if ($result.ExitCode -eq 0) {
            Write-Host ("  [ok]   {0} removido" -f $match.Alias)
            $removed++
        }
        else {
            Write-Host ("  [fail] {0}" -f $match.Alias)
            if (-not [string]::IsNullOrWhiteSpace($result.StdErr)) {
                Write-Warning ("Detalhe keytool: {0}" -f $result.StdErr.Trim())
            }
            $failed++
        }
    }
}

if ($Remove) {
    Write-Host ''
    Write-Host ("Resumo - Removidos: {0} | Nao encontrados: {1} | Falhas: {2}" -f $removed, $notFound, $failed)
}
