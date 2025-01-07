========================================================================================
== Criando Database Links
== Marcio Mandarino
== 20/11/2024
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


==========================================================================================
== 🎯 Visão Geral 
==========================================================================================
▶️ Um database link é um objeto no Oracle Database que define uma conexão de rede a outro banco de dados Oracle
▶️ Permite que você consulte e manipule dados em uma base de dados remota como se estivesse acessando uma tabela local
▶️ Database links são extremamente úteis para integrar dados entre diferentes sistemas
💡 Pode ser utilizado para extrair dados de outros SGDBS (Sql Server, MySql, Postgres, etc...)


==========================================================================================
== 🎯 Pré requisitos 
==========================================================================================
▶️ Para criar um database link, você precisa da permissão CREATE DATABASE LINK ou CREATE PUBLIC DATABASE LINK 
▶️ O servidor aonde será criado o database link, precisa ter conectividade na porta do listener do servidor de destino
▶️ Você precisa de um usuário no banco de destino
    ▫️ As permissões do seu Database Link, será de acordo com o usuário do db_link


==========================================================================================
== 🎯 Cenário 
==========================================================================================
✅ Criar um database link no banco de dev para acessar tabelas do banco de produção


SERVIDOR        TIPO            DATABASE        OBJETO CRIADO     
------------------------------------------------------------------
srvprd01        Produção        orcl            Usuário
srvdev01        Dev             dev             Database Link


==========================================================================================
== 🎯 Definições Importantes
==========================================================================================
▶️ Você cria o database link no banco quem você vai usar para "puxar" os dados
▶️ Você cria o usuário do database link no banco que os dados serão consultados
▶️ As permissões que o database link terá, será herdada do usuário vinculado ao db_link e não ao usuário proprietário do db_link


==========================================================================================
== 🎯 Criando um usuário no banco de produção
==========================================================================================
$ . oraenv <<< ORCL
$ sqlplus / as sysdba
SQL> set lines 200
SQL> col table_name form a20
SQL> col num_rows form 999,999,999,999
SQL> select table_name, num_rows from dba_tables where owner = 'SOE' order by num_rows;

SQL> create user lk_srvdev01_soe identified by "Welcome1";
SQL> grant create session to lk_srvdev01_soe;

SQL> grant select on SOE.ADDRESSES              to lk_srvdev01_soe;
SQL> grant select on SOE.CUSTOMERS              to lk_srvdev01_soe;
SQL> grant select on SOE.CARD_DETAILS           to lk_srvdev01_soe;
SQL> grant select on SOE.WAREHOUSES             to lk_srvdev01_soe;
SQL> grant select on SOE.ORDER_ITEMS            to lk_srvdev01_soe;
SQL> grant select on SOE.ORDERS                 to lk_srvdev01_soe;
SQL> grant select on SOE.INVENTORIES            to lk_srvdev01_soe;
SQL> grant select on SOE.PRODUCT_INFORMATION    to lk_srvdev01_soe;
SQL> grant select on SOE.LOGON                  to lk_srvdev01_soe;
SQL> grant select on SOE.PRODUCT_DESCRIPTIONS   to lk_srvdev01_soe;
SQL> grant select on SOE.ORDERENTRY_METADATA    to lk_srvdev01_soe;


==========================================================================================
== 🎯 Adicionando uma entrada no tnsnames do servidor de dev
==========================================================================================
$ . oraenv <<< DEV
$ vi $ORACLE_HOME/network/admin/tnsnames.ora

# servidor de producao
ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )


==========================================================================================
== 🎯 Testando a entrada do tnsnames
==========================================================================================
$ tnsping orcl
$ sqlplus lk_srvdev01_soe/"Welcome1"@orcl
SQL> set lines 200
SQL> col num_rows form 999,999,999,999
SQL> col table_name form a20
SQL> select table_name, num_rows from all_tables where owner = 'SOE' order by num_rows;

SQL> col server_host form a15
SQL> col instance_name form a15
SQL> SELECT SYS_CONTEXT( 'USERENV', 'SERVER_HOST' ) server_host,
  SYS_CONTEXT( 'USERENV', 'INSTANCE_NAME' ) instance_name
FROM dual;



==========================================================================================
== 🎯 Criando ambiente de dev
==========================================================================================
$ . oraenv <<< DEV
$ sqlplus / as sysdba
SQL> create tablespace ts_soe_dev datafile size 100M autoextend on next 100M maxsize 31g;
SQL> create user soe_dev identified by "Welcome1";
SQL> grant create session, create table, create database link to soe_dev;
SQL> alter user soe_dev default tablespace ts_soe_dev;
SQL> alter user soe_dev quota unlimited on ts_soe_dev;
SQL> exit

==========================================================================================
== 🎯 Criando o Database Link usando o tnsnames
==========================================================================================
$ sqlplus soe_dev/"Welcome1"
SQL> CREATE DATABASE LINK dblk_srvprod01_soe_01
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Welcome1"
   USING 'orcl';


==========================================================================================
== 🎯 Criando o Database Link sem o tnsnames
==========================================================================================
SQL> CREATE DATABASE LINK dblk_srvprod01_soe_02
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Welcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';


==========================================================================================
== 🎯 Criando o Database Link público
==========================================================================================
⚠️ Todos os usuários do banco de dados poderão utilizar este database link
🧨 Não recomendo o uso!!!


SQL> CREATE PUBLIC DATABASE LINK dblk_srvprod01_soe_03
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Welcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';

⚠️ É necessário que o usuário tenha privilégios de CREATE PUBLIC DATABASE LINK

-- Abrir uma nova sessão:
$ . oraenv <<< DEV
$ sqlplus / as sysdba
SQL> grant CREATE PUBLIC DATABASE LINK to soe_dev;


==========================================================================================
== 🎯 Testando o dblink
==========================================================================================
SQL> set lines 200
SQL> col server_host form a15
SQL> col instance_name form a15
SQL> col table_name form a20
SQL> col num_rows form 999,999,999,999
SQL> select table_name, num_rows from all_tables@dblk_srvprod01_soe_01 where owner = 'SOE' order by num_rows;
SQL> select table_name, num_rows from all_tables@dblk_srvprod01_soe_02 where owner = 'SOE' order by num_rows;
SQL> select table_name, num_rows from all_tables@dblk_srvprod01_soe_03 where owner = 'SOE' order by num_rows;


SQL> SELECT SYS_CONTEXT( 'USERENV', 'SERVER_HOST' ) server_host,
  SYS_CONTEXT( 'USERENV', 'INSTANCE_NAME' ) instance_name
FROM dual;


select count(1) from soe.WAREHOUSES@dblk_srvprod01_soe_01;

==========================================================================================
== 🎯 Informações sobre o dblink
==========================================================================================
▶️ A view DBA_DB_LINKS contém informações de todos os databases links do banco

SQL> conn / as sysdba
SQL> col owner form a15
SQL> col username form a15
SQL> col db_link form a30
SQL> col host form a70
SQL> SELECT
    owner,db_link,username,host,created,valid
FROM
    all_db_links;