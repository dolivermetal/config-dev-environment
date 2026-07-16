[CmdletBinding()]
param(
    [string]$InstallRoot = "$env:USERPROFILE\opt\java",
    [string]$StorePass = 'changeit',
    [switch]$SkipJava,
    [switch]$SkipChrome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Convert-ToAlias {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.ToLowerInvariant()
    $normalized = $normalized -replace '[^a-z0-9._-]', '-'
    $normalized = $normalized.Trim('-')

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return 'cert'
    }

    return $normalized
}

function Get-CertificatesFromFile {
    param([Parameter(Mandatory = $true)][string]$FilePath)

    $ext = [IO.Path]::GetExtension($FilePath).ToLowerInvariant()
    $base = [IO.Path]::GetFileNameWithoutExtension($FilePath)
    $results = @()

    if ($ext -in @('.cer', '.crt')) {
        try {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($FilePath)
            $results += [PSCustomObject]@{
                Cert         = $cert
                Source       = $FilePath
                AliasBase    = (Convert-ToAlias -Value $base)
                FriendlyName = [IO.Path]::GetFileName($FilePath)
            }
        }
        catch {
            Write-Warning ("Falha ao ler certificado: {0} - {1}" -f $FilePath, $_.Exception.Message)
        }

        return $results
    }

    if ($ext -eq '.pem') {
        $raw = Get-Content -Path $FilePath -Raw
        $matches = [regex]::Matches(
            $raw,
            '-----BEGIN CERTIFICATE-----(?<body>[\s\S]*?)-----END CERTIFICATE-----',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

        if ($matches.Count -eq 0) {
            Write-Warning ("Arquivo PEM sem blocos de certificado: {0}" -f $FilePath)
            return $results
        }

        $index = 0
        foreach ($m in $matches) {
            $index++
            try {
                $body = $m.Groups['body'].Value
                $base64 = $body -replace '\s+', ''
                $bytes = [Convert]::FromBase64String($base64)
                $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes)

                $aliasBase = if ($matches.Count -gt 1) {
                    "{0}-{1}" -f (Convert-ToAlias -Value $base), $index
                }
                else {
                    (Convert-ToAlias -Value $base)
                }

                $results += [PSCustomObject]@{
                    Cert         = $cert
                    Source       = $FilePath
                    AliasBase    = $aliasBase
                    FriendlyName = if ($matches.Count -gt 1) {
                        "{0} (cert #{1})" -f [IO.Path]::GetFileName($FilePath), $index
                    }
                    else {
                        [IO.Path]::GetFileName($FilePath)
                    }
                }
            }
            catch {
                Write-Warning ("Falha ao processar bloco PEM em {0}: {1}" -f $FilePath, $_.Exception.Message)
            }
        }

        return $results
    }

    return $results
}

function Get-JavaKeystorePath {
    param([Parameter(Mandatory = $true)][string]$JavaHome)

    $paths = @(
        (Join-Path $JavaHome 'lib\security\cacerts'),
        (Join-Path $JavaHome 'jre\lib\security\cacerts')
    )

    foreach ($candidate in $paths) {
        if (Test-Path -Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Get-ExportedCertThumbprintFromKeytool {
    param(
        [Parameter(Mandatory = $true)][string]$Keytool,
        [Parameter(Mandatory = $true)][string]$Keystore,
        [Parameter(Mandatory = $true)][string]$StorePass,
        [Parameter(Mandatory = $true)][string]$Alias
    )

    $args = @('-exportcert', '-rfc', '-alias', $Alias, '-cacerts', '-storepass', $StorePass)
    $result = Invoke-KeytoolCommand -Keytool $Keytool -Arguments $args

    if ($result.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($result.StdOut)) {
        return $null
    }

    $text = $result.StdOut
    $m = [regex]::Match(
        $text,
        '-----BEGIN CERTIFICATE-----(?<body>[\s\S]*?)-----END CERTIFICATE-----',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    if (-not $m.Success) {
        return $null
    }

    try {
        $base64 = ($m.Groups['body'].Value -replace '\s+', '')
        $bytes = [Convert]::FromBase64String($base64)
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes)
        return $cert.Thumbprint.ToUpperInvariant()
    }
    catch {
        return $null
    }
}

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
        if ($null -eq $arg) {
            '""'
            continue
        }

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

function Install-CertificatesIntoJava {
    param(
        [Parameter(Mandatory = $true)][object[]]$CertItems,
        [Parameter(Mandatory = $true)][string]$InstallRoot,
        [Parameter(Mandatory = $true)][string]$StorePass
    )

    $summary = [PSCustomObject]@{
        JdksFound  = 0
        Installed  = 0
        Skipped    = 0
        Failed     = 0
    }

    $jdkDirs = @(
        Get-ChildItem -Path $InstallRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^jdk-\d+' } |
            Sort-Object Name
    )

    if (-not $jdkDirs -or $jdkDirs.Count -eq 0) {
        Write-Warning ("Nenhuma JDK encontrada em {0}" -f $InstallRoot)
        return $summary
    }

    $summary.JdksFound = $jdkDirs.Count

    foreach ($jdk in $jdkDirs) {
        $javaHome = $jdk.FullName
        $keytool = Join-Path $javaHome 'bin\keytool.exe'
        $keystore = Get-JavaKeystorePath -JavaHome $javaHome

        Write-Host ''
        Write-Host ("Java: {0}" -f $jdk.Name)

        if (-not (Test-Path -Path $keytool)) {
            Write-Warning ("Keytool nao encontrado em {0}" -f $keytool)
            continue
        }

        if (-not $keystore) {
            Write-Warning ("Keystore cacerts nao encontrado em {0}" -f $javaHome)
            continue
        }

        foreach ($item in $CertItems) {
            $thumb = $item.Cert.Thumbprint.ToUpperInvariant()
            $alias = "corp-{0}-{1}" -f $item.AliasBase, $thumb.Substring(0, 8).ToLowerInvariant()

            $existingThumb = Get-ExportedCertThumbprintFromKeytool -Keytool $keytool -Keystore $keystore -StorePass $StorePass -Alias $alias
            if ($existingThumb -eq $thumb) {
                Write-Host ("  [skip] {0} (ja existente)" -f $item.FriendlyName)
                $summary.Skipped++
                continue
            }

            $tempCert = Join-Path $env:TEMP ("cert-{0}.cer" -f ([Guid]::NewGuid().ToString('N')))

            try {
                [IO.File]::WriteAllBytes($tempCert, $item.Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))

                $args = @('-importcert', '-noprompt', '-trustcacerts', '-alias', $alias, '-cacerts', '-storepass', $StorePass, '-file', $tempCert)
                $importResult = Invoke-KeytoolCommand -Keytool $keytool -Arguments $args

                if ($importResult.ExitCode -eq 0) {
                    Write-Host ("  [ok]   {0}" -f $item.FriendlyName)
                    $summary.Installed++
                }
                else {
                    Write-Host ("  [fail] {0}" -f $item.FriendlyName)
                    if (-not [string]::IsNullOrWhiteSpace($importResult.StdErr)) {
                        Write-Warning ("Detalhe keytool: {0}" -f $importResult.StdErr.Trim())
                    }
                    $summary.Failed++
                }
            }
            catch {
                Write-Warning ("Falha ao importar certificado {0} no Java {1}: {2}" -f $item.FriendlyName, $jdk.Name, $_.Exception.Message)
                $summary.Failed++
            }
            finally {
                if (Test-Path -Path $tempCert) {
                    Remove-Item -Path $tempCert -Force
                }
            }
        }
    }

    return $summary
}

function Install-CertificatesIntoWindowsRoot {
    param([Parameter(Mandatory = $true)][object[]]$CertItems)

    $summary = [PSCustomObject]@{
        Installed = 0
        Skipped   = 0
        Failed    = 0
    }

    $store = [System.Security.Cryptography.X509Certificates.X509Store]::new('Root', 'CurrentUser')
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

    try {
        $existing = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
        foreach ($cert in $store.Certificates) {
            $existing.Add($cert.Thumbprint.ToUpperInvariant()) | Out-Null
        }

        foreach ($item in $CertItems) {
            $thumb = $item.Cert.Thumbprint.ToUpperInvariant()

            if ($existing.Contains($thumb)) {
                Write-Host ("Chrome/Windows [skip] {0} (ja existente)" -f $item.FriendlyName)
                $summary.Skipped++
                continue
            }

            try {
                $store.Add($item.Cert)
                $existing.Add($thumb) | Out-Null
                Write-Host ("Chrome/Windows [ok]   {0}" -f $item.FriendlyName)
                $summary.Installed++
            }
            catch {
                Write-Warning ("Falha ao importar certificado no store CurrentUser\\Root: {0}" -f $_.Exception.Message)
                $summary.Failed++
            }
        }
    }
    finally {
        $store.Close()
    }

    return $summary
}

$certDir = Join-Path $PSScriptRoot '..\certs'
$resolvedCertDir = @(Resolve-Path -Path $certDir -ErrorAction SilentlyContinue)
if (-not $resolvedCertDir -or $resolvedCertDir.Count -eq 0) {
    throw "Diretorio de certificados nao encontrado: $certDir"
}

$resolvedCertDirPath = $resolvedCertDir[0].Path

$certFiles = @(
    Get-ChildItem -Path $resolvedCertDirPath -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLowerInvariant() -in @('.cer', '.crt', '.pem') } |
        Sort-Object Name
)

if (-not $certFiles -or $certFiles.Count -eq 0) {
    throw "Nenhum certificado .cer/.crt/.pem encontrado em $resolvedCertDirPath"
}

$certItems = @()
foreach ($file in $certFiles) {
    $certItems += Get-CertificatesFromFile -FilePath $file.FullName
}

if (-not $certItems -or $certItems.Count -eq 0) {
    throw "Nenhum certificado valido foi carregado de $resolvedCertDirPath"
}

Write-Host '====================================================================='
Write-Host 'INSTALACAO DE CERTIFICADOS (WINDOWS)'
Write-Host '====================================================================='
Write-Host ("Certificados encontrados: {0}" -f $certItems.Count)
Write-Host ("Diretorio de certificados: {0}" -f $resolvedCertDirPath)
Write-Host ("InstallRoot Java: {0}" -f $InstallRoot)

$javaSummary = [PSCustomObject]@{ JdksFound = 0; Installed = 0; Skipped = 0; Failed = 0 }
$chromeSummary = [PSCustomObject]@{ Installed = 0; Skipped = 0; Failed = 0 }

if (-not $SkipJava) {
    if (-not (Test-Path -Path $InstallRoot)) {
        Write-Warning ("InstallRoot nao existe, importacao Java ignorada: {0}" -f $InstallRoot)
    }
    else {
        $javaSummary = Install-CertificatesIntoJava -CertItems $certItems -InstallRoot $InstallRoot -StorePass $StorePass
    }
}
else {
    Write-Host 'Importacao para Java ignorada por parametro.'
}

Write-Host ''
if (-not $SkipChrome) {
    $chromeSummary = Install-CertificatesIntoWindowsRoot -CertItems $certItems
}
else {
    Write-Host 'Importacao para Chrome/Windows ignorada por parametro.'
}

Write-Host ''
Write-Host 'Resumo:'
Write-Host ("Java    - JDKs: {0} | Instalados: {1} | Ignorados: {2} | Falhas: {3}" -f $javaSummary.JdksFound, $javaSummary.Installed, $javaSummary.Skipped, $javaSummary.Failed)
Write-Host ("Chrome  - Instalados: {0} | Ignorados: {1} | Falhas: {2}" -f $chromeSummary.Installed, $chromeSummary.Skipped, $chromeSummary.Failed)
Write-Host ''
Write-Host 'Instalacao de certificados concluida.' -ForegroundColor Green
