# Windows - Ambiente de Desenvolvimento

Scripts PowerShell para instalação no Windows com escopo controlado.

## Escopo

- Instala Java em varias versões.
- Importa certificados de `..\\certs` para todas as JDKs instaladas.
- Importa certificados para o store `CurrentUser\\Root` do Windows (usado pelo Chrome).
- Lista e remove certificados `corp-*` do `cacerts` de cada JDK (`remove-certs.ps1`). Não altera o store do Windows e só aceita aliases com prefixo `corp-`.
- Permite alternar versão ativa do Java por variáveis de ambiente do usuário.
- Baixa e descompacta IntelliJ IDEA Community 2026.1 em `USERPROFILE\\opt\\idea`.
- Cria atalho no Menu Iniciar para o IntelliJ.
- Configurações customizadas para o PowerShell

## Não faz parte do escopo Windows

Este fluxo **não** instala aplicações do script Linux, como Chrome, KeePassXC e DBeaver.

## Execução

No PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\install-all.ps1
```

## Comandos úteis

```powershell
# Instalar Java apenas
.\windows\install-java.ps1 -Versions 24,26

# Instalar certificados (Java + Chrome/Windows)
.\windows\install-certs.ps1

# Instalar certificados com InstallRoot customizado
.\windows\install-certs.ps1 -InstallRoot "D:\tools\java"

# Instalar certificados apenas no Java
.\windows\install-certs.ps1 -SkipChrome

# Instalar certificados apenas no store do Chrome/Windows
.\windows\install-certs.ps1 -SkipJava

# Listar certificados corp-* instalados em cada JDK
.\windows\remove-certs.ps1

# Simular remoção de um certificado (não altera nada)
.\windows\remove-certs.ps1 -Remove corp-meu-cert-1a2b3c4d -WhatIf

# Remover certificado de todas as JDKs (pede confirmação)
.\windows\remove-certs.ps1 -Remove corp-meu-cert-1a2b3c4d

# Remover certificado de uma JDK específica
.\windows\remove-certs.ps1 -Remove corp-meu-cert-1a2b3c4d -JdkName jdk-24

# Listar versões Java instaladas
.\windows\set-java-version.ps1 -List

# Alternar versão ativa do Java
.\windows\set-java-version.ps1 -Version 24
.\windows\set-java-version.ps1 -Version 26

# Instalar IntelliJ apenas
.\windows\install-intellij.ps1 -Version 2026.1
```
