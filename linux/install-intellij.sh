#!/bin/bash

echo "💡 ====================================================================="
echo "💡 INSTALANDO INTELLIJ IDEA COMMUNITY EDITIONS"
echo "💡 ====================================================================="

# Verifica se TMP_DIR foi definido pelo script principal, senão define um padrão
if [ -z "$TMP_DIR" ]; then
    TMP_DIR="../tmp"
    mkdir -p $TMP_DIR
fi

# Create IntelliJ installation directory
IDEA_INSTALL_DIR="/opt/idea"
echo "📁 Criando diretório de instalação: $IDEA_INSTALL_DIR"
sudo mkdir -p $IDEA_INSTALL_DIR
sudo chown $USER:$USER $IDEA_INSTALL_DIR
echo ""

# Define IntelliJ versions
declare -A IDEA_VERSIONS=(
    ["2019.1.4"]="https://download.jetbrains.com/idea/ideaIC-2019.1.4.tar.gz"
    ["2025.1.3"]="https://download.jetbrains.com/idea/ideaIC-2025.1.3.tar.gz"
)

# Function to install IntelliJ version
install_idea_version() {
    local version=$1
    local download_url=$2
    local install_path="$IDEA_INSTALL_DIR/idea-IC-$version"
    
    # Set friendly names for versions
    echo "🔍 Verificando instalação do IntelliJ IDEA $version no diretório $install_path..."

    if [ -d "$install_path" ]; then
        echo "   ✅ IntelliJ IDEA $version já está instalado em $install_path"
    else
        echo "   🔄 Instalando IntelliJ IDEA $version..."
        
        # Download IntelliJ
        echo "   🌐 Baixando IntelliJ IDEA $version..."
        wget -O "$TMP_DIR/ideaIC-$version.tar.gz" "$download_url"
        
        if [ $? -eq 0 ]; then
            echo "📁 Criando diretório de instalação: $install_path"
            sudo mkdir -p $install_path
            echo ""

            echo "   📦 Extraindo IntelliJ IDEA $version..."
            sudo tar -xzf "$TMP_DIR/ideaIC-$version.tar.gz" -C "$install_path"
            sudo chown -R $USER:$USER "$install_path"
            
            # Validate installation
            if [ -d "$install_path" ]; then
                echo "   ✅ IntelliJ IDEA $version instalado com sucesso!"
            else
                echo "   ❌ Erro na instalação do IntelliJ IDEA $version"
            fi
            
            rm -f "$TMP_DIR/ideaIC-$version.tar.gz"
        else
            echo "   ❌ Erro ao baixar IntelliJ IDEA $version"
        fi
    fi
    echo ""
}

# Install all IntelliJ versions
echo "🔄 Iniciando instalação das versões do IntelliJ IDEA..."
echo ""
for version in "${!IDEA_VERSIONS[@]}"; do
    install_idea_version "$version" "${IDEA_VERSIONS[$version]}"
done

# Create symbolic links and desktop entries for easy access
echo "🔗 Criando links simbólicos e ícones no menu de aplicativos..."
echo ""

# Create links in /usr/local/bin
sudo mkdir -p /usr/local/bin

# Create applications directory for desktop entries
sudo mkdir -p /usr/share/applications

for version in "${!IDEA_VERSIONS[@]}"; do
    install_path="$IDEA_INSTALL_DIR/idea-IC-$version"

    for folder in "$install_path"/*; do
        if [[ -d "$folder" && -f "$folder/bin/idea.sh" ]]; then
            version_name=$(basename "$folder")
            break
        fi
    done
    
    if [ -d "$install_path" ] && [ -x "$install_path/$version_name/bin/idea.sh" ]; then
        # Create version-specific symbolic links
        sudo ln -sf "$install_path/$version_name/bin/idea.sh" "/usr/local/bin/idea-$version"
        echo "   🔗 Link criado: idea-$version → $install_path/$version_name/bin/idea.sh"

        # Create desktop entry for menu integration
        desktop_file="/usr/share/applications/intellij-idea-$version_name.desktop"
        sudo tee "$desktop_file" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community $version
Comment=IntelliJ IDEA Community Edition $version
Exec=$install_path/$version_name/bin/idea.sh %f
Icon=$install_path/$version_name/bin/idea.png
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea-ce
MimeType=text/x-java;text/x-scala;application/x-shellscript;text/plain;
EOF
        
        # Make desktop file executable
        sudo chmod +x "$desktop_file"
        
        echo "   🖥️  Ícone criado: IntelliJ IDEA Community $version"
        
    else
        echo "   ❌ IntelliJ IDEA $version não encontrado, pulando criação de links e ícones"
    fi
done

echo ""
echo "✅ Configuração do IntelliJ IDEA concluída!"
echo ""
echo "📋 Acesso disponível via:"
echo "───────────────────────────────────────────────────────────────────────"
echo "   �️  Menu de Aplicativos:"
echo "       - IntelliJ IDEA Community 2019.1.4"
echo "       - IntelliJ IDEA Community 2025.1.3"
echo ""
echo "   🚀 Linha de comando:"
echo "       - idea-2019.1.4          # Versão 2019.1.4"
echo "       - idea-2025.1.3          # Versão 2025.1.3"
echo ""
echo "💡 Agora você pode abrir o IntelliJ diretamente pelo menu de aplicativos!"
echo ""