# Windows - Ambiente de Desenvolvimento

Scripts PowerShell para instalação no Windows com escopo controlado.

## Escopo

- Instala Java OpenJDK nas versões 21, 25 e 26.
- Importa certificados de `..\\certs` para todas as JDKs instaladas.
- Importa certificados para o store `CurrentUser\\Root` do Windows (usado pelo Chrome).
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

# Listar versões Java instaladas
.\windows\set-java-version.ps1 -List

# Alternar versão ativa do Java
.\windows\set-java-version.ps1 -Version 24
.\windows\set-java-version.ps1 -Version 26

# Instalar IntelliJ apenas
.\windows\install-intellij.ps1 -Version 2026.1
```
