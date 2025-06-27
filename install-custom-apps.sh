#!/bin/bash

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
if command -v dbeaver &> /dev/null; then
    echo "✅ DBeaver já está instalado."
else
    echo "🔄 Baixando e instalando DBeaver Community Edition..."
    
    # Get the latest DBeaver version
    echo "🌐 Obtendo informações da versão mais recente..."
    DBEAVER_LATEST=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    DBEAVER_VERSION=${DBEAVER_LATEST#v}
    
    echo "📦 Versão mais recente encontrada: $DBEAVER_VERSION"
    
    # Download DBeaver
    DBEAVER_URL="https://github.com/dbeaver/dbeaver/releases/download/$DBEAVER_LATEST/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb"
    echo "🔄 Baixando DBeaver $DBEAVER_VERSION..."
    wget -O $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb "$DBEAVER_URL"
    
    echo "🔧 Instalando pacote .deb..."
    sudo dpkg -i $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb
    
    echo "🔧 Corrigindo dependências..."
    sudo apt-get install -f -y
    
    rm -f $TMP_DIR/dbeaver-ce_${DBEAVER_VERSION}_amd64.deb
    echo "✅ DBeaver instalado com sucesso!"
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


