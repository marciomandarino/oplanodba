========================================================================================
== Aula: Como acessar um PDB no Oracle
== Nome do autor: Marcio Mandarino
== Data da geração: 11/07/2025
== https://www.linkedin.com/in/marciomandarino/
== https://mrdba.com.br/oracle_fundamentals/
========================================================================================

========================================================================================
== 🎯 1 - Instruções práticas
========================================================================================

========================================================================================
== 🎯 1.1 - Conectando usando tnsnames.ora
========================================================================================
$ cat $ORACLE_HOME/network/admin/tnsnames.ora
$ ifconfig

$ cat >> $ORACLE_HOME/network/admin/tnsnames.ora <<EOF
PDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.137)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB1)
    )
  )

PDB2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.137)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB2)
    )
  )
EOF

$ tnsping pdb1
$ tnsping pdb2

$ sqlplus system@pdb1
SQL> SHOW CON_NAME
SQL> conn system@pdb2


========================================================================================
== 🎯 1.2 - Conectando usando Easy Connect
========================================================================================
$ sqlplus system@192.168.68.137:1521/PDB1
$ sqlplus system@192.168.68.137:1521/PDB2
$ sql system@192.168.68.137:1521/PDB2


========================================================================================
== 🎯 1.3 - Conectando usando o set container
========================================================================================
$ sqlplus / as sysdba
SQL> show pdbs;
SQL> alter session set container = PDB1;
SQL> alter session set container = PDB2;
SQL> show con_name
SQL> alter session set container = cdb$root;

========================================================================================
== 🎯 1.4 - Conectando usando variável ORACLE_PDB_SID
========================================================================================
$ export ORACLE_PDB_SID=PDB1
$ sqlplus sys as sysdba
SQL> SHOW CON_NAME

$ export ORACLE_PDB_SID=PDB2
$ sqlplus sys as sysdba
SQL> SHOW CON_NAME

========================================================================================
== 🎯 2 - Boas práticas
========================================================================================

💡 Mantenha o arquivo tnsnames.ora organizado e versionado, especialmente em ambientes de produção.
💡 Utilize Easy Connect para testes rápidos sem alterar arquivos de configuração persistentes.
💡 Configure ORACLE_PDB_SID em seu perfil (bash_profile) para conexões locais automáticas.
💡 Verifique sempre o listener para garantir que o serviço do PDB está registrado: $ lsnrctl status.
💡 Use o comando SHOW CON_NAME para confirmar que você está no PDB correto.

========================================================================================
== 📎 3 - Anexos
========================================================================================

Exemplo de snippet do tnsnames.ora (em $ORACLE_HOME/network/admin/tnsnames.ora):
PDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.137)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB1)
    )
  )

PDB2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB2)
    )
  )

Exemplo de configuração em ~/.bash_profile:
export ORACLE_PDB_SID=PDB1

========================================================================================
== 📄 4 - Consultas auxiliares
========================================================================================

SQL> SET LINES 200
SQL> SET PAGESIZE 50
SQL> col name form a20
SQL> col OPEN_MODE form a20
SQL> SELECT NAME, OPEN_MODE,TOTAL_SIZE/1024/1024/1024 FROM V$PDBS;

SQL> SELECT SYS_CONTEXT('USERENV','CON_NAME') AS CONTAINER FROM DUAL;

========================================================================================
== 🧹 5 - Limpando a bagunça
========================================================================================

$ unset ORACLE_PDB_SID

# apaga todo o conteúdo do tnsnames, só execute se essa for a sua intenção:
$ cat /dev/null > $ORACLE_HOME/network/admin/tnsnames.ora
