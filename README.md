# Ambiente de Desenvolvimento - Scripts de Configuração

Este repositório contém scripts automatizados para configuração completa de um ambiente de desenvolvimento.

## 📁 Estrutura do Projeto

```
config-dev-environment/
├── install-all.sh          # Script principal (orquestrador)
├── install-java.sh         # Instalação de múltiplas versões do Java
├── install-intellij.sh     # Instalação de múltiplas versões do IntelliJ IDEA
├── install-certs.sh        # Importação de certificados SSL
├── certs/                  # Certificados SSL corporativos
│   ├── *.cer
└── tmp/                    # Diretório temporário para downloads
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
- Múltiplas versões do Java (8, 11, 12, 17, 21, 24)
- IntelliJ IDEA Community (versões 2019.1.4 e 2024.3.2)
- Certificados SSL corporativos

### 2. Script de Java (`install-java.sh`)

Instala e configura múltiplas versões do Java com `update-alternatives`:

```bash
./install-java.sh
```

**Versões instaladas:**
- 8, 11, 12, 17, 21, 24
- Configuração automática com `update-alternatives`

### 3. Script do IntelliJ (`install-intellij.sh`)

Instala múltiplas versões do IntelliJ IDEA com integração ao desktop:

```bash
./install-intellij.sh
```

**Recursos:**
- Instalação de versões específicas (2019.1.4 e 2024.3.2)
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
idea-2024.3.2          # Versão 2024.3.2
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
    ["191.8026.42"]="https://download.jetbrains.com/idea/ideaIC-2019.1.4.tar.gz"
    ["251.26094.121"]="https://download.jetbrains.com/idea/ideaIC-2024.3.2.tar.gz"
    # Nova versão
    ["XXX.XXXXX.XXX"]="https://download.jetbrains.com/idea/ideaIC-NOVA.tar.gz"
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

## 📜 Licença

Scripts desenvolvidos para uso pessoal.

## 🤝 Contribuições

Para adicionar novas funcionalidades ou corrigir problemas:

1. Teste as mudanças em ambiente isolado
2. Mantenha a modularidade dos scripts
3. Adicione logs informativos
4. Documente novos parâmetros e funções

Estas funcionalidades tornam o sistema de instalação mais robusto e facilita a manutenção de ambientes com múltiplas versões de software.
