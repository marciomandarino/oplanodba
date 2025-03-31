#!/bin/bash
# Script para instalar o Oradash de forma silenciosa com alias

# Variáveis
SCRIPTS_DIR="$HOME/scripts"
ORADASH_ZIP_URL="https://github.com/marciomandarino/oplanodba/raw/refs/heads/main/shell/oradash.zip"
ORADASH_SCRIPT="$SCRIPTS_DIR/oradash/oradash.sh"
BASH_PROFILE="$HOME/.bash_profile"

# Exibe o resumo das ações a serem realizadas
echo "Resumo da instalação do Oradash:"
echo "  • Criar o diretório '$SCRIPTS_DIR' se não existir."
echo "  • Verificar se a variável SQLPATH está definida; se não, definir como '$SCRIPTS_DIR' e atualizar o ~/.bash_profile."
echo "  • Baixar silenciosamente o arquivo 'oradash.zip' do GitHub para '$SCRIPTS_DIR'."
echo "  • Descompactar 'oradash.zip' dentro de '$SCRIPTS_DIR'."
echo "  • Dar permissão de execução para o script '$ORADASH_SCRIPT'."
echo "  • Criar um alias 'oradash' no ~/.bash_profile apontando para \$SQLPATH/oradash/oradash.sh."
echo "  • Carregar o ~/.bash_profile (source) para atualizar as configurações."
echo
read -n1 -s -r -p "Pressione qualquer tecla para continuar ou CTRL+C para cancelar..."
echo
echo "Iniciando instalação do Oradash..."

# Cria o diretório de instalação se não existir
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Criando diretório $SCRIPTS_DIR..."
    mkdir -p "$SCRIPTS_DIR" || { echo "Erro ao criar $SCRIPTS_DIR"; exit 1; }
else
    echo "Diretório $SCRIPTS_DIR já existe."
fi

# Verifica se a variável SQLPATH está definida; se não, define-a
if [ -z "$SQLPATH" ]; then
    echo "SQLPATH não está definida. Definindo SQLPATH como $SCRIPTS_DIR..."
    echo "export SQLPATH=\"$SCRIPTS_DIR\"" >> "$BASH_PROFILE"
    export SQLPATH="$SCRIPTS_DIR"
else
    echo "SQLPATH já está definida: $SQLPATH"
fi

# Baixa o arquivo oradash.zip silenciosamente
cd "$SCRIPTS_DIR" || { echo "Não foi possível acessar $SCRIPTS_DIR"; exit 1; }
echo "Baixando oradash.zip..."
wget -q -O oradash.zip "$ORADASH_ZIP_URL" || { echo "Erro ao baixar oradash.zip"; exit 1; }
echo "Download concluído."

# Descompacta o arquivo oradash.zip silenciosamente
echo "Descompactando oradash.zip..."
unzip -qo oradash.zip -d "$SCRIPTS_DIR" || { echo "Erro ao descompactar oradash.zip"; exit 1; }
echo "Descompactação concluída."

# Dá permissão de execução para o script oradash.sh
if [ -f "$ORADASH_SCRIPT" ]; then
    echo "Definindo permissões de execução para $ORADASH_SCRIPT..."
    chmod +x "$ORADASH_SCRIPT"
else
    echo "Arquivo $ORADASH_SCRIPT não encontrado. Instalação abortada."
    exit 1
fi

# Cria um alias no ~/.bash_profile para o Oradash, se não existir
ALIAS_LINE="alias oradash=\"\$SQLPATH/oradash/oradash.sh\""
if ! grep -q "^alias oradash=" "$BASH_PROFILE"; then
    echo "Adicionando alias 'oradash' no $BASH_PROFILE..."
    echo "$ALIAS_LINE" >> "$BASH_PROFILE"
else
    echo "Alias 'oradash' já existe em $BASH_PROFILE."
fi

# Carrega o ~/.bash_profile para atualizar variáveis e alias
echo "Carregando $BASH_PROFILE..."
source "$BASH_PROFILE"

echo "Oradash instalado com sucesso em $SCRIPTS_DIR."
echo "Você pode iniciar o Oradash executando: oradash"
