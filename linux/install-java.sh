#!/bin/bash

echo "☕ ====================================================================="
echo "☕ CONFIGURANDO MÚLTIPLAS VERSÕES DO JAVA"
echo "☕ ====================================================================="

# Verifica se TMP_DIR foi definido pelo script principal, senão define um padrão
if [ -z "$TMP_DIR" ]; then
    TMP_DIR="tmp"
    mkdir -p $TMP_DIR
fi

# Define Java versions and their download URLs
declare -A JAVA_VERSIONS=(
    ["8"]="jdk1.8.0_451"
    ["11"]="jdk-11.0.27"
    ["12"]="jdk-12.0.2"
    ["14"]="jdk-14.0.2"
    ["17"]="jdk-17.0.15"
    ["21"]="jdk-21.0.7"
    ["24"]="jdk-24.0.1"
    ["25"]="jdk-25.0.2"
    ["26"]="jdk-26"
)

# Create Java installation directory
JAVA_INSTALL_DIR="/opt/java"
echo "📁 Criando diretório de instalação: $JAVA_INSTALL_DIR"
sudo mkdir -p $JAVA_INSTALL_DIR
echo ""

# Function to install Java version
install_java_version() {
    local version_key=$1
    local java_version=${JAVA_VERSIONS[$version_key]}
    local install_path="$JAVA_INSTALL_DIR/$java_version"
    
    echo "🔍 Verificando instalação do Java $version_key ($java_version)..."
    
    if [ -d "$install_path" ]; then
        echo "   ✅ Java $version_key já está instalado em $install_path"
    else
        echo "   🔄 Instalando Java $version_key..."
        
        # Download URLs for different Java versions
        case $version_key in
            "8")
                if [ -f "$TMP_DIR/jdk-8u451-linux-x64.tar.gz" ]; then
                    echo "   📦 Arquivo jdk-8u451-linux-x64.tar.gz encontrado, extraindo..."
                    sudo tar -xzf "$TMP_DIR/jdk-8u451-linux-x64.tar.gz" -C "$JAVA_INSTALL_DIR"
                    rm "$TMP_DIR/jdk-8u451-linux-x64.tar.gz"
                else
                    echo "   ⚠️  ATENÇÃO: Java 8 requer download manual do Oracle JDK devido ao acordo de licença."
                    echo "   📥 Por favor, baixe manualmente de: https://www.oracle.com/br/java/technologies/downloads/#java8-linux"
                    echo "   📂 E coloque o arquivo no diretório: $TMP_DIR/"
                fi
                ;;
            "11")
                if [ -f "$TMP_DIR/jdk-11.0.27_linux-x64_bin.tar.gz" ]; then
                    echo "   📦 Arquivo jdk-11.0.27_linux-x64_bin.tar.gz encontrado, extraindo..."
                    sudo tar -xzf "$TMP_DIR/jdk-11.0.27_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                    rm "$TMP_DIR/jdk-11.0.27_linux-x64_bin.tar.gz"
                else
                    echo "   ⚠️  ATENÇÃO: Java 11 requer download manual do Oracle JDK devido ao acordo de licença."
                    echo "   📥 Por favor, baixe manualmente de: https://www.oracle.com/br/java/technologies/downloads/#java11-linux"
                    echo "   📂 E coloque o arquivo no diretório: $TMP_DIR/"
                fi
                ;;
            "12")
                if [ -f "$TMP_DIR/jdk-12.0.2_linux-x64_bin.tar.gz" ]; then
                    echo "   📦 Arquivo jdk-12.0.2_linux-x64_bin.tar.gz encontrado, extraindo..."
                    sudo tar -xzf "$TMP_DIR/jdk-12.0.2_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                    rm "$TMP_DIR/jdk-12.0.2_linux-x64_bin.tar.gz"
                else
                    echo "   ⚠️  ATENÇÃO: Java 12 requer download manual do Oracle JDK devido ao acordo de licença."
                    echo "   📥 Por favor, baixe manualmente de: https://www.oracle.com/java/technologies/javase/jdk12-archive-downloads.html"
                    echo "   📂 E coloque o arquivo no diretório: $TMP_DIR/"
                fi
                ;;
            "14")
                if [ -f "$TMP_DIR/jdk-14.0.2_linux-x64_bin.tar.gz" ]; then
                    echo "   📦 Arquivo jdk-14.0.2_linux-x64_bin.tar.gz encontrado, extraindo..."
                    sudo tar -xzf "$TMP_DIR/jdk-14.0.2_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                    rm "$TMP_DIR/jdk-14.0.2_linux-x64_bin.tar.gz"
                else
                    echo "   ⚠️  ATENÇÃO: Java 14 requer download manual do Oracle JDK devido ao acordo de licença."
                    echo "   📥 Por favor, baixe manualmente de: https://www.oracle.com/java/technologies/javase/jdk14-archive-downloads.html"
                    echo "   📂 E coloque o arquivo no diretório: $TMP_DIR/"
                fi
                ;;
            "17")
                if [ -f "$TMP_DIR/jdk-17.0.15_linux-x64_bin.tar.gz" ]; then
                    echo "   📦 Arquivo jdk-17.0.15_linux-x64_bin.tar.gz encontrado, extraindo..."
                    sudo tar -xzf "$TMP_DIR/jdk-17.0.15_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                    rm "$TMP_DIR/jdk-17.0.15_linux-x64_bin.tar.gz"
                else
                    echo "   ⚠️  ATENÇÃO: Java 17 requer download manual do Oracle JDK devido ao acordo de licença."
                    echo "   📥 Por favor, baixe manualmente de: https://www.oracle.com/br/java/technologies/downloads/#java17-linux"
                    echo "   📂 E coloque o arquivo no diretório: $TMP_DIR/"
                fi
                ;;
            "21")
                echo "   🌐 Baixando Java 21 automaticamente..."
                wget -O "$TMP_DIR/jdk-21_linux-x64_bin.tar.gz" "https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"
                echo "   📦 Extraindo Java 21..."
                sudo tar -xzf "$TMP_DIR/jdk-21_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                rm "$TMP_DIR/jdk-21_linux-x64_bin.tar.gz"
                ;;
            "24")
                echo "   🌐 Baixando Java 24 automaticamente..."
                wget -O "$TMP_DIR/jdk-24_linux-x64_bin.tar.gz" "https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.tar.gz"
                echo "   📦 Extraindo Java 24..."
                sudo tar -xzf "$TMP_DIR/jdk-24_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                rm "$TMP_DIR/jdk-24_linux-x64_bin.tar.gz"
                ;;
            "25")
                echo "   🌐 Baixando Java 25 automaticamente..."
                wget -O "$TMP_DIR/jdk-25_linux-x64_bin.tar.gz" "https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"
                echo "   📦 Extraindo Java 25..."
                sudo tar -xzf "$TMP_DIR/jdk-25_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                rm "$TMP_DIR/jdk-25_linux-x64_bin.tar.gz"
                ;;
            "26")
                echo "   🌐 Baixando Java 26 automaticamente..."
                wget -O "$TMP_DIR/jdk-26_linux-x64_bin.tar.gz" "https://download.oracle.com/java/26/latest/jdk-26_linux-x64_bin.tar.gz"
                echo "   📦 Extraindo Java 26..."
                sudo tar -xzf "$TMP_DIR/jdk-26_linux-x64_bin.tar.gz" -C "$JAVA_INSTALL_DIR"
                rm "$TMP_DIR/jdk-26_linux-x64_bin.tar.gz"
                ;;
        esac
        
        if [ -d "$install_path" ]; then
            echo "   ✅ Java $version_key instalado com sucesso!"
        fi
    fi
    echo ""
}

# Install all Java versions
echo "🔄 Iniciando instalação de todas as versões do Java..."
echo ""
for version in "${!JAVA_VERSIONS[@]}"; do
    install_java_version $version
done
sudo chown -R $USER:$USER $JAVA_INSTALL_DIR

# Configure update-alternatives for installed Java versions
echo "⚙️  ====================================================================="
echo "⚙️  CONFIGURANDO UPDATE-ALTERNATIVES PARA VERSÕES DO JAVA"
echo "⚙️  ====================================================================="

configure_java_alternatives() {
    local version_key=$1
    local java_version=${JAVA_VERSIONS[$version_key]}
    local install_path="$JAVA_INSTALL_DIR/$java_version"
    local priority=$((800 + version_key))
    
    if [ -d "$install_path" ] && [ -x "$install_path/bin/java" ]; then
        echo "🔧 Configurando alternativas para Java $version_key..."
        
        # Configure java
        sudo update-alternatives --install /usr/bin/java java "$install_path/bin/java" $priority
        
        # Configure javac
        if [ -x "$install_path/bin/javac" ]; then
            sudo update-alternatives --install /usr/bin/javac javac "$install_path/bin/javac" $priority
        fi
        
        # Configure jar
        if [ -x "$install_path/bin/jar" ]; then
            sudo update-alternatives --install /usr/bin/jar jar "$install_path/bin/jar" $priority
        fi
        
        # Configure javadoc
        if [ -x "$install_path/bin/javadoc" ]; then
            sudo update-alternatives --install /usr/bin/javadoc javadoc "$install_path/bin/javadoc" $priority
        fi
        
        echo "   ✅ Alternativas configuradas para Java $version_key com prioridade $priority"
    else
        echo "   ⚠️  Java $version_key não encontrado em $install_path - pulando configuração"
    fi
    echo ""
}

# Configure alternatives for all installed Java versions
for version in "${!JAVA_VERSIONS[@]}"; do
    configure_java_alternatives $version
done

echo "✅ Configuração do Java concluída!"
echo ""

# Display current Java version
echo "📋 VERSÃO ATUAL DO JAVA:"
echo "───────────────────────────────────────────────────────────────────────"
java -version 2>&1 || echo "❌ Nenhuma versão do Java configurada como padrão"
echo ""
