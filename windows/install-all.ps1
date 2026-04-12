Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '====================================================================='
Write-Host 'CONFIGURACAO DO AMBIENTE DE DESENVOLVIMENTO (WINDOWS)'
Write-Host '====================================================================='
Write-Host ''
Write-Host 'Escopo deste orquestrador:' -ForegroundColor Cyan
Write-Host '- Java (Temurin/OpenJDK)'
Write-Host '- IntelliJ IDEA Community'
Write-Host ''
Write-Host 'Aplicacoes Linux adicionais (Chrome, KeePass, DBeaver, certificados etc.) nao sao instaladas aqui.' -ForegroundColor Yellow
Write-Host ''

$javaScript = Join-Path $PSScriptRoot 'install-java.ps1'
$ideaScript = Join-Path $PSScriptRoot 'install-intellij.ps1'

if (-not (Test-Path -Path $javaScript)) {
    throw "Script nao encontrado: $javaScript"
}
if (-not (Test-Path -Path $ideaScript)) {
    throw "Script nao encontrado: $ideaScript"
}

Write-Host 'Executando instalacao do Java...'
& $javaScript

Write-Host ''
Write-Host 'Executando instalacao do IntelliJ IDEA...'
& $ideaScript

Write-Host ''
Write-Host 'Configuracao Windows concluida.' -ForegroundColor Green
