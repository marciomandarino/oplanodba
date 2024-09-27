========================================================================================
== SQL*Plus Easy Connect
== Marcio Mandarino
== 27/09/2024
== marcio@mrdba.com.br
== www.mrdba.com.br
== https://www.linkedin.com/in/marciomandarino/
========================================================================================

🌎 Referências
https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/connecting-to-database.html#GUID-83B35623-4306-4E67-8E62-797B7F0D2C1F

==========================================================================================
== 🎯 Resumo do vídeo
==========================================================================================
📍 Visão Geral
📍 O que é o Easy Connect
📍 Vantagens de usar Easy Connect
📍 Estrutura da sintaxe
📍 Como conectar usando o Easy Connect
📍 Exemplos práticos de conexão
📍 Utilizando o Easy Connect com SQL*Plus
📍 Usando Easy Connect com ferramentas gráficas
📍 Conclusão


==========================================================================================
== 🎯 Visão Geral
==========================================================================================
▶️ O Easy Connect é uma forma simplificada de se conectar ao Oracle Database sem precisar de entradas no arquivo tnsnames.ora.
▶️ Permite conexões diretas usando apenas o host, a porta e o serviço do banco de dados.
▶️ Ideal para ambientes de desenvolvimento, testes rápidos e quando não se deseja modificar arquivos de configuração de rede.


==========================================================================================
== 🎯 O que é o Easy Connect
==========================================================================================
▶️ É um método de conexão ao Oracle Database usando uma string de conexão simplificada.
▶️ Não requer configuração prévia no arquivo tnsnames.ora ou sqlnet.ora.
▶️ Facilita conexões diretas usando os parâmetros básicos: host, porta e service name.


==========================================================================================
== 🎯 Vantagens de usar Easy Connect
==========================================================================================
▶️ Reduz a necessidade de configurar arquivos de rede como tnsnames.ora.
▶️ Facilita testes de conexão e resolução de problemas.
▶️ Pode ser utilizado por ferramentas de linha de comando e interfaces gráficas.
▶️ Ideal para ambientes que mudam constantemente, como desenvolvimento ou testes.


==========================================================================================
== 🎯 Estrutura da sintaxe
==========================================================================================
▶️ Sintaxe básica:
$ sqlplus username/password@host:port/service_name


==========================================================================================
== 🎯 Como conectar usando o Easy Connect
==========================================================================================
▶️ Para conectar, você precisa saber:
  ▫️ Nome do usuário e senha.
  ▫️ Host do banco de dados (endereço IP ou nome de rede).
  ▫️ Porta do listener (geralmente 1521).
  ▫️ Nome do serviço (service name).
▶️ Exemplos de conexões comuns usando SQL*Plus:


==========================================================================================
== 🎯 Exemplos práticos de conexão
==========================================================================================
▶️ Conexão direta com serviço especificado:

▶️ Exemplo de uso:
$ sqlplus system/"Welcome1"@192.168.68.120:1521/DEV
$ sqlplus system/"Welcome1"@192.168.68.126:1521/ORCL
$ sqlplus pdbadmin/"Welcome1"@192.168.68.126:1521/PDB1
$ sqlplus sys/"Welcome1"@192.168.68.126:1521/CDB1 as sysdba


==========================================================================================
== 🎯 Utilizando o Easy Connect com SQL*Plus
==========================================================================================
▶️ O SQLPlus é uma das ferramentas mais utilizadas para testar conexões com o Easy Connect.
▶️ Passo a passo para testar a conectividade:
  ▫️ Certifique-se de que o listener está ativo no host de destino.
  ▫️ Utilize o comando tnsping para verificar a conectividade.
  ▫️ Teste a conexão com o comando SQLPlus direto.

==========================================================================================
== 🎯 Usando Easy Connect com ferramentas gráficas
==========================================================================================
▶️ Ferramentas como SQL Developer, TOAD e outras também suportam o Easy Connect.
▶️ Insira as mesmas informações da linha de comando na interface gráfica.
▶️ Exemplos de como configurar as conexões usando Easy Connect.


==========================================================================================
== 🏁 Conclusão
==========================================================================================
💡 Easy Connect simplifica conexões ao Oracle sem precisar de configuração extra.
💡 Ideal para ambientes dinâmicos e para DBAs que precisam testar conexões rapidamente.
💡 Fique atento a parâmetros adicionais que podem ser utilizados para aumentar a segurança e a confiabilidade da conexão.
