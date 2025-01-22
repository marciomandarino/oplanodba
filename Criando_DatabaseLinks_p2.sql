========================================================================================
== Criando tabelas a partir de um Database Link
== Marcio Mandarino
== 19/11/2024
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
📍 Copiando as tabelas de produção para dev
📍 Fazendo um update na origem dos dados
📍 Fechando um database link
📍 Data Pump Import via database link
📍 Excluindo um Database Link
📍 Conclusão


==========================================================================================
== 🎯 Visão Geral 
==========================================================================================
▶️ Através de um Database Link você pode copiar dados, criar tabelas, etc a partir de um banco remoto
▶️ É muito útil no dia a dia quando você precisa copiar certos dados a partir de um ambiente remoto
▶️ Existem algumas formas diferentes de realizar esta tarefa, usar um Database Link é uma delas
💡 Também é conhecido como "DBLink"


==========================================================================================
== 🎯 Cenário 
==========================================================================================
✅ Copiar tabelas do banco de produção para o banco de desenvolvimento


SERVIDOR        TIPO            DATABASE        OBJETO CRIADO     
------------------------------------------------------------------
srvprd01        Produção        orcl            Usuário
srvdev01        Dev             dev             Database Link


==========================================================================================
== 🎯 Criando um schema de exemplo na origem
==========================================================================================
$ . oraenv <<< ORCL
$ sqlplus / as sysdba
-- Criando o schema
SQL> create tablespace ts_sales datafile size 50M;
SQL> create user sales identified by sales;
SQL> alter user sales quota unlimited on ts_sales;
SQL> alter user sales default tablespace ts_sales;

SQL> grant create session, resource to sales;
SQL> conn sales/sales
SQL> @cria_objs.sql


CREATE TABLE DEPARTMENTS (
    DEPT_ID     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DEPT_NAME   VARCHAR2(50) NOT NULL,
    LOCATION    VARCHAR2(100),
    CONSTRAINT chk_dept_name CHECK (DEPT_NAME IS NOT NULL AND LENGTH(DEPT_NAME) >= 2)
);

CREATE TABLE EMPLOYEES (
    EMP_ID      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EMP_NAME    VARCHAR2(100) NOT NULL,
    DEPT_ID     NUMBER NOT NULL,
    SALARY      NUMBER(10, 2) NOT NULL,
    CONSTRAINT chk_salary CHECK (SALARY > 0),
    CONSTRAINT fk_dept
        FOREIGN KEY (DEPT_ID)
        REFERENCES DEPARTMENTS(DEPT_ID)
        ON DELETE CASCADE
);

CREATE TABLE PROJECTS (
    PROJ_ID     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PROJ_NAME   VARCHAR2(100) NOT NULL,
    EMP_ID      NUMBER NOT NULL,
    START_DATE  DATE DEFAULT SYSDATE,
    CONSTRAINT fk_emp
        FOREIGN KEY (EMP_ID)
        REFERENCES EMPLOYEES(EMP_ID)
        ON DELETE SET NULL,
    CONSTRAINT chk_proj_name CHECK (PROJ_NAME IS NOT NULL AND LENGTH(PROJ_NAME) >= 3)
);

CREATE INDEX idx_emp_dept ON EMPLOYEES(DEPT_ID);
CREATE INDEX idx_proj_emp ON PROJECTS(EMP_ID);

INSERT INTO DEPARTMENTS (DEPT_NAME, LOCATION) VALUES ('Recursos Humanos', 'São Paulo');
INSERT INTO DEPARTMENTS (DEPT_NAME, LOCATION) VALUES ('TI', 'Rio de Janeiro');
INSERT INTO DEPARTMENTS (DEPT_NAME, LOCATION) VALUES ('Financeiro', 'Belo Horizonte');

INSERT INTO EMPLOYEES (EMP_NAME, DEPT_ID, SALARY) VALUES ('Alice Silva', 1, 5000);
INSERT INTO EMPLOYEES (EMP_NAME, DEPT_ID, SALARY) VALUES ('Bruno Souza', 2, 7000);
INSERT INTO EMPLOYEES (EMP_NAME, DEPT_ID, SALARY) VALUES ('Carla Mendes', 3, 6500);

INSERT INTO PROJECTS (PROJ_NAME, EMP_ID, START_DATE) VALUES ('Recrutamento 2025', 1, TO_DATE('2025-01-10', 'YYYY-MM-DD'));
INSERT INTO PROJECTS (PROJ_NAME, EMP_ID, START_DATE) VALUES ('Desenvolvimento do Portal', 2, TO_DATE('2025-02-15', 'YYYY-MM-DD'));
INSERT INTO PROJECTS (PROJ_NAME, EMP_ID, START_DATE) VALUES ('Auditoria Financeira', 3, TO_DATE('2025-03-20', 'YYYY-MM-DD'));


CREATE TABLE EMPLOYEES_LOG (
    LOG_ID          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EMP_ID          NUMBER,
    OPERACAO        VARCHAR2(10),
    USUARIO         VARCHAR2(30),
    DATA_OPERACAO   TIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_emp_audit
AFTER INSERT OR UPDATE OR DELETE
ON EMPLOYEES
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO EMPLOYEES_LOG (EMP_ID, OPERACAO, USUARIO, DATA_OPERACAO)
        VALUES (:NEW.EMP_ID, 'INSERT', USER, SYSTIMESTAMP);
    ELSIF UPDATING THEN
        INSERT INTO EMPLOYEES_LOG (EMP_ID, OPERACAO, USUARIO, DATA_OPERACAO)
        VALUES (:NEW.EMP_ID, 'UPDATE', USER, SYSTIMESTAMP);
    ELSIF DELETING THEN
        INSERT INTO EMPLOYEES_LOG (EMP_ID, OPERACAO, USUARIO, DATA_OPERACAO)
        VALUES (:OLD.EMP_ID, 'DELETE', USER, SYSTIMESTAMP);
    END IF;
END;
/


CREATE OR REPLACE FUNCTION calcular_bonus(p_emp_id NUMBER) RETURN NUMBER IS
    v_salario EMPLOYEES.SALARY%TYPE;
    v_bonus NUMBER;
BEGIN
    SELECT SALARY INTO v_salario FROM EMPLOYEES WHERE EMP_ID = p_emp_id;
    v_bonus := v_salario * 0.10;
    RETURN v_bonus;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

CREATE OR REPLACE PROCEDURE adicionar_projeto (
    p_proj_name  VARCHAR2,
    p_emp_id     NUMBER,
    p_start_date DATE
) AS
BEGIN
    INSERT INTO PROJECTS (PROJ_NAME, EMP_ID, START_DATE)
    VALUES (p_proj_name, p_emp_id, p_start_date);
    COMMIT;
END;
/


==========================================================================================
== 🎯 Criando um usuário para o db_link com permissões na origem
==========================================================================================
SQL> create user lk_srvdev01_expdp identified by "Welcome1";
SQL> grant create session to lk_srvdev01_expdp;
SQL> GRANT exp_full_database TO lk_srvdev01_expdp;


==========================================================================================
== 🎯 Criando o Database Link sem o tnsnames
==========================================================================================
SQL> CREATE DATABASE LINK dblk_srvprod01_expdp
CONNECT TO lk_srvdev01_expdp IDENTIFIED BY "Welcome1"
USING '(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.68.126)(PORT = 1521))
  (CONNECT_DATA = (SERVICE_NAME = orcl)))';


==========================================================================================
== 🎯 Criando um diretório
==========================================================================================
SQL> create or replace directory dir_data_pump as '/tmp/';


==========================================================================================
== 🎯 Criando a tablespace
==========================================================================================
SQL> create tablespace ts_sales datafile size 50m;


==========================================================================================
== 🎯 Importando do schema de origem SALES para o destino SALES 
==========================================================================================
$ impdp  \"/ as sysdba\"  directory=dir_data_pump schemas=sales network_link=dblk_srvprod01_expdp 


==========================================================================================
== 🎯 Importando do schema de origem SALES para o destino SALES_DEV
==========================================================================================
$ impdp  \"/ as sysdba\"  directory=dir_data_pump schemas=sales network_link=dblk_srvprod01_expdp  remap_schema=SALES:SALES_DEV


==========================================================================================
== 🎯 Importando apenas a tabela DEPARTMENTS do schema de origem SALES para o destino SALES_DEV
==========================================================================================
$ impdp  \"/ as sysdba\"  directory=dir_data_pump tables=sales.DEPARTMENTS table_exists_action=replace network_link=dblk_srvprod01_expdp  remap_schema=SALES:SALES_DEV


==========================================================================================
== 🎯 Verificando os objetos importados
==========================================================================================

SQL> col object_name form a20
SQL> col status form a15
SQL> select object_name, object_type, status from dba_objects where owner = 'SALES';

SQL> col object_name form a20
SQL> col status form a15
SQL> select object_name, object_type, status from dba_objects where owner = 'SALES_DEV';


==========================================================================================
== 🎯 Restrições
==========================================================================================
https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html#GUID-0871E56B-07EB-43B3-91DA-D1F457CF6182


==========================================================================================
== 🎯 Boas práticas
==========================================================================================
💡 Antes de usar o Datapump com network link, você deve primeiro
    ▫️ Domine o uso do data pump export e import
    ▫️ Donine o uso de Database Links
💡 Pratique bastante em laboratórios esses conceitos antes de fazer em um ambiente produtivo
🔥 Preste sempre atenção aonde você está executando os comandos