========================================================================================
== Datapump import com Database Link
== Marcio Mandarino
== 15/01/2025
== marcio@mrdba.com.br
== www.mrdba.com.br
== https://www.linkedin.com/in/marciomandarino/
== https://mrdba.com.br/oracle_fundamentals/
========================================================================================

🌎 Referências 
https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/CREATE-DATABASE-LINK.html


==========================================================================================
== 🎯 Resumo do vídeo 
==========================================================================================
📍 Visão Geral
📍 Pré requisitos 
📍 Cenário
📍 Definições Importantes
📍 Criando um usuário no banco de produção
📍 Adicionando uma entrada no tnsnames do servidor de dev
📍 Testando a entrada do tnsnames
📍 Criando ambiente de dev
📍 Criando o Database Link usando o tnsnames
📍 Criando o Database Link sem o tnsnames
📍 Criando o Database Link público
📍 Testando o dblink
📍 Informações sobre o dblink
📍 Copiando as tabelas de produção para dev
📍 Fazendo um update na origem dos dados
📍 Fechando um database link
📍 Data Pump Import via database link
📍 Excluindo um Database Link
📍 Conclusão


==========================================================================================
== 🎯 Visão Geral 
==========================================================================================
▶️ Importar dados com o Datapump via Database Link tem suas vantagens e desvantagens
▶️ Para realizar a importação via Database link, utiliza-se o parâmetro network_link
▶️ O processo de importação é muito similar, porém sem usar um dump para ler os dados

==========================================================================================
== 🎯 Vantagens e desvantagens
==========================================================================================

▶️ Vantagens
  ▫️ Simplicidade no processo
  ▫️ Não necessita de uma área para armazenar o dump
▶️ Desvantagens
  ▫️ Não suporta paralelismo
  ▫️ Tem limitações com relação a versões diferentes dos bancos de origem e destino


==========================================================================================
== 🎯 Cenário 
==========================================================================================
✅ Importar dados via Datapump Import usando um Database Link
✅ Já existe um Database link entre os bancos de origem e destino


SERVIDOR        TIPO            DATABASE        OBJETO CRIADO     
------------------------------------------------------------------
srvprd01        Produção        orcl            Usuário
srvdev01        Dev             dev             Database Link


==========================================================================================
== 🎯 Data Pump Import via database link
==========================================================================================
✅ O usuário de origem precisa de privilégios de export (exp_full_database)
✅ O usuário de destino precisa de privilégios de import (imp_full_database)


==========================================================================================
== 🎯 Criar usuário no banco de origem
==========================================================================================
SQL> create user lk_expdp identified by "Welcome1";
SQL> grant create session, exp_full_database to lk_expdp;


==========================================================================================
== 🎯 Criar db_link no banco de destino
==========================================================================================
$ sqlplus / as sysdba

SQL> CREATE DATABASE LINK dblk_srvprod01_expdp 
CONNECT TO lk_expdp IDENTIFIED BY "Welcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';



==========================================================================================
== 🎯 Importando através do db_link
==========================================================================================

$ impdp \"/ as sysdba\" tables=SOE.LOGON network_link=dblk_srvprod01_expdp directory=DATA_PUMP_DIR logfile=LOGON_IMP.log remap_schema=SOE:SOE_DEV remap_tablespace=TS_SOE:TS_SOE_DEV exclude=OBJECT_GRANT parallel=4

$ impdp \"/ as sysdba\" schemas=SOE network_link=dblk_srvprod01_expdp directory=DATA_PUMP_DIR logfile=LOGON_IMP.log remap_schema=SOE:SOE_DEV remap_tablespace=TS_SOE:TS_SOE_DEV exclude=OBJECT_GRANT parallel=4


==========================================================================================
== 🎯 Excluindo um Database Link
==========================================================================================
$ sqlplus soe_dev/"Wellcome1"@dev

SQL> drop DATABASE LINK dblk_srvprod01_soe_01;
SQL> drop DATABASE LINK dblk_srvprod01_soe_02;
SQL> drop public DATABASE LINK dblk_srvprod01_soe_03;
ORA-01031: insufficient privileges
⚠️ Precisa do privilégio DROP PUBLIC DATABASE LINK 
SQL> conn / as sysdba
SQL> drop public DATABASE LINK dblk_srvprod01_soe_03;


==========================================================================================
== 🏁 Conclusão
==========================================================================================
💡 É um recurso muito útil para banco de dados Oracle
💡 Fique atento aonde criar o usuário e aonde criar o database link
💡 Atenção aos privilégios concedidos ao usuário do database link
💡 Evite ao máximo criar database links públicos


==========================================================================================
== 🧹 Limpa tudo
==========================================================================================

-- Prod
SQL> drop user lk_srvdev01_soe;
SQL> drop user lk_expdp;

-- Dev
SQL> drop user soe_dev cascade;
SQL> drop tablespace ts_soe_dev including contents and datafiles;
SQL> drop public database link dblk_srvprod01_soe_03;
SQL> drop database link dblk_srvprod01_expdp;