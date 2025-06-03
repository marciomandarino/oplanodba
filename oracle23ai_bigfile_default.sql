========================================================================================
== Aula: BIGFILE Default para SYSAUX, SYSTEM e USER no Oracle 23ai
== Nome do autor: Marcio Mandarino
== Data da geração: 06/05/2025
== https://www.linkedin.com/in/marciomandarino/
== https://mrdba.com.br/oracle_fundamentals/
========================================================================================

========================================================================================
== 🎯 1 - Instruções práticas 
========================================================================================

========================================================================================
== 🎯 1.1 - Verificando o tipo de tablespace padrão
========================================================================================
SQL> SET LINES 200
SQL> COL PROPERTY_NAME FORMAT A30
SQL> COL PROPERTY_VALUE FORMAT A30

SQL> SELECT property_name, property_value
     FROM database_properties
     WHERE property_name = 'DEFAULT_TBS_TYPE';

========================================================================================
== 🎯 1.2 - Checando se SYSTEM, SYSAUX e USER são BIGFILE
========================================================================================
SQL> COL TABLESPACE_NAME FORMAT A20
SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name IN ('SYSTEM','SYSAUX','USERS')
     ORDER BY 1;

========================================================================================
== 🎯 1.3 - Criando tablespaces com o padrão atual
========================================================================================
SQL> CREATE TABLESPACE x;

SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name = 'X';

========================================================================================
== 🎯 1.4 - Alterando o padrão para SMALLFILE
========================================================================================
SQL> ALTER DATABASE SET DEFAULT SMALLFILE TABLESPACE;

SQL> CREATE TABLESPACE y;

SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name IN ('X','Y');

========================================================================================
== 🎯 1.5 - Alterando novamente para BIGFILE
========================================================================================
SQL> ALTER DATABASE SET DEFAULT BIGFILE TABLESPACE;

SQL> CREATE TABLESPACE z;

SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name IN ('X','Y','Z');

========================================================================================
== 🎯 1.6 - Criando tablespaces com cláusulas explícitas
========================================================================================
SQL> CREATE SMALLFILE TABLESPACE tbs_small;

SQL> CREATE BIGFILE TABLESPACE tbs_big;

SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name IN ('TBS_SMALL', 'TBS_BIG');

SQL> SELECT property_name, property_value
     FROM database_properties
     WHERE property_name = 'DEFAULT_TBS_TYPE';


========================================================================================
== 🎯 1.7 - Executando no PDB FREEPDB1
========================================================================================
SQL> ALTER SESSION SET CONTAINER=FREEPDB1;

SQL> SELECT property_name, property_value
     FROM database_properties
     WHERE property_name = 'DEFAULT_TBS_TYPE';

SQL> CREATE TABLESPACE pdb_tbs;

SQL> SELECT tablespace_name, bigfile
     FROM   dba_tablespaces
     WHERE  tablespace_name = 'PDB_TBS';

========================================================================================
== 🎯 2 - Boas práticas
========================================================================================
💡 Ao usar Oracle 23ai, assuma que BIGFILE será o padrão para novos tablespaces, inclusive USERS.
💡 Sempre valide o tipo de tablespace antes de aplicar políticas de backup ou uso de RMAN.
💡 Use cláusulas explícitas BIGFILE ou SMALLFILE se desejar fugir do padrão configurado no banco.
💡 Bigfile tablespaces simplificam o gerenciamento do banco
⚠️ Atenção ao uso de bigfile tablespaces em ambientes standard que possuam tablespaces grandes


========================================================================================
== 📎 3 - Anexos
========================================================================================

Documentação oficial:
https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/logical-storage-structures.html#GUID-D02B2220-E6F5-40D9-AFB5-BC69BCEF6CD4


========================================================================================
== 📄 4 - Consultas auxiliares
========================================================================================

SQL> SELECT tablespace_name, contents, bigfile, status
     FROM   dba_tablespaces
     ORDER BY 1;

SQL> SELECT * FROM v$tablespace;

SQL> SELECT * FROM dba_data_files WHERE tablespace_name IN ('X','Y','Z','TBS_SMALL','TBS_BIG','PDB_TBS');

========================================================================================
== 🧹 5 - Limpando a bagunça
========================================================================================

-- No CDB
SQL> DROP TABLESPACE x INCLUDING CONTENTS AND DATAFILES;
SQL> DROP TABLESPACE y INCLUDING CONTENTS AND DATAFILES;
SQL> DROP TABLESPACE z INCLUDING CONTENTS AND DATAFILES;
SQL> DROP TABLESPACE tbs_small INCLUDING CONTENTS AND DATAFILES;
SQL> DROP TABLESPACE tbs_big INCLUDING CONTENTS AND DATAFILES;

-- No PDB
SQL> ALTER SESSION SET CONTAINER=FREEPDB1;
SQL> DROP TABLESPACE pdb_tbs INCLUDING CONTENTS AND DATAFILES;
