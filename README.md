# Ambiente de Desenvolvimento - Scripts de Configuração

Este repositório contém scripts automatizados para configuração de ambiente de desenvolvimento, com trilhas separadas por sistema operacional.

## 📁 Estrutura do Projeto

```
config-dev-environment/
├── linux/
│   ├── install-all.sh          # Script principal (orquestrador)
│   ├── install-certs.sh        # Importação de certificados SSL
|   ├── install-custom-apps.sh  # Instalação de softwares diversos
│   ├── install-intellij.sh     # Instalação de múltiplas versões do IntelliJ IDEA
│   ├── install-java.sh         # Instalação de múltiplas versões do Java
|   └── README.md               # Documentacao da trilha Linux
├── windows/
│   ├── install-all.ps1         # Orquestrador Windows
│   ├── install-java.ps1        # Instala Java 24 e 26 (OpenJDK)
│   ├── set-java-version.ps1    # Alterna JAVA_HOME/PATH do usuario
│   ├── install-intellij.ps1    # Instala IntelliJ 2026.1 + atalho no Menu Iniciar
│   └── README.md               # Documentacao da trilha Windows
├── certs/                      # Certificados SSL corporativos
└── tmp/                        # Diretório temporário para downloads
```

## 🚀 Escolha do Sistema Operacional

### Linux

Use os scripts em `linux/`.

```bash
./linux/install-all.sh
```

Fluxo Linux atual instala:
- Aplicacoes adicionais (Chrome, KeePassXC, DBeaver e outras do script Linux)
- Java (multiplas versoes)
- IntelliJ IDEA (multiplas versoes)
- Certificados SSL corporativos

### Windows

No Windows, o escopo foi limitado para Java e IntelliJ.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\install-all.ps1
```

Fluxo Windows instala:
- Java Temurin/OpenJDK nas versoes 24 e 26
- Comando para alternar versao ativa do Java (JAVA_HOME e PATH do usuario)
- IntelliJ IDEA Community 2026.1 em USERPROFILE\opt\idea
- Atalho executavel no Menu Iniciar

Fluxo Windows nao instala:
- Chrome, KeePassXC, DBeaver, certificados SSL e demais aplicativos do fluxo Linux

## 🎯 Comandos Uteis

### Linux

```bash
# Selecionar versao do Java
sudo update-alternatives --config java

# Ver versoes disponiveis
update-alternatives --list java

# Verificar certificados
keytool -list -keystore $JAVA_HOME/lib/security/cacerts
```

### Windows

```powershell
# Instalar apenas Java
.\windows\install-java.ps1 -Versions 24,26

# Listar versoes Java instaladas
.\windows\set-java-version.ps1 -List

# Alternar Java ativo
.\windows\set-java-version.ps1 -Version 24
.\windows\set-java-version.ps1 -Version 26

# Instalar apenas IntelliJ
.\windows\install-intellij.ps1 -Version 2026.1
```

## 🔧 Requisitos

### Linux
- Ubuntu/Debian (testado no Ubuntu)
- Acesso sudo
- Conexao com internet
- Bash 4.0+ (arrays associativos)

### Windows
- Windows com PowerShell 5.1+
- Conexao com internet
- Permissao para executar scripts na sessao atual (`Set-ExecutionPolicy -Scope Process Bypass`)

## 📜 Licença

Scripts desenvolvidos para uso pessoal.

## 🤝 Contribuições

Para adicionar novas funcionalidades ou corrigir problemas:

1. Teste as mudanças em ambiente isolado
2. Mantenha a modularidade dos scripts
3. Adicione logs informativos
4. Documente novos parâmetros e funções

Estas funcionalidades tornam o sistema de instalação mais robusto e facilita a manutenção de ambientes com múltiplas versões de software.
