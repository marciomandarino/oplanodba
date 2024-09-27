========================================================================================
== Criando Database Links
== Marcio Mandarino
== 10/06/2024
== marcio@mrdba.com.br
== www.mrdba.com.br
== https://www.linkedin.com/in/marciomandarino/
========================================================================================

🌎 Referências 
https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-data-files-and-temp-files.html#GUID-814D8847-5327-41A3-8959-444C40093B46

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
📍 Conclusão


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
    ▫️ As permissões do seu Database Link, será de acordo com o este usuário


==========================================================================================
== 🎯 Cenário 
==========================================================================================
✅ Copiar tabelas do banco de produção para o banco de dev


SERVIDOR        TIPO            DATABASE        OBJETO CRIADO     
------------------------------------------------------------------
srvprd01        Produção        orcl            Usuário
srvdev01        Dev             dev             Database Link


==========================================================================================
== 🎯 Definições Importantes
==========================================================================================
▶️ Você cria o database link no banco quem você vai usar para "puxar" os dados
▶️ Você cria o usuário do database link no banco que os dados serão consultados
▶️ As permissões que o database link terá será herdada do usuário vinculado ao db_link e não ao usuário proprietário do db_link


==========================================================================================
== 🎯 Criando um usuário no banco de produção
==========================================================================================
$ . oraenv <<< ORCL
$ sqlplus / as sysdba
SQL> set lines 200
SQL> col table_name form a20
SQL> col num_rows form 999,999,999,999
SQL> select table_name, num_rows from dba_tables where owner = 'SOE' order by num_rows;

SQL> create user lk_srvdev01_soe identified by "Wellcome1";
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
$ sqlplus lk_srvdev01_soe/"Wellcome1"@orcl
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
SQL> create user soe_dev identified by "Wellcome1";
SQL> grant create session, create table, create database link to soe_dev;
SQL> alter user soe_dev default tablespace ts_soe_dev;
SQL> alter user soe_dev quota unlimited on ts_soe_dev;

==========================================================================================
== 🎯 Criando o Database Link usando o tnsnames
==========================================================================================
$ sqlplus soe_dev/"Wellcome1"@dev
SQL> CREATE DATABASE LINK dblk_srvprod01_soe_01
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Wellcome1"
   USING 'orcl';


==========================================================================================
== 🎯 Criando o Database Link sem o tnsnames
==========================================================================================
SQL> CREATE DATABASE LINK dblk_srvprod01_soe_02
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Wellcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';


==========================================================================================
== 🎯 Criando o Database Link público
==========================================================================================
⚠️ Todos os usuários do banco de dados poderão utilizar este database link
🧨 Não recomendo o uso!!!


SQL> CREATE PUBLIC DATABASE LINK dblk_srvprod01_soe_03
CONNECT TO lk_srvdev01_soe IDENTIFIED BY "Wellcome1"
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




==========================================================================================
== 🎯 Copiando as tabelas de produção para dev
==========================================================================================
SQL> set timing on
SQL> create table SOE_DEV.INVENTORIES            AS (SELECT * FROM SOE.INVENTORIES@dblk_srvprod01_soe_01      );
SQL> create table SOE_DEV.PRODUCT_DESCRIPTIONS   AS (SELECT * FROM SOE.PRODUCT_DESCRIPTIONS@dblk_srvprod01_soe_01);
SQL> create table SOE_DEV.PRODUCT_INFORMATION    AS (SELECT * FROM SOE.PRODUCT_INFORMATION@dblk_srvprod01_soe_01 );
SQL> create table SOE_DEV.WAREHOUSES             AS (SELECT * FROM SOE.WAREHOUSES@dblk_srvprod01_soe_01          );
SQL> create table SOE_DEV.CUSTOMERS              AS (SELECT * FROM SOE.CUSTOMERS@dblk_srvprod01_soe_02        );
SQL> create table SOE_DEV.CARD_DETAILS           AS (SELECT * FROM SOE.CARD_DETAILS@dblk_srvprod01_soe_03     );
SQL> create table SOE_DEV.ADDRESSES              AS (SELECT * FROM SOE.ADDRESSES@dblk_srvprod01_soe_01           );
SQL> create table SOE_DEV.ORDER_ITEMS            AS (SELECT * FROM SOE.ORDER_ITEMS@dblk_srvprod01_soe_01         );
SQL> create table SOE_DEV.ORDERS                 AS (SELECT * FROM SOE.ORDERS@dblk_srvprod01_soe_01              );
SQL> create table SOE_DEV.LOGON                  AS (SELECT * FROM SOE.LOGON@dblk_srvprod01_soe_01               );
SQL> create table SOE_DEV.ORDERENTRY_METADATA    AS (SELECT * FROM SOE.ORDERENTRY_METADATA@dblk_srvprod01_soe_01 );


SQL> set lines 200
SQL> col table_name form a20
SQL> select table_name, num_rows from user_tables;




==========================================================================================
== 🎯 Fazendo um update na origem dos dados
==========================================================================================
▶️ Você pode fazer outras operações usando o database link, desde que tenha privilégios para isso.

SQL> update soe.CUSTOMERS@dblk_srvprod01_soe
set SUGGESTIONS = 'xxxxx' where rownum < 10;
ORA-01031: insufficient privileges


-- Conceder privilégio na produção
SQL> grant update on SOE.CUSTOMERS              to lk_srvdev01_soe;

==========================================================================================
== 🎯 Fechando um database link
==========================================================================================
▶️ Se você usar um db_link ele ficará aberto na sessão
▶️ Normalmente isso não é um problema quando você faz operações pontuais
▶️ Se fizer muitas operações com Database Link, procure fechá-las


SQL> ALTER SESSION CLOSE DATABASE LINK dblk_srvprod01_soe_01;
SQL> ALTER SESSION CLOSE DATABASE LINK dblk_srvprod01_soe_02;
SQL> ALTER SESSION CLOSE DATABASE LINK dblk_srvprod01_soe_03;


==========================================================================================
== 🎯 Data Pump Import via database link
==========================================================================================
✅ O usuário de origem precisa de privilégios de export (exp_full_database)
✅ O usuário de destino precisa de privilégios de import (imp_full_database)


-- Criar usuário no banco de origem
SQL> create user lk_expdp identified by "Wellcome1";
SQL> grant create session, exp_full_database to lk_expdp;

-- Criar db_link no banco de destino
$ sqlplus / as sysdba

SQL> CREATE DATABASE LINK dblk_srvprod01_expdp 
CONNECT TO lk_expdp IDENTIFIED BY "Wellcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';



-- Importando através do db_link
$ impdp \"/ as sysdba\" tables=SOE.LOGON network_link=dblk_srvprod01_expdp directory=DATA_PUMP_DIR logfile=LOGON_IMP.log remap_schema=SOE:SOE_DEV remap_tablespace=TS_SOE:TS_SOE_DEV exclude=OBJECT_GRANT


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