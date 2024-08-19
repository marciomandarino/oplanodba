========================================================================================
== Adicionando um datafile em tablespaces no Oracle
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
📍 Conceito Geral
📍 Criando uma estrutura de testes
📍 Verificando a ocupação das tablespaces
📍 Buscando mais informações sobre a tablespace
📍 Verificando se o banco usa OMF
📍 Verificando espaço no ASM
📍 Adicionando um datafile, usando OMF (File System)
📍 Adicionando um datafile, sem OMF (File System)
📍 Adicionando um datafile (ASM)
📍 Conclusão


==========================================================================================
== 🎯 Conceito Geral
==========================================================================================
▶️ Um DBA precisa gerenciar o espaço nas tablespaces
▶️ Quando você vai adicionar um datafile, você precisa ficar atento nas seguintes questões:
    ▫️ Se o banco usa OMF
    ▫️ Localização dos arquivos de dados (ASM ou File System)
    ⚠️ Espaço no local de destino
    ▫️ Característica da tablespace (Smallfile ou Bigfile)



==========================================================================================
== 🎯 Criando uma estrutura de testes
==========================================================================================
-- Tablespace com OMF
SQL> create tablespace ts_omf datafile size 10m autoextend on next 10m maxsize 1g;

-- Tablespace sem OMF
SQL> create tablespace ts_semomf datafile '/u02/oradata/ORCL/datafile/ts_semomf_1.dbf' size 10m;

-- Tablespace ASM
SQL> create tablespace ts_asm datafile '+DATA' size 10m autoextend on next 10m maxsize 1g;


==========================================================================================
== 🎯 Verificando a ocupação das tablespaces
==========================================================================================
$ . oraenv
$ sqlplus / as sysdba

SQL> SET LINES 1000
SQL> COL "TAMANHO_MB" FORM 999,999,999.9
SQL> COL "MAXIMO_MB" FORM 999,999,999.9
SQL> COL "LIVRE_MB" FORM 999,999,999.9

SQL> SELECT
    tablespace_name,
    round(SUM(bytes) / 1024 / 1024  ,1) AS "TAMANHO_MB",
    round(SUM(maxbytes) / 1024 / 1024  ,1) AS "MAXIMO_MB",
    round((SUM(maxbytes) - SUM(bytes)) /   1024 / 1024,1) AS "LIVRE_MB", 
    count(1) AS "TOT_FILES"
FROM
    dba_data_files
GROUP BY tablespace_name
ORDER BY tablespace_name;



==========================================================================================
== 🎯 Buscando mais informações sobre a tablespace
==========================================================================================
SQL> SELECT
    tablespace_name,
    bigfile
FROM
    dba_tablespaces 
    order by tablespace_name;

SQL> col file_name form a60
SQL> select file_name from dba_data_files where tablespace_name like 'TS%';

==========================================================================================
== 🎯 Verificando se o banco usa OMF
==========================================================================================
$ . oraenv
$ sqlplus / as sysdba

SQL> show parameter db_create_file_dest;


==========================================================================================
== 🎯 Verificando espaço no File System
==========================================================================================
$ df -h /u02

==========================================================================================
== 🎯 Verificando espaço no ASM
==========================================================================================
$ . oraenv
$ sqlplus / as sysdba

SQL> SELECT
    name,
    round(total_mb / 1024, 1)                       size_gb,
    round(free_mb / 1024, 1)                        free_gb,
    round((total_mb - free_mb) / 1024, 1)           ocupation_gb,
    round((total_mb - free_mb) / total_mb * 100, 2) "OCUPATION %"
FROM
    v$asm_diskgroup;


==========================================================================================
== 🎯 Adicionando um datafile, usando OMF (File System)
==========================================================================================
SQL> ALTER TABLESPACE ts_omf ADD DATAFILE SIZE 100M autoextend on next 10m maxsize 1g;


==========================================================================================
== 🎯 Adicionando um datafile, sem OMF (File System)
==========================================================================================
SQL> ALTER TABLESPACE ts_omf ADD DATAFILE '/u02/oradata/ORCL/datafile/ts_semomf_a_1' SIZE 100M;


==========================================================================================
== 🎯 Adicionando um datafile (ASM)
==========================================================================================

-- Especificando o Disk Group
SQL> ALTER TABLESPACE ts_asm ADD DATAFILE '+DATA' SIZE 100M autoextend on next 10m maxsize 1g;

-- Sem especificar o Disk Group
SQL> ALTER TABLESPACE ts_asm ADD DATAFILE SIZE 100M autoextend on next 10m maxsize 1g;


==========================================================================================
== 🏁 Conclusão
==========================================================================================
💡 Monitore o espaço das suas tablespaces
⚠️ Fique alerta com relação ao espaço no destino dos datafiles
⚠️ Quando especificar um caminho da datafile, faça com cuidado