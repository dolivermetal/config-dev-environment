echo "📦 ====================================================================="
echo "📦 INSTALANDO KUBECTL OIDC LOGIN NO LINUX/WSL"
echo "📦 ====================================================================="

# Define temporary directory
TMP_DIR="${TMP_DIR:-./tmp}"
mkdir -p "$TMP_DIR"

version=$(curl -s https://api.github.com/repos/int128/kubelogin/releases/latest | grep '"tag_name"' | cut -d'"' -f4)

# Baixando o plugin diretamente do repositório no Linux/WSL
curl -L "https://github.com/int128/kubelogin/releases/download/$version/kubelogin_linux_amd64.zip" -o "$TMP_DIR/kubelogin_linux_amd64.zip"

unzip "$TMP_DIR/kubelogin_linux_amd64.zip" -d "$TMP_DIR"
sudo mv "$TMP_DIR/kubelogin" /usr/local/bin/kubectl-oidc_login
sudo chmod +x /usr/local/bin/kubectl-oidc_login

rm -fr "$TMP_DIR"