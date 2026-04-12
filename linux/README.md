# Ambiente de Desenvolvimento - Scripts de Configuração

Este repositório contém scripts automatizados para configuração completa de um ambiente de desenvolvimento.

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
└── tmp/                        # Diretório temporário para downloads
```

## 🚀 Scripts Principais

### 1. Script Principal (`install-all.sh`)

Script orquestrador que executa toda a configuração do ambiente:

```bash
./install-all.sh
```

**Instala:**
- Google Chrome (se não estiver instalado)
- KeePassXC (via snap)
- DBeaver Community Edition (última versão)
- Múltiplas versões do Java (8, 11, 12, 14, 17, 21, 24)
- IntelliJ IDEA Community (versões 2019.1.4 e 2025.1.3)
- Certificados SSL corporativos

### 2. Script de Java (`install-java.sh`)

Instala e configura múltiplas versões do Java com `update-alternatives`:

```bash
./install-java.sh
```

**Versões instaladas:**
- 8, 11, 12, 14, 17, 21, 24
- Configuração automática com `update-alternatives`

### 3. Script do IntelliJ (`install-intellij.sh`)

Instala múltiplas versões do IntelliJ IDEA com integração ao desktop:

```bash
./install-intellij.sh
```

**Recursos:**
- Instalação de versões específicas (2019.1.4 e 2025.1.3)
- Criação de links simbólicos em `/usr/local/bin`
- Criação de ícones no menu de aplicativos
- Detecção dinâmica de versões instaladas

### 4. Script de Certificados (`install-certs.sh`)

Importa certificados SSL em todas as versões do Java:

```bash
./install-certs.sh
```

**Características:**
- Validação de existência dos certificados
- Importação dos certificados no Ubuntu
- Importação dos certificados no Chrome
- Importação em todas as versões do Java
- Logs detalhados do processo


## 🎯 Comandos Úteis Pós-Instalação

### Java
```bash
# Selecionar versão do Java
sudo update-alternatives --config java

# Ver versões disponíveis
update-alternatives --list java

# Verificar certificados
keytool -list -keystore $JAVA_HOME/lib/security/cacerts
```

### IntelliJ IDEA
```bash
# Executar versões específicas
idea-2019.1.4          # Versão 2019.1.4
idea-2025.1.3          # Versão 2025.1.3
```

## 🛠️ Personalização

### Adicionar Nova Versão do Java
Edite `install-java.sh` e adicione a versão ao array:
```bash
declare -A JAVA_VERSIONS=(
    ["8"]="openjdk-8-jdk"
    ["11"]="openjdk-11-jdk"
    # ... versões existentes
    ["25"]="openjdk-25-jdk"  # Nova versão
)
```

### Adicionar Nova Versão do IntelliJ
Edite `install-intellij.sh` e adicione ao array:
```bash
declare -A IDEA_VERSIONS=(
    ["2019.1.4"]="https://download.jetbrains.com/idea/ideaIC-2019.1.4.tar.gz"
    ["2025.1.3"]="https://download.jetbrains.com/idea/ideaIC-2025.1.3.tar.gz"
    # Nova versão
    ["XXXX.X.X"]="https://download.jetbrains.com/idea/ideaIC-NOVA.tar.gz"
)
```

## 📝 Logs e Diagnósticos

### Verificar Instalações
```bash
# Status das instalações
which google-chrome
which keepassxc
which dbeaver
which java
which idea

# Versões instaladas
java -version
google-chrome --version
```

## 🔧 Requisitos

- Ubuntu/Debian (testado no Ubuntu)
- Acesso sudo
- Conexão com internet
- Bash 4.0+ (para arrays associativos)
