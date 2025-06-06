#!/bin/bash
# install_oracle.sh
# Script para instalação do Oracle Database Free 23ai com pré-checks alinhados,
# confirmação em caso de falha, log, medição de tempo, arquivo de senhas e resumo final formatado.

#############################################
# Limpar a tela
#############################################
clear

#############################################
# Definições de largura e divisores
#############################################
WIDTH=134
DIVIDER="$(printf '%0.1s' '-'{1..134})"
EQUALS="$(printf '%0.1s' '='{1..134})"

#############################################
# Cabeçalho
#############################################
echo "$DIVIDER"
cat <<'EOF'
 ::::::::  :::::::::      :::      ::::::::  :::        ::::::::::        ::::::::   ::::::::            :::     ::::::::::: 
:+:    :+: :+:    :+:   :+: :+:   :+:    :+: :+:        :+:              :+:    :+: :+:    :+:         :+: :+:       :+:     
+:+    +:+ +:+    +:+  +:+   +:+  +:+        +:+        +:+                    +:+         +:+        +:+   +:+      +:+     
+#+    +:+ +#++:++#:  +#++:++#++: +#+        +#+        +#++:++#             +#+        +#++:        +#++:++#++:     +#+     
+#+    +#+ +#+    +#+ +#+     +#+ +#+        +#+        +#+                +#+             +#+       +#+     +#+     +#+     
#+#    #+# #+#    #+# #+#     #+# #+#    #+# #+#        #+#               #+#       #+#    #+#       #+#     #+#     #+#     
 ########  ###    ### ###     ###  ########  ########## ##########       ##########  ########        ###     ### ########### 
EOF
echo "$DIVIDER"
TITLE="Oracle Database 23ai Instalation"
# Centraliza o título dentro de WIDTH
printf "%*s\n" $(((${#TITLE}+WIDTH)/2)) "$TITLE"
echo "$DIVIDER"
echo ""

#############################################
# Definir cores usando tput
#############################################
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

#############################################
# Função para converter segundos em hh:mm:ss
#############################################
convert_seconds() {
    local total_seconds=$1
    local hours minutes seconds
    hours=$(printf "%02d" $(( total_seconds / 3600 )))
    minutes=$(printf "%02d" $(( (total_seconds % 3600) / 60 )))
    seconds=$(printf "%02d" $(( total_seconds % 60 )))
    echo "${hours}:${minutes}:${seconds}"
}

#############################################
# Pré-requisitos
#############################################
fail_found=false

# 1. Obtém nome e versão atuais do SO
current_name=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
current_ver=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
current_os="${current_name} ${current_ver}"
minimum_os="OL8"

# Verifica e imprime Sistema Operacional com o SO atual e o mínimo exigido
if $prereq_os; then
    print_prereq_line "PASS" "Sistema Operacional" "${current_os} (mínimo: ${minimum_os})"
else
    print_prereq_line "FAIL" "Sistema Operacional" "${current_os} (mínimo: ${minimum_os})"
    fail_found=true
fi


# 2. Verificar se há pelo menos 1,5GB de RAM (1536 MB)
prereq_mem=false
total_mem=$(free -m | awk '/^Mem:/{print $2}')
if [ "$total_mem" -ge 1536 ]; then
    prereq_mem=true
fi

# 3. Verificar espaço livre de pelo menos 20GB no file system onde está o /opt
prereq_space=false
if [ -d /opt ]; then
    mount_point=$(df --output=target /opt | tail -1 | tr -d ' ')
    avail_space=$(df --output=avail -BG /opt | tail -1 | tr -d 'G ')
else
    mount_point=$(df --output=target / | tail -1 | tr -d ' ')
    avail_space=$(df --output=avail -BG / | tail -1 | tr -d 'G ')
fi
if [ "$avail_space" -ge 20 ]; then
    prereq_space=true
fi

if [ "$mount_point" != "/opt" ]; then
    dedicated_opt="NÃO"
else
    dedicated_opt="SIM"
fi

# 4. Verificar conexão com a Internet (ping 8.8.8.8)
prereq_inet=false
if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    prereq_inet=true
fi

#############################################
# Exibir relatório dos pré-requisitos
#############################################
echo "$EQUALS"
echo "== Pré-requisitos"
echo "$EQUALS"
echo ""

# Função auxiliar para imprimir cada linha alinhada (":" na coluna 35)
print_prereq_line() {
  local status="$1"
  local label="$2"
  local detail="$3"

  # Define cor para PASS/FAIL
  if [ "$status" = "PASS" ]; then
    status="${GREEN}[PASS]${NC}"
  else
    status="${RED}[FAIL]${NC}"
  fi

  # %-6s => [PASS] / [FAIL] (6 colunas)
  # espaço => col 7
  # %-28s => label (col 8 a 35)
  # ':' => col 36
  # espaço => col 37
  # detail => a partir da col 38
  #
  # Aumentamos de 27 para 28 para tentar acomodar melhor caracteres acentuados.
  printf "%-6s %-28s: %s\n" "$status" "$label" "$detail"
}

# Verifica e imprime Sistema Operacional
if $prereq_os; then
    print_prereq_line "PASS" "Sistema Operacional" "Oracle Linux 8 (OL8 exigido)"
else
    print_prereq_line "FAIL" "Sistema Operacional" "Oracle Linux 8 (OL8 exigido)"
    fail_found=true
fi

# Verifica e imprime Memória
if $prereq_mem; then
    print_prereq_line "PASS" "Memória" "${total_mem} MB (mínimo 1,5GB)"
else
    print_prereq_line "FAIL" "Memória" "${total_mem} MB (mínimo 1,5GB)"
    fail_found=true
fi

# Verifica e imprime Espaço livre em /opt
if $prereq_space; then
    print_prereq_line "PASS" "Espaço livre em /opt" "${avail_space} GB (mínimo 20 GB)"
else
    print_prereq_line "FAIL" "Espaço livre em /opt" "${avail_space} GB (mínimo 20 GB)"
    fail_found=true
fi

# Verifica e imprime Conexão com a Internet
if $prereq_inet; then
    print_prereq_line "PASS" "Conexão com a Internet" "OK"
else
    print_prereq_line "FAIL" "Conexão com a Internet" "NOK"
    fail_found=true
fi

if [ "$dedicated_opt" = "NÃO" ]; then
    echo "Observação: /opt não é uma partição dedicada. A instalação será realizada no file system raiz."
fi

echo ""
echo "$EQUALS"
echo "== O script realizará as seguintes etapas:"
echo "$EQUALS"
echo "  • Preparação do Sistema operacional"
echo "  • Instalação do Oracle 23ai"
echo "  • Criação de um banco de dados"
echo ""
read -n 1 -s -r -p "Pressione qualquer tecla para continuar ou CTRL+C para abortar..." < /dev/tty
echo ""
echo "Iniciando a instalação..."
echo ""

# Se houve falha, perguntar se deseja continuar
if $fail_found; then
    read -p "Alguns pré-requisitos não foram atendidos. Deseja continuar mesmo assim? (s/n): " choice
    if [[ "$choice" != "s" && "$choice" != "S" ]]; then
        echo "Instalação abortada."
        exit 1
    fi
fi

#############################################
# Redireciona saída para log e tela
#############################################
LOGFILE="$(pwd)/oracle_install.log"
exec > >(tee -a "$LOGFILE") 2>&1

#############################################
# Registrar horário de início da instalação
#############################################
systemctl restart chronyd
sleep 15

start_total=$(date +%s)
start_install_time=$(date +'%d/%m/%Y %H:%M:%S')
SECONDS=0

echo $start_total
echo $start_install_time
date

#########################
# Etapa 1: Preparação do servidor
#########################
echo "----- Início: Preparação -----"
start_prep=$(date +%s)

# Atualizar /etc/hosts
echo "Atualizando /etc/hosts..."
echo "$(hostname -I | awk '{print $1}') $(hostname | cut -d'.' -f1) $(hostname)" >> /etc/hosts

# Instalar pacotes adicionais
echo "Instalando pacotes..."
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum install -y mlocate net-tools rlwrap wget zip screen vim glibc-all-langpacks langpacks-en

# Configurar repositório Oracle Linux Developer
echo "Configurando repositório..."
dnf install -y oraclelinux-developer-release-el8
dnf config-manager --set-enabled ol8_developer

# Desabilitar firewall e SELINUX
echo "Desabilitando firewall e SELINUX..."
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Instalar pacote preinstall e atualizar sistema
echo "Instalando pré-requisitos Oracle e atualizando sistema..."
dnf -y install oracle-database-preinstall-23ai
dnf update -y 

end_prep=$(date +%s)
duration_prep=$(( end_prep - start_prep ))
echo "----- Fim: Preparação (Tempo: $(convert_seconds "$duration_prep")) -----"
echo ""

#########################
# Etapa 2: Instalação do Oracle
#########################
echo "----- Início: Instalação -----"
start_install=$(date +%s)

echo "Download do Oracle Database Free 23ai..."
curl -L -o /tmp/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm \
     https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm

echo "Instalando Oracle Database Free 23ai..."
dnf -y localinstall /tmp/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm
rm -rf /tmp/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm

end_install=$(date +%s)
duration_install=$(( end_install - start_install ))
echo "----- Fim: Instalação (Tempo: $(convert_seconds "$duration_install")) -----"
echo ""

#########################
# Etapa 3: Criação do banco
#########################
echo "----- Início: Criação do banco -----"
start_db=$(date +%s)

echo "Configurando Oracle e criando o banco..."
time ( echo "Welcome1"; echo "Welcome1"; ) | /etc/init.d/oracle-free-23ai configure

echo "Atualizando variáveis do usuário oracle..."
cat >> /home/oracle/.bash_profile <<'EOF'
# Oracle variables
export ORACLE_SID=FREE
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree
export PATH=$ORACLE_HOME/bin:$PATH
EOF

echo "Configurando tnsnames.ora..."
cat >> /opt/oracle/product/23ai/dbhomeFree/network/admin/tnsnames.ora <<EOF
FREEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP) ( HOST = $(hostname) ) (PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = FREEPDB1)
    )
  )
EOF

end_db=$(date +%s)
duration_db=$(( end_db - start_db ))
echo "----- Fim: Criação do banco (Tempo: $(convert_seconds "$duration_db")) -----"
echo ""

#########################
# Etapa 4: Criação do arquivo de senhas
#########################
PASSWORD_FILE="$(pwd)/oracle_db_passwords.txt"
echo "Criando arquivo de senhas em ${PASSWORD_FILE}..."
cat > "${PASSWORD_FILE}" <<EOF
###############################################
# Oracle Database Free 23ai - Arquivo de Senhas
###############################################
# Senha para contas administrativas (SYS/SYSTEM): Welcome1
###############################################
EOF

echo "As senhas do banco estão armazenadas em: ${PASSWORD_FILE}"
echo ""

#############################################
# Registrar horário de término da instalação
#############################################
finish_install_time=$(date +'%d/%m/%Y %H:%M:%S')
duration_minutes=$(( SECONDS / 60 ))

echo "=============================================="
echo -e "Fim da instalação (Tempo total: ${YELLOW}${duration_minutes} minutos${NC})"
echo "Início: ${YELLOW}${start_install_time}${NC} | Término: ${YELLOW}${finish_install_time}${NC}"
echo "=============================================="


#############################################
# Resumo Final da Instalação
#############################################
# Obter IP (primeiro endereço) em vez do hostname
ip_addr=$(hostname -I | awk '{print $1}')


#############################################
# Registrar horário de término da instalação
#############################################
finish_install_time=$(date +'%d/%m/%Y %H:%M:%S')

# Calcular os tempos em minutos para cada etapa
prep_minutes=$(( duration_prep / 60 ))
install_minutes=$(( duration_install / 60 ))
db_minutes=$(( duration_db / 60 ))
total_minutes=$(( SECONDS / 60 ))

echo "$EQUALS"
echo "== Resumo da instalação"
echo "$EQUALS"
echo ""
printf "  • %-40s : %s minutos\n" "Preparação do Sistema operacional" "$prep_minutes"
printf "  • %-40s : %s minutos\n" "Instalação do Oracle 23ai" "$install_minutes"
printf "  • %-40s : %s minutos\n" "Criação de um banco de dados" "$db_minutes"
printf "  • %-40s : %s minutos\n" "Tempo total de instalação" "$total_minutes"
echo ""



echo ""
echo "================ Resumo da Instalação ================"
printf "%-25s: ${GREEN}%s${NC}\n" "Oracle Home" "/opt/oracle/product/23ai/dbhomeFree"
printf "%-25s: ${GREEN}%s${NC}\n" "Database" "FREE"
printf "%-25s: ${GREEN}%s${NC}\n" "PDB" "FREEPDB1"
printf "%-25s: ${GREEN}%s${NC}\n" "Versão" "Oracle Database Free 23ai"
printf "%-25s: ${GREEN}%s${NC}\n" "Senha (arquivo)" "${PASSWORD_FILE}"
echo ""
echo "Como se conectar:"
printf "   %-20s -> IP: ${GREEN}%s${NC}, Porta: ${GREEN}1521${NC}, Serviço: ${GREEN}FREE${NC}\n" "CDB" "${ip_addr}"
printf "   %-20s -> IP: ${GREEN}%s${NC}, Porta: ${GREEN}1521${NC}, Serviço: ${GREEN}FREEPDB1${NC}\n" "PDB" "${ip_addr}"
echo "======================================================="


#############################################
# Verificação pós instalação
#############################################
MAGENTA=$(tput setaf 5)

# Função auxiliar para imprimir cada linha alinhada (":" na coluna 35)
print_post_line() {
  local status="$1"
  local label="$2"
  local detail="$3"
  if [ "$status" = "PASS" ]; then
    status="${GREEN}[PASS]${NC}"
  else
    status="${RED}[FAIL]${NC}"
  fi
  printf "%-6s %-28s: %s\n" "$status" "$label" "$detail"
}

post_ok=true

echo "$EQUALS"
echo "== Verificação pós instalação"
echo "$EQUALS"
echo ""

# Verificar se o processo pmon (db_pmon_FREE) está rodando
if ps -ef | grep -v grep | grep -q "pmon_FREE"; then
    print_post_line "PASS" "Processo pmon (db_pmon_FREE)" "Encontrado"
else
    print_post_line "FAIL" "Processo pmon (db_pmon_FREE)" "Não encontrado"
    post_ok=false
fi

# Verificar se o Listener está rodando
if ps -ef | grep -v grep | grep -q "tnslsnr"; then
    print_post_line "PASS" "Listener" "Rodando"
else
    print_post_line "FAIL" "Listener" "Não rodando"
    post_ok=false
fi

# Verificar o status da instância via SQL*Plus (executando como usuário oracle)
instance_status=$(su - oracle -c "export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree; sqlplus -S / as sysdba <<'SQLEOF'
set heading off feedback off verify off;
select status from v\$instance;
exit;
SQLEOF")
instance_status=$(echo "$instance_status" | xargs)  # Remove espaços em branco

if [ "$instance_status" = "OPEN" ]; then
    print_post_line "PASS" "Status da Instância" "$instance_status"
else
    print_post_line "FAIL" "Status da Instância" "Esperado 'OPEN', obtido '$instance_status'"
    post_ok=false
fi

echo ""

if $post_ok; then
    echo -e "${MAGENTA}Processo de instalação do Oracle 23ai foi com sucesso!${NC}"
else
    echo -e "${RED}Processo de instalação do Oracle 23ai falhou. Verifique os itens acima!${NC}"
fi



