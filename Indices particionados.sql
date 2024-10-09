========================================================================================
== Índices Particionados no Oracle
== Marcio Mandarino
== 08/10/2024
== marcio@mrdba.com.br
== www.mrdba.com.br
== https://www.linkedin.com/in/marciomandarino/
========================================================================================

🌎 Referências
https://docs.oracle.com/en/database/oracle/oracle-database/19/vldbg/index-partitioning.html


==========================================================================================
== 🎯 Resumo do vídeo
========================================================================================
📍 Visão Geral
📍 Por que usar índices particionados?
📍 Diferença entre índices locais e globais
📍 Tipos de índices particionados
📍 Exemplo de criação de índice particionado local
📍 Exemplo de criação de índice particionado global
📍 Exemplo de índice particionado composto
📍 Indice particionado em uma tabela não particionada
📍 Melhores práticas para uso de índices particionados
📍 Conclusão

==========================================================================================
== 🎯 Visão Geral
========================================================================================
▶️ Índices particionados são úteis para melhorar o desempenho de consultas em tabelas muito grandes.
▶️ Eles dividem os dados do índice em partições menores, que podem ser gerenciadas e acessadas separadamente.
▶️ São especialmente benéficos para operações de manutenção, como rebuild e manutenção de índices, sem a necessidade de processar o índice inteiro.
▶️ Você pode criar indices particionados em tabelas não particionadas

==========================================================================================
== 🎯 Por que usar índices particionados?
========================================================================================
▶️ Melhor performance de consultas em tabelas de grandes volumes de dados.
▶️ Maior facilidade de manutenção
▶️ Melhora o desempenho de consultas de faixa de dados (range queries) e operações paralelas.
▶️ Pode reduzir o impacto de bloqueios e contenção de recursos.


==========================================================================================
== 🎯 Restrições
========================================================================================
▶️ Em alguns casos, os índices particionados não podem ser utilizados:
  ▫️ O indice é um cluster index
  ▫️ O indice é definido em uma tabela clusterizada


==========================================================================================
== 🎯 Tipos de Índices Particionados
========================================================================================
▶️ Índices Locais:
  ▫️ Um índice local é particionado da mesma forma que a tabela.
  ▫️ Cada partição do índice corresponde a uma partição da tabela.
  ▫️ As operações são realizadas na partição correspondente, o que facilita o gerenciamento.
  ▫️ Útil quando as operações se concentram em partições específicas da tabela.

▶️ Índices Globais:
  ▫️ Um índice global não segue a mesma partição da tabela.
  ▫️ As partições do índice são independentes da tabela, podendo ser particionadas de forma diferente.
  ▫️ Oferece mais flexibilidade para otimização de consultas que cobrem várias partições da tabela.
  ▫️ Pode ser útil em cenários onde há consultas que acessam múltiplas partições.


==========================================================================================
== 🎯 Criando estrutura inicial
==========================================================================================

-- Criando um usuário teste
SQL> create user teste identified by teste;
SQL> grant create session, resource to teste;
SQL> alter user teste quota unlimited on users;

SQL> alter session set current_schema = teste;

-- Criação de uma tabela particionada por intervalo
SQL> CREATE TABLE sales (
  sale_id NUMBER,
  sale_date DATE,
  amount NUMBER,
  customer_id NUMBER
)
  PARTITION BY RANGE (
        sale_date
    ) INTERVAL ( numtoyminterval(1, 'MONTH') ) ( PARTITION p0
        VALUES LESS THAN ( TO_DATE('01/01/2019', 'DD/MM/RRRR') )
    );

-- Fazendo uma carga na tabela

SQL> set timing on
SQL> DECLARE
  v_start_date  DATE := TO_DATE('2022/01', 'YYYY/MM');
  v_end_date    DATE := LAST_DAY(TO_DATE('2024/10', 'YYYY/MM'));
  v_quantity    NUMBER := 1500000;
  v_random_date DATE;
  v_random_amount NUMBER;
  v_random_customer_id NUMBER;
BEGIN
  FOR i IN 1 .. v_quantity LOOP
    -- Gera uma data aleatória entre v_start_date e v_end_date
    v_random_date := v_start_date + DBMS_RANDOM.VALUE(0, v_end_date - v_start_date);

    -- Gera um valor aleatório para o campo amount (valores entre 10 e 1000, por exemplo)
    v_random_amount := ROUND(DBMS_RANDOM.VALUE(10, 1000), 2);

    -- Gera um ID de cliente aleatório (exemplo de IDs entre 1 e 100)
    v_random_customer_id := TRUNC(DBMS_RANDOM.VALUE(1, 100));

    -- Insere o registro na tabela sales
    INSERT INTO sales (sale_id, sale_date, amount, customer_id)
    VALUES (
      i,  -- Usando o contador do loop como sale_id (poderia ser uma sequence)
      v_random_date,
      v_random_amount,
      v_random_customer_id
    );
  END LOOP;

  -- Confirma a transação
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Inserção de ' || v_quantity || ' registros concluída.');
END;
/

SQL> exec dbms_stats.gather_table_stats (ownname => 'TESTE', tabname => 'SALES', cascade => TRUE, degree=>2);

SQL> set timing off

==========================================================================================
== 🎯 Informações sobre a tabela particionada
==========================================================================================
SQL> set lines 400
SQL> col table_name form a30
SQL> col last_analyzed form a30
SQL> col num_rows form 999,999,999,999

SQL> SELECT
    table_name,
    num_rows,
    to_Char(last_analyzed,'DD/MM/RRRR HH24:MI:SS') last_analyzed,
    partitioned
FROM
    dba_tables
WHERE
        owner = 'TESTE'
    AND table_name IN ( 'SALES' );


SQL> SELECT
    table_name,
    partitioning_type,
    autolist
FROM
    dba_part_tables
WHERE
        owner = 'TESTE'
    AND table_name = 'SALES';

SQL> col TABLE_NAME form a22
SQL> col PARTITION_NAME form a20
SQL> col HIGH_VALUE form a90
SQL> SELECT
    a.table_name,
    a.partition_name,
    a.num_rows,
    b.bytes / 1024 / 1024 size_mb,
    a.high_value
FROM
    dba_tab_partitions a,
    dba_segments       b
WHERE
        a.table_owner = b.owner
    AND a.table_name = b.segment_name
    AND a.partition_name = b.partition_name
    AND table_owner = 'TESTE'
    AND table_name = 'SALES'
ORDER BY
    partition_name;


==========================================================================================
== 🎯 Exemplo de Criação de Índice Particionado Local
==========================================================================================

▶️ Criando o índice local para essa tabela:

SQL> CREATE INDEX idx_sales_amount ON sales(sale_date)
LOCAL ;

💡 Neste exemplo, cada partição do índice corresponde diretamente a uma partição da tabela.


==========================================================================================
== 🎯 Exemplo de Criação de Índice Particionado Global
==========================================================================================
Agora, um exemplo de índice particionado global por intervalo:


CREATE INDEX idx_global_sales ON sales(sale_id)
GLOBAL PARTITION BY RANGE (sale_id) (
 partition part01 values less than (100000),
 partition part02 values less than (200000),
 partition part03 values less than (300000),
 partition part04 values less than (400000),
 partition part05 values less than (500000),
 partition part06 values less than (600000),
 partition part07 values less than (700000),
 partition part08 values less than (800000),
 partition part09 values less than (900000),
 partition part10 values less than (1000000),
 partition part11 values less than (1100000),
 partition part12 values less than (1200000),
 partition part13 values less than (1300000),
 partition part14 values less than (1400000),
 partition part15 values less than (1500000),
 partition pmax values less than (maxvalue));
  

▶️ Neste caso, o índice é particionado de forma diferente da tabela. As partições do índice global não seguem as partições da tabela diretamente, oferecendo mais flexibilidade.

==========================================================================================
== 🎯 Exemplo de Índice Particionado Composto
==========================================================================================
Aqui temos um exemplo de índice composto, particionado por intervalo e com várias colunas:

CREATE INDEX idx_sales_composite ON sales(customer_id, sale_date)
local;


▶️ Neste exemplo, estamos utilizando um índice composto de customer_id e sale_date, com particionamento por sale_date. Isso é útil para otimizar consultas que utilizam ambas as colunas em suas condições.


==========================================================================================
== 🎯 Informações sobre os indices particionados
==========================================================================================
SQL> col index_name form a30
SQL> col owner form a30

SQL> SELECT
    index_name,
    partitioning_type,
    locality
FROM
    dba_part_indexes
WHERE
        owner = 'TESTE'
    AND table_name = 'SALES';


SQL> SELECT
    owner,
    index_name,
    partitioned
FROM
    dba_indexes
WHERE
        owner = 'TESTE'
    AND table_name = 'SALES';

SQL> SELECT
    a.index_name,
    a.partition_name,
    a.num_rows,
    b.bytes / 1024 / 1024 size_mb,
    a.high_value
FROM
    dba_ind_partitions a,
    dba_segments       b
WHERE
        a.index_owner = b.owner
    AND a.index_name = b.segment_name
    AND a.partition_name = b.partition_name
    AND index_owner = 'TESTE'
    AND index_name = 'IDX_GLOBAL_SALES'
ORDER BY
    partition_name;
    

==========================================================================================
== 🎯 Indice particionado em uma tabela não particionada
==========================================================================================
SQL> create table tb_teste as select * from dba_objects;

SQL> CREATE INDEX idx_global_tb_teste ON tb_teste (object_id)
GLOBAL
PARTITION BY RANGE (object_id)
(
    PARTITION part1 VALUES LESS THAN (10000),
    PARTITION part2 VALUES LESS THAN (50000),
    PARTITION part3 VALUES LESS THAN (100000),
    PARTITION part4 VALUES LESS THAN (MAXVALUE)
);


==========================================================================================
== 🎯 Melhores práticas para Uso de Índices Particionados
==========================================================================================
▶️ Escolha o particionamento correto: O tipo de particionamento (intervalo, lista, hash) deve refletir o padrão de acesso aos dados.
▶️ Manutenção de índices particionados: Manter o índice rebuildado regularmente, principalmente após operações de grande volume.
▶️ Evite criar muitos índices globais: Índices globais podem aumentar a complexidade da manutenção, especialmente em tabelas grandes.
▶️ Utilize paralelismo: A reconstrução e manutenção de índices particionados podem se beneficiar do uso de paralelismo.


==========================================================================================
== 🏁 Conclusão
==========================================================================================
💡 Índices particionados são uma ferramenta poderosa para gerenciar grandes volumes de dados de forma eficiente.
💡 A escolha entre índices locais e globais depende da natureza das consultas e operações que você precisa executar.
💡 A flexibilidade dos índices particionados no Oracle permite otimizações significativas tanto em desempenho quanto em manutenção.

