Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '====================================================================='
Write-Host 'CONFIGURACAO DO AMBIENTE DE DESENVOLVIMENTO (WINDOWS)'
Write-Host '====================================================================='
Write-Host ''
Write-Host 'Escopo deste orquestrador:' -ForegroundColor Cyan
Write-Host '- Java (Temurin/OpenJDK)'
Write-Host '- Certificados (Java + store do Windows usado pelo Chrome)'
Write-Host '- IntelliJ IDEA Community'
Write-Host ''
Write-Host 'Aplicacoes Linux adicionais (KeePass, DBeaver etc.) nao sao instaladas aqui.' -ForegroundColor Yellow
Write-Host ''

$javaScript = Join-Path $PSScriptRoot 'install-java.ps1'
$certsScript = Join-Path $PSScriptRoot 'install-certs.ps1'
$ideaScript = Join-Path $PSScriptRoot 'install-intellij.ps1'
$customPowershellScript = Join-Path $PSScriptRoot 'custom-powershell.ps1'

if (-not (Test-Path -Path $javaScript)) {
    throw "Script nao encontrado: $javaScript"
}
if (-not (Test-Path -Path $ideaScript)) {
    throw "Script nao encontrado: $ideaScript"
}

if (-not (Test-Path -Path $certsScript)) {
    throw "Script nao encontrado: $certsScript"
}

if (-not (Test-Path -Path $customPowershellScript)) {
    throw "Script nao encontrado: $customPowershellScript"
}

Write-Host 'Executando instalacao do Java...'
& $javaScript

Write-Host ''
Write-Host 'Executando instalacao de certificados (Java + Chrome/Windows)...'
& $certsScript

Write-Host ''
Write-Host 'Executando instalacao do IntelliJ IDEA...'
& $ideaScript

Write-Host ''
Write-Host 'Configurando PowerShell personalizado...'
& $customPowershellScript

Write-Host ''
Write-Host 'Configuracao Windows concluida.' -ForegroundColor Green
