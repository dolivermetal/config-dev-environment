#!/bin/bash

# Pasta com os certificados
CERT_DIR="../certs"
STOREPASS="changeit"

# Diretórios de certificados do sistema
SYSTEM_CERT_DIR="/usr/local/share/ca-certificates"
NSS_DB_DIR="$HOME/.pki/nssdb"

# Verifica se há certificados
if [ ! -d "$CERT_DIR" ]; then
  echo "❌ A pasta '$CERT_DIR' não existe. Crie-a e coloque os certificados .cer ou .crt nela."
  exit 1
fi

echo "🔍 Buscando versões de Java instaladas via update-alternatives..."

# Lista de caminhos de Java
mapfile -t JAVA_PATHS < <(update-alternatives --list java | sed 's|/bin/java||' | sort -u)

if [ ${#JAVA_PATHS[@]} -eq 0 ]; then
  echo "❌ Nenhuma JDK encontrada via update-alternatives."
  exit 1
fi

echo "📦 Encontradas ${#JAVA_PATHS[@]} versões de Java:"
for path in "${JAVA_PATHS[@]}"; do
  echo "   ☕ $(basename $path)"
echo ""

# Função para instalar certificados na JRE do DBeaver
install_certs_dbeaver() {
  echo "🦫 Procurando instalação do DBeaver..."

  # Tenta localizar o executável do DBeaver
  local dbeaver_path=""
  if command -v dbeaver &> /dev/null; then
    dbeaver_path=$(readlink -f "$(command -v dbeaver)")
  elif [ -d "/opt/dbeaver" ]; then
    dbeaver_path="/opt/dbeaver/dbeaver"
  elif [ -d "$HOME/.local/share/DBeaver" ]; then
    dbeaver_path="$HOME/.local/share/DBeaver/dbeaver"
  fi

  if [ -z "$dbeaver_path" ] || [ ! -e "$dbeaver_path" ]; then
    echo "   ❌ DBeaver não encontrado no sistema."
    return 1
  fi

  # Tenta localizar a JRE interna do DBeaver
  local dbeaver_dir="$(dirname "$dbeaver_path")"
  local dbeaver_jre=""
  if [ -d "$dbeaver_dir/jre" ]; then
    dbeaver_jre="$dbeaver_dir/jre"
  elif [ -d "$dbeaver_dir/../jre" ]; then
    dbeaver_jre="$dbeaver_dir/../jre"
  fi

  if [ -z "$dbeaver_jre" ] || [ ! -d "$dbeaver_jre" ]; then
    echo "   ❌ JRE interna do DBeaver não encontrada."
    return 1
  fi

  echo "   ✅ DBeaver encontrado em: $dbeaver_path"
  echo "   ☕ JRE do DBeaver: $dbeaver_jre"

  # Instala os certificados na JRE do DBeaver
  install_certs_for_java "$dbeaver_jre"
}
done
echo ""

# Função para instalar certificados no sistema Ubuntu
install_certs_system() {
  echo "🐧 Instalando certificados no sistema Ubuntu..."
  
  local cert_installed=0
  local cert_skipped=0
  
  # Criar diretório de certificados do sistema se não existir
  sudo mkdir -p "$SYSTEM_CERT_DIR"
  
  for cert in "$CERT_DIR"/*.crt "$CERT_DIR"/*.cer; do
    [ -e "$cert" ] || continue
    
    filename=$(basename -- "$cert")
    # Remover extensão e garantir que termine com .crt
    aliasname="${filename%.*}"
    system_cert_name="${aliasname}.crt"
    system_cert_path="$SYSTEM_CERT_DIR/$system_cert_name"
    
    # Verificar se o certificado já existe no sistema
    if [ -f "$system_cert_path" ]; then
      echo "   ⏭️  $filename (já existe no sistema)"
      ((cert_skipped++))
    else
      echo "   📄 Instalando $filename no sistema..."
      
      # Copiar certificado para o diretório do sistema
      if sudo cp "$cert" "$system_cert_path"; then
        echo "   ✅ $filename copiado para $system_cert_path"
        ((cert_installed++))
      else
        echo "   ❌ Erro ao copiar $filename"
      fi
    fi
  done
  
  # Atualizar certificados do sistema
  if [ $cert_installed -gt 0 ]; then
    echo "   🔄 Atualizando certificados do sistema..."
    if sudo update-ca-certificates; then
      echo "   ✅ Certificados do sistema atualizados"
    else
      echo "   ❌ Erro ao atualizar certificados do sistema"
    fi
  fi
  
  echo "   📊 Sistema - Instalados: $cert_installed | Ignorados: $cert_skipped"
  echo ""
  return 0
}

# Função para instalar certificados no Chrome/Chromium (NSS)
install_certs_chrome() {
  echo "🌐 Instalando certificados para Chrome/Chromium..."
  
  local cert_installed=0
  local cert_skipped=0
  
  # Verificar se certutil está disponível
  if ! command -v certutil &> /dev/null; then
    echo "   📦 Instalando libnss3-tools (necessário para certutil)..."
    if sudo apt-get update && sudo apt-get install -y libnss3-tools; then
      echo "   ✅ libnss3-tools instalado"
    else
      echo "   ❌ Erro ao instalar libnss3-tools"
      return 1
    fi
  fi
  
  # Criar banco de dados NSS se não existir
  if [ ! -d "$NSS_DB_DIR" ]; then
    echo "   📁 Criando banco de dados NSS..."
    mkdir -p "$NSS_DB_DIR"
    certutil -N -d "sql:$NSS_DB_DIR" --empty-password
  fi
  
  for cert in "$CERT_DIR"/*.crt "$CERT_DIR"/*.cer; do
    [ -e "$cert" ] || continue
    
    filename=$(basename -- "$cert")
    aliasname="${filename%.*}"
    
    # Verificar se o certificado já existe no NSS
    if certutil -L -d "sql:$NSS_DB_DIR" -n "$aliasname" >/dev/null 2>&1; then
      echo "   ⏭️  $filename (já existe no Chrome)"
      ((cert_skipped++))
    else
      echo "   📄 Instalando $filename no Chrome..."
      
      # Instalar certificado no banco NSS
      if certutil -A -d "sql:$NSS_DB_DIR" -n "$aliasname" -t "C,," -i "$cert"; then
        echo "   ✅ $filename instalado no Chrome"
        ((cert_installed++))
      else
        echo "   ❌ Erro ao instalar $filename no Chrome"
      fi
    fi
  done
  
  echo "   📊 Chrome - Instalados: $cert_installed | Ignorados: $cert_skipped"
  echo ""
  return 0
}

# Função para validar instalação dos certificados
validate_cert_installation() {
  echo "🔍 Validando instalação dos certificados..."
  echo ""
  
  # Validar certificados do sistema
  echo "   🐧 Certificados do sistema Ubuntu:"
  system_certs=$(ls -1 "$SYSTEM_CERT_DIR"/*.crt 2>/dev/null | wc -l)
  echo "      📊 Total no sistema: $system_certs certificados"
  
  # Validar certificados do Chrome
  echo "   🌐 Certificados do Chrome/NSS:"
  if [ -d "$NSS_DB_DIR" ] && command -v certutil &> /dev/null; then
    chrome_certs=$(certutil -L -d "sql:$NSS_DB_DIR" 2>/dev/null | grep -v "Certificate Nickname" | grep -v "^$" | wc -l)
    echo "      📊 Total no Chrome: $chrome_certs certificados"
  else
    echo "      ❌ NSS não configurado"
  fi
  
  echo ""
}

# Função para instalar certificados em uma versão específica do Java
install_certs_for_java() {
  local JAVA_HOME=$1
  local KEYTOOL="$JAVA_HOME/bin/keytool"
  local KEYSTORE=""
  
  echo "🔧 Processando Java: $(basename $JAVA_HOME)"
  
  # Tentativa inteligente de localizar o cacerts (Oracle ou OpenJDK)
  if [ -f "$JAVA_HOME/lib/security/cacerts" ]; then
    KEYSTORE="$JAVA_HOME/lib/security/cacerts"
  elif [ -f "$JAVA_HOME/jre/lib/security/cacerts" ]; then
    KEYSTORE="$JAVA_HOME/jre/lib/security/cacerts"
  else
    echo "   ❌ Keystore não encontrado"
    return 1
  fi
  
  # Verificação do keytool
  if [ ! -x "$KEYTOOL" ]; then
    echo "   ❌ Keytool não disponível"
    return 1
  fi
  
  # Instalar certificados
  local cert_installed=0
  local cert_updated=0
  local cert_skipped=0
  
  for cert in "$CERT_DIR"/*.crt "$CERT_DIR"/*.cer; do
    [ -e "$cert" ] || continue
    
    filename=$(basename -- "$cert")
    aliasname="${filename%.*}"
    
    # Obter fingerprint do arquivo
    file_fingerprint=$(get_cert_fingerprint "$cert")
    if [ -z "$file_fingerprint" ]; then
      echo "   ❌ Não foi possível obter fingerprint de $filename"
      continue
    fi

    # Verificar se o certificado já existe
    if sudo "$KEYTOOL" -list -keystore "$KEYSTORE" -storepass "$STOREPASS" -alias "$aliasname" >/dev/null 2>&1; then
      # Certificado existe, comparar fingerprints
      keystore_fingerprint=$(get_keystore_cert_fingerprint "$KEYSTORE" "$aliasname" "$STOREPASS" "sudo $KEYTOOL")
      
      if [ "$file_fingerprint" = "$keystore_fingerprint" ]; then
        echo "   ⏭️  $filename (idêntico, ignorando)"
        ((cert_skipped++))
        continue
      else
        echo "   🔄 $filename (diferente, atualizando...)"
        # Remover certificado existente
        if sudo "$KEYTOOL" -delete -keystore "$KEYSTORE" -storepass "$STOREPASS" -alias "$aliasname" >/dev/null 2>&1; then
          echo "   🗑️  Certificado antigo removido"
        else
          echo "   ❌ Erro ao remover certificado antigo"
          continue
        fi
      fi
    else
      echo "   📄 Instalando $filename..."
    fi
    
    # Instalar/reinstalar certificado
    if sudo "$KEYTOOL" -importcert \
      -alias "$aliasname" \
      -keystore "$KEYSTORE" \
      -file "$cert" \
      -storepass "$STOREPASS" \
      -noprompt >/dev/null 2>&1; then
      if sudo "$KEYTOOL" -list -keystore "$KEYSTORE" -storepass "$STOREPASS" -alias "$aliasname" >/dev/null 2>&1; then
        echo "   ✅ $filename instalado"
        ((cert_installed++))
      else
        echo "   ❌ Erro na verificação pós-instalação de $filename"
      fi
    else
      echo "   ❌ Erro ao instalar $filename"
    fi
  done
  
  echo "   📊 Instalados: $cert_installed | Atualizados: $cert_updated | Ignorados: $cert_skipped"
  echo ""
  return 0
}

# Função para obter fingerprint de um certificado
get_cert_fingerprint() {
  local cert_file=$1
  openssl x509 -in "$cert_file" -fingerprint -sha256 -noout 2>/dev/null | cut -d'=' -f2 | tr -d ':'
}

# Função para obter fingerprint de certificado no keystore
get_keystore_cert_fingerprint() {
  local keystore=$1
  local alias=$2
  local storepass=$3
  local keytool=$4
  
  "$keytool" -list -v -keystore "$keystore" -storepass "$storepass" -alias "$alias" 2>/dev/null | \
    grep "SHA256:" | head -n1 | sed 's/.*SHA256: //' | tr -d ' :'
}

# Instalar certificados em todas as versões do Java
echo "🚀 Iniciando instalação de certificados..."
echo ""

# 1. Instalar certificados no sistema Ubuntu
install_certs_system

# 2. Instalar certificados no Chrome/Chromium
install_certs_chrome

# 3. Instalar certificados nas versões do Java
echo "☕ Processando versões do Java..."
echo ""

total_java_versions=0
successful_installations=0
total_installed=0
total_skipped=0

for JAVA_HOME in "${JAVA_PATHS[@]}"; do
  ((total_java_versions++))
  if install_certs_for_java "$JAVA_HOME"; then
    ((successful_installations++))
  fi
done

# Instalar certificados na JRE do DBeaver (se existir)
echo "🦫 Processando JRE do DBeaver..."
install_certs_dbeaver

echo "🎉 Instalação concluída!"
echo ""

# Validar instalação
validate_cert_installation

echo "📊 Resumo Final:"
echo "   ✅ Versões do Java processadas: $successful_installations/$total_java_versions"
echo "   📄 Certificados disponíveis: $(find "$CERT_DIR" -name "*.cer" -o -name "*.crt" 2>/dev/null | wc -l)"
echo "   🐧 Certificados no sistema Ubuntu: $(ls -1 "$SYSTEM_CERT_DIR"/*.crt 2>/dev/null | wc -l)"
if [ -d "$NSS_DB_DIR" ] && command -v certutil &> /dev/null; then
echo "   🌐 Certificados no Chrome: $(certutil -L -d "sql:$NSS_DB_DIR" 2>/dev/null | grep -v "Certificate Nickname" | grep -v "^$" | wc -l)"
fi
echo ""
echo "💡 Comandos úteis:"
echo "   🔍 Java: keytool -list -keystore \$JAVA_HOME/lib/security/cacerts"
echo "   🔍 Sistema: ls -la $SYSTEM_CERT_DIR"
echo "   🔍 Chrome: certutil -L -d sql:$NSS_DB_DIR"
echo "   🔍 DBeaver: verificar conexões SSL/TLS no DBeaver"
echo ""
echo "🔄 Para aplicar as mudanças:"
echo "   - Reinicie o navegador Chrome/Chromium"
echo "   - Reinicie o DBeaver para aplicar os novos certificados"
echo "   - Aplicações Java usarão automaticamente os novos certificados"
echo "   - Aplicações do sistema usarão os certificados atualizados"

