#!/bin/bash

echo "🚀 ====================================================================="
echo "🚀          SCRIPT DE INSTALAÇÃO DO AMBIENTE DE DESENVOLVIMENTO"
echo "🚀 ====================================================================="
echo ""

TMP_DIR="tmp"
mkdir -p $TMP_DIR

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


# Install IntelliJ IDEA Versions
echo "💡 ====================================================================="
echo "💡 EXECUTANDO INSTALAÇÃO DO INTELLIJ IDEA"
echo "💡 ====================================================================="

INTELLIJ_SCRIPT="./install-intellij.sh"

if [ -f "$INTELLIJ_SCRIPT" ]; then
    echo "✅ Script de instalação do IntelliJ encontrado: $INTELLIJ_SCRIPT"
    echo "🔄 Executando instalação e configuração do IntelliJ IDEA..."
    echo ""
    
    # Make the script executable
    chmod +x "$INTELLIJ_SCRIPT"
    
    # Export TMP_DIR so the IntelliJ script can use it
    export TMP_DIR
    
    # Run the IntelliJ installation script
    bash "$INTELLIJ_SCRIPT"
    
    echo "✅ Instalação do IntelliJ IDEA concluída!"
else
    echo "❌ Script de instalação do IntelliJ não encontrado em: $INTELLIJ_SCRIPT"
    echo "   � Por favor, verifique se o arquivo existe e tente novamente."
fi
echo ""


# Install Java Versions
echo "☕ ====================================================================="
echo "☕ EXECUTANDO INSTALAÇÃO DO JAVA"
echo "☕ ====================================================================="

JAVA_SCRIPT="./install-java.sh"

if [ -f "$JAVA_SCRIPT" ]; then
    echo "✅ Script de instalação do Java encontrado: $JAVA_SCRIPT"
    echo "🔄 Executando instalação e configuração do Java..."
    echo ""
    
    # Make the script executable
    chmod +x "$JAVA_SCRIPT"
    
    # Export TMP_DIR so the Java script can use it
    export TMP_DIR
    
    # Run the Java installation script
    bash "$JAVA_SCRIPT"
    
    echo "✅ Instalação do Java concluída!"
else
    echo "❌ Script de instalação do Java não encontrado em: $JAVA_SCRIPT"
    echo "   � Por favor, verifique se o arquivo existe e tente novamente."
fi
echo ""


# Install SSL Certificates
echo "🔒 ====================================================================="
echo "🔒 CONFIGURANDO CERTIFICADOS SSL"
echo "🔒 ====================================================================="

# Define certificate installation directory
CERT_SCRIPT_DIR="./certs"
CERT_INSTALL_SCRIPT="install-certs.sh"

# Check if certificate installation script exists
if [ -f "$CERT_INSTALL_SCRIPT" ]; then
    echo "✅ Script de instalação de certificados encontrado: $CERT_INSTALL_SCRIPT"
    echo ""
    
    # List of certificates found in the directory
    CERTIFICATES=(
        $(ls $CERT_SCRIPT_DIR/*.cer | xargs -n 1 basename)
    )
    
    echo "📋 Certificados disponíveis para instalação:"
    echo "───────────────────────────────────────────────────────────────────────"
    for cert in "${CERTIFICATES[@]}"; do
        if [ -f "$CERT_SCRIPT_DIR/$cert" ]; then
            echo "   ✅ $cert"
        else
            echo "   ❌ $cert (arquivo não encontrado)"
        fi
    done
    
    echo "🔄 Executando instalação de certificados..."
        
    # Make the script executable
    chmod +x "$CERT_INSTALL_SCRIPT"
    
    # Run the certificate installation script from current directory
    bash "$CERT_INSTALL_SCRIPT"
    
    echo "✅ Instalação de certificados concluída!"
else
    echo "❌ Script de instalação de certificados não encontrado em: $CERT_INSTALL_SCRIPT"
    echo "   📂 Por favor, verifique se o arquivo existe e tente novamente."
fi
echo ""

echo "🎉 ====================================================================="
echo "🎉 CONFIGURAÇÃO DO AMBIENTE DE DESENVOLVIMENTO CONCLUÍDA!"
echo "🎉 ====================================================================="
echo ""
echo "📋 RESUMO DAS INSTALAÇÕES:"
echo "───────────────────────────────────────────────────────────────────────"
echo "   ✅ Google Chrome"
echo "   ✅ KeePass"
echo "   ✅ DBeaver Community Edition"
echo "   ✅ IntelliJ IDEA Community (2019.1.4 e 2024.3.2)"
echo "   ✅ Múltiplas versões do Java (8, 11, 12, 17, 21, 24)"
echo "   ✅ Certificados SSL corporativos"
echo ""
echo "🔧 COMANDOS ÚTEIS:"
echo "───────────────────────────────────────────────────────────────────────"
echo "   📌 Selecionar versão do Java:"
echo "      sudo update-alternatives --config java"
echo ""
echo "   📌 Verificar certificados instalados:"
echo "      keytool -list -keystore \$JAVA_HOME/lib/security/cacerts"
echo ""
echo "   📌 Ver versões do Java disponíveis:"
echo "      update-alternatives --list java"
echo ""
echo "   📌 Executar IntelliJ IDEA:"
echo "      idea-2019.1.4          # Versão 2019.1.4"
echo "      idea-2024.3.2          # Versão 2024.3.2"
echo ""
echo "🚀 Ambiente de desenvolvimento pronto para uso!"
echo ""