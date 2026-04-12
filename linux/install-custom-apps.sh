#!/bin/bash

# Define temporary directory
TMP_DIR="../tmp"
mkdir -p "$TMP_DIR"

# Parse command line arguments
UPDATE_DBEAVER=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --update-dbeaver)
      UPDATE_DBEAVER=true
      echo "🔄 Modo de atualização do DBeaver ativado"
      shift
      ;;
    --help|-h)
      echo "Uso: $0 [--update-dbeaver] [--help|-h]"
      echo "  --update-dbeaver    Força a atualização do DBeaver para a versão mais recente"
      echo "  --help, -h          Mostra esta ajuda"
      exit 0
      ;;
    *)
      echo "⚠️  Parâmetro desconhecido: $1"
      echo "Use --help para ver opções disponíveis"
      shift
      ;;
  esac
done

# Install Google Chrome
echo "📦 ====================================================================="
echo "📦 INSTALANDO GOOGLE CHROME"
echo "📦 ====================================================================="
if command -v google-chrome &> /dev/null; then
    echo "✅ Google Chrome já está instalado."
else
    echo "🔄 Baixando e instalando Google Chrome..."
    wget -O $TMP_DIR/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    echo "🔧 Instalando pacote .deb..."
    sudo dpkg -i $TMP_DIR/google-chrome-stable_current_amd64.deb
    echo "🔧 Corrigindo dependências..."
    sudo apt-get install -f
    rm -f $TMP_DIR/google-chrome-stable_current_amd64.deb
    echo "✅ Google Chrome instalado com sucesso!"
fi
echo ""


# Install DBeaver
echo "🗄️ ====================================================================="
echo "🗄️ INSTALANDO DBEAVER"
echo "🗄️ ====================================================================="

# Function to get installed DBeaver version
get_installed_dbeaver_version() {
    if command -v dbeaver &> /dev/null; then
        local version=""
        
        # Try different version commands
        version=$(dbeaver -V 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -n1)
        
        if [ -z "$version" ]; then
            version=$(dbeaver --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -n1)
        fi
        
        if [ -z "$version" ]; then
            version=$(dbeaver -version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -n1)
        fi
        
        # Try to get version from dpkg if commands fail
        if [ -z "$version" ]; then
            version=$(dpkg -l | grep dbeaver-ce | awk '{print $3}' | grep -oP '\d+\.\d+\.\d+' | head -n1)
        fi
        
        echo "$version"
    else
        echo ""
    fi
}

# Function to install/update DBeaver
install_update_dbeaver() {
    # Get the latest DBeaver version
    echo "🌐 Obtendo informações da versão mais recente..."
    DBEAVER_LATEST=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    DBEAVER_VERSION=${DBEAVER_LATEST#v}
    
    echo "📦 Versão mais recente disponível: $DBEAVER_VERSION"
    
    # Download DBeaver
    DBEAVER_URL="https://github.com/dbeaver/dbeaver/releases/download/$DBEAVER_LATEST/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb"
    echo "🔄 Baixando DBeaver $DBEAVER_VERSION..."
    wget -O $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb "$DBEAVER_URL"
    
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao baixar DBeaver"
        return 1
    fi
    
    echo "🔧 Instalando pacote .deb..."
    sudo dpkg -i $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb
    
    echo "🔧 Corrigindo dependências..."
    sudo apt-get install -f -y
    
    rm -f $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb
    echo "✅ DBeaver $DBEAVER_VERSION instalado com sucesso!"
    return 0
}

# Check if DBeaver is installed
if command -v dbeaver &> /dev/null; then
    INSTALLED_VERSION=$(get_installed_dbeaver_version)
    
    if [ -n "$INSTALLED_VERSION" ]; then
        echo "ℹ️  DBeaver versão $INSTALLED_VERSION está instalado."
    else
        echo "ℹ️  DBeaver está instalado (versão não detectada)."
    fi
    
    # Check if update is requested
    if [ "$UPDATE_DBEAVER" = true ]; then
        echo "🔄 Verificando atualizações do DBeaver..."
        
        # Get latest version
        DBEAVER_LATEST=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep "tag_name" | cut -d '"' -f 4)
        DBEAVER_LATEST_VERSION=${DBEAVER_LATEST#v}
        
        if [ -n "$INSTALLED_VERSION" ] && [ "$INSTALLED_VERSION" = "$DBEAVER_LATEST_VERSION" ]; then
            echo "✅ DBeaver já está na versão mais recente ($INSTALLED_VERSION)"
        else
            echo "🔄 Atualizando DBeaver de $INSTALLED_VERSION para $DBEAVER_LATEST_VERSION..."
            install_update_dbeaver
        fi
    else
        echo "💡 Use --update-dbeaver para atualizar o DBeaver"
    fi
else
    echo "📦 DBeaver não está instalado. Instalando..."
    install_update_dbeaver
fi
echo ""


# Install VMWare Workstation Client
echo "📦 ====================================================================="
echo "📦 INSTALANDO VMWare Workstation Client"
echo "📦 ====================================================================="
if command -v horizon-client &> /dev/null; then
    echo "✅ VMWare Workstation Client já está instalado."
else
    echo "🔄 Baixando e instalando VMWare Workstation Client..."
    wget -O $TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb https://download3.omnissa.com/software/CART26FQ1_LIN64_DEBPKG_2503/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb
    echo "🔧 Instalando pacote .deb..."
    sudo dpkg -i $TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb
    echo "🔧 Corrigindo dependências..."
    sudo apt-get install -f
    rm -f $TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb
    echo "✅ VMWare Workstation Client instalado com sucesso!"
fi
echo ""


# Install KeePass
echo "🔐 ====================================================================="
echo "🔐 INSTALANDO KEEPASS"
echo "🔐 ====================================================================="
if command -v keepassxc &> /dev/null; then
    echo "✅ KeePass já está instalado."
else
    echo "🔄 Instalando KeePass via Snap..."
    sudo snap install keepassxc
    echo "✅ KeePass instalado com sucesso!"
fi
echo ""


# Install Terminator
echo "🖥️ ====================================================================="
echo "🖥️ INSTALANDO TERMINATOR"
echo "🖥️ ====================================================================="
if command -v terminator &> /dev/null; then
    echo "✅ Terminator já está instalado."
else
    echo "🔄 Instalando Terminator..."
    sudo apt-get update
    sudo apt-get install -y terminator
    echo "✅ Terminator instalado com sucesso!"
fi
echo ""


# Configure bashrc to show git branch
echo "⚙️ ====================================================================="
echo "⚙️ CONFIGURANDO BASHRC PARA EXIBIR BRANCH DO GIT"
echo "⚙️ ====================================================================="

# Check if git branch function already exists in bashrc
if grep -q "parse_git_branch" ~/.bashrc; then
    echo "✅ Configuração do git branch já existe no bashrc."
else
    echo "🔄 Adicionando configuração do git branch no bashrc..."
    
    # Add git branch function and PS1 configuration
    cat >> ~/.bashrc << 'EOF'

# Function to get current git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Custom PS1 with git branch support (preserving default colors)
export PS1="\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]$ "
EOF
    
    echo "✅ Configuração do git branch adicionada ao bashrc!"
    echo "ℹ️  Reinicie o terminal ou execute 'source ~/.bashrc' para aplicar as mudanças."
fi
echo ""


# Install Docker
echo "🐳 =====================================================================
echo "🐳 INSTALANDO DOCKER"
echo "🐳 =====================================================================

# Check if Docker is already installed"
if command -v docker &> /dev/null; then
    echo "✅ Docker já está instalado."
else
    echo "🔄 Instalando Docker..."
    
    # Uninstall any old versions of Docker
    sudo apt remove docker docker-engine docker.io containerd runc

    # Update package index
    sudo apt-get update
    
    # Install required packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine, CLI, and Containerd
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Add current user to the docker group
    sudo usermod -aG docker $USER
    newgrp docker

    echo "✅ Docker instalado com sucesso!"
fi