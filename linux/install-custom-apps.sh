#!/bin/bash

# Define temporary directory
TMP_DIR="${TMP_DIR:-./tmp}"
mkdir -p "$TMP_DIR"

print_usage() {
    echo "Uso: $0 <alvo> [opcoes]"
    echo ""
    echo "Alvos suportados:"
    echo "  chrome              Instala Google Chrome"
    echo "  dbeaver             Instala DBeaver (use --update para forcar atualizacao)"
    echo "  vmware-client       Instala Omnissa Horizon Client"
    echo "  keepass             Instala KeePassXC via Snap"
    echo "  terminator          Instala Terminator"
    echo "  bashrc-git-branch   Configura branch do Git no prompt do bash"
    echo "  docker              Instala Docker"
    echo ""
    echo "Aliases:"
    echo "  vmware, horizon     Equivalentes a vmware-client"
    echo "  git-branch, bashrc  Equivalentes a bashrc-git-branch"
    echo ""
    echo "Exemplos:"
    echo "  $0 dbeaver"
    echo "  $0 dbeaver --update"
    echo "  $0 docker"
    echo ""
    echo "Opcoes gerais:"
    echo "  -h, --help          Mostra esta ajuda"
}

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
    wget -O "$TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb" "$DBEAVER_URL"
    
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao baixar DBeaver"
        return 1
    fi
    
    echo "🔧 Instalando pacote .deb..."
    sudo dpkg -i "$TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb"
    
    echo "🔧 Corrigindo dependências..."
    sudo apt-get install -f -y
    
    rm -f "$TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb"
    echo "✅ DBeaver $DBEAVER_VERSION instalado com sucesso!"
    return 0
}

install_chrome() {
    echo "📦 ====================================================================="
    echo "📦 INSTALANDO GOOGLE CHROME"
    echo "📦 ====================================================================="
    if command -v google-chrome &> /dev/null; then
        echo "✅ Google Chrome já está instalado."
    else
        echo "🔄 Baixando e instalando Google Chrome..."
        wget -O "$TMP_DIR/google-chrome-stable_current_amd64.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        echo "🔧 Instalando pacote .deb..."
        sudo dpkg -i "$TMP_DIR/google-chrome-stable_current_amd64.deb"
        echo "🔧 Corrigindo dependências..."
        sudo apt-get install -f -y
        rm -f "$TMP_DIR/google-chrome-stable_current_amd64.deb"
        echo "✅ Google Chrome instalado com sucesso!"
    fi
    echo ""
}

install_dbeaver() {
    local update_dbeaver="$1"

    echo "🗄️ ====================================================================="
    echo "🗄️ INSTALANDO DBEAVER"
    echo "🗄️ ====================================================================="

    if command -v dbeaver &> /dev/null; then
        local installed_version
        installed_version=$(get_installed_dbeaver_version)

        if [ -n "$installed_version" ]; then
            echo "ℹ️  DBeaver versão $installed_version está instalado."
        else
            echo "ℹ️  DBeaver está instalado (versão não detectada)."
        fi

        if [ "$update_dbeaver" = "true" ]; then
            echo "🔄 Verificando atualizações do DBeaver..."

            DBEAVER_LATEST=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep "tag_name" | cut -d '"' -f 4)
            DBEAVER_LATEST_VERSION=${DBEAVER_LATEST#v}

            if [ -n "$installed_version" ] && [ "$installed_version" = "$DBEAVER_LATEST_VERSION" ]; then
                echo "✅ DBeaver já está na versão mais recente ($installed_version)"
            else
                echo "🔄 Atualizando DBeaver de $installed_version para $DBEAVER_LATEST_VERSION..."
                install_update_dbeaver
            fi
        else
            echo "💡 Use '$0 dbeaver --update' para atualizar o DBeaver"
        fi
    else
        echo "📦 DBeaver não está instalado. Instalando..."
        install_update_dbeaver
    fi
    echo ""
}

install_vmware_client() {
    echo "📦 ====================================================================="
    echo "📦 INSTALANDO VMWare Workstation Client"
    echo "📦 ====================================================================="
    if command -v horizon-client &> /dev/null; then
        echo "✅ VMWare Workstation Client já está instalado."
    else
        echo "🔄 Baixando e instalando VMWare Workstation Client..."
        wget -O "$TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb" https://download3.omnissa.com/software/CART26FQ1_LIN64_DEBPKG_2503/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb
        echo "🔧 Instalando pacote .deb..."
        sudo dpkg -i "$TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb"
        echo "🔧 Corrigindo dependências..."
        sudo apt-get install -f -y
        rm -f "$TMP_DIR/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb"
        echo "✅ VMWare Workstation Client instalado com sucesso!"
    fi
    echo ""
}

install_keepass() {
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
}

install_terminator() {
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
}

configure_bashrc_git_branch() {
    echo "⚙️ ====================================================================="
    echo "⚙️ CONFIGURANDO BASHRC PARA EXIBIR BRANCH DO GIT"
    echo "⚙️ ====================================================================="

    if grep -q "parse_git_branch" ~/.bashrc; then
        echo "✅ Configuração do git branch já existe no bashrc."
    else
        echo "🔄 Adicionando configuração do git branch no bashrc..."

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
}

install_docker() {
    echo "🐳 ====================================================================="
    echo "🐳 INSTALANDO DOCKER"
    echo "🐳 ====================================================================="

    if command -v docker &> /dev/null; then
        echo "✅ Docker já está instalado."
    else
        echo "🔄 Instalando Docker..."

        sudo apt remove -y docker docker-engine docker.io containerd runc

        sudo apt-get update

        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update

        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        sudo usermod -aG docker "$USER"

        echo "✅ Docker instalado com sucesso!"
        echo "ℹ️  Faça logout/login para aplicar o grupo docker na sessão atual."
    fi
    echo ""
}

if [ $# -eq 0 ]; then
    echo "❌ Erro: informe um alvo obrigatório."
    echo ""
    print_usage
    exit 1
fi

TARGET="$1"
shift

if [ "$TARGET" = "-h" ] || [ "$TARGET" = "--help" ] || [ "$TARGET" = "help" ]; then
    print_usage
    exit 0
fi

UPDATE_DBEAVER=false

while [ $# -gt 0 ]; do
    case "$1" in
        --update)
            UPDATE_DBEAVER=true
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "❌ Opção inválida: $1"
            print_usage
            exit 1
            ;;
    esac
done

if [ "$UPDATE_DBEAVER" = "true" ] && [ "$TARGET" != "dbeaver" ]; then
    echo "❌ A opção --update só pode ser usada com o alvo dbeaver."
    exit 1
fi

case "$TARGET" in
    chrome)
        install_chrome
        ;;
    dbeaver)
        install_dbeaver "$UPDATE_DBEAVER"
        ;;
    vmware-client|vmware|horizon)
        install_vmware_client
        ;;
    keepass)
        install_keepass
        ;;
    terminator)
        install_terminator
        ;;
    bashrc-git-branch|git-branch|bashrc)
        configure_bashrc_git_branch
        ;;
    docker)
        install_docker
        ;;
    *)
        echo "❌ Alvo inválido: $TARGET"
        echo ""
        print_usage
        exit 1
        ;;
esac