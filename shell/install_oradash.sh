#!/bin/bash
# Script para instalar o Oradash de forma silenciosa com alias

# Variáveis
SCRIPTS_DIR="$HOME/scripts"
ORADASH_ZIP_URL="https://github.com/marciomandarino/oplanodba/raw/refs/heads/main/shell/oradash.zip"
ORADASH_SCRIPT="$SCRIPTS_DIR/oradash/oradash.sh"
BASH_PROFILE="$HOME/.bash_profile"

echo "Iniciando instalação do Oradash..."

# Cria o diretório de instalação se não existir
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Criando diretório $SCRIPTS_DIR..."
    mkdir -p "$SCRIPTS_DIR" || { echo "Erro ao criar $SCRIPTS_DIR"; exit 1; }
else
    echo "Diretório $SCRIPTS_DIR já existe."
fi

# Verifica se SQLPATH está definida; se não, adiciona ao .bash_profile e exporta
if [ -z "$SQLPATH" ]; then
    echo "SQLPATH não está definida. Definindo SQLPATH como $SCRIPTS_DIR..."
    echo "export SQLPATH=\"$SCRIPTS_DIR\"" >> "$BASH_PROFILE"
    export SQLPATH="$SCRIPTS_DIR"
else
    echo "SQLPATH já está definida: $SQLPATH"
fi

# Baixa o arquivo oradash.zip para o diretório de instalação (silenciosamente)
cd "$SCRIPTS_DIR" || { echo "Não foi possível acessar $SCRIPTS_DIR"; exit 1; }
echo "Baixando oradash.zip..."
wget -q -O oradash.zip "$ORADASH_ZIP_URL" || { echo "Erro ao baixar oradash.zip"; exit 1; }
echo "Download concluído."

# Descompacta o arquivo oradash.zip (silenciosamente)
echo "Descompactando oradash.zip..."
unzip -qo oradash.zip -d "$SCRIPTS_DIR" || { echo "Erro ao descompactar oradash.zip"; exit 1; }
echo "Descompactação concluída."

# Verifica se o arquivo oradash.sh existe e dá permissão de execução
if [ -f "$ORADASH_SCRIPT" ]; then
    echo "Definindo permissões de execução para $ORADASH_SCRIPT..."
    chmod +x "$ORADASH_SCRIPT"
else
    echo "Arquivo $ORADASH_SCRIPT não encontrado. Instalação abortada."
    exit 1
fi

# Cria um alias no ~/.bash_profile para chamar o Oradash
ALIAS_LINE="alias oradash=\"\$SQLPATH/oradash/oradash.sh\""
if ! grep -q "^alias oradash=" "$BASH_PROFILE"; then
    echo "Adicionando alias 'oradash' no $BASH_PROFILE..."
    echo "$ALIAS_LINE" >> "$BASH_PROFILE"
else
    echo "Alias 'oradash' já existe em $BASH_PROFILE."
fi

# Carrega o ~/.bash_profile para atualizar as variáveis e o alias
echo "Carregando $BASH_PROFILE..."
source "$BASH_PROFILE"

echo "Oradash instalado com sucesso em $SCRIPTS_DIR."
echo "Você pode iniciar o Oradash executando: oradash"
