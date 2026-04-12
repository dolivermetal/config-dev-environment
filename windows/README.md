# Windows - Ambiente de Desenvolvimento

Scripts PowerShell para instalação no Windows com escopo controlado.

## Escopo

- Instala Java OpenJDK nas versões 24 e 26.
- Permite alternar versão ativa do Java por variáveis de ambiente do usuário.
- Baixa e descompacta IntelliJ IDEA Community 2026.1 em `USERPROFILE\\opt\\idea`.
- Cria atalho no Menu Iniciar para o IntelliJ.

## Não faz parte do escopo Windows

Este fluxo **não** instala aplicações do script Linux, como Chrome, KeePassXC, DBeaver e certificados.

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

# Listar versões Java instaladas
.\windows\set-java-version.ps1 -List

# Alternar versão ativa do Java
.\windows\set-java-version.ps1 -Version 24
.\windows\set-java-version.ps1 -Version 26

# Instalar IntelliJ apenas
.\windows\install-intellij.ps1 -Version 2026.1
```
