========================================================================================
== Instalando Oracle Linux 9 - Server With GUI com VirtualBox e MobaXterm (com particionamento manual)
== Marcio Mandarino
== 05/05/2025
== marcio@mrdba.com.br
== www.mrdba.com.br
== https://www.linkedin.com/in/marciomandarino/
== https://mrdba.com.br/oracle_fundamentals/
========================================================================================

========================================================================================
== 🎯 Resumo deste vídeo 
========================================================================================
📍 Objetivos
📍 Conceitos 
📍 Gerais
📍 Baixar os instaladores
📍 Criar nova VM no VirtualBox
📍 Instalação do OL9 Server With GUI
📍 Conexão com o Moba
📍 Instalar pacotes adicionais
📍 Update dos pacotes do Sistema Operacional
📍 Boas Práticas
📍 Cuidados
📍 Conclusão


========================================================================================
== 🎯 Objetivos 
========================================================================================
▶️ Criar e configurar uma VM no VirtualBox
▶️ Instalar o Oracle Linux 9 com perfil mínimo e particionamento manual
▶️ Habilitar e testar acesso remoto via MobaXterm (SSH)


========================================================================================
== 🎯 Conceitos Gerais 
========================================================================================
▶️ Minimal Install oferece um sistema enxuto ideal para servidores
▶️ O VirtualBox simula ambientes completos em seu PC
▶️ O MobaXterm facilita conexões SSH e edição de arquivos remotamente
▶️ Particionamento adequado garante organização e performance do sistema


========================================================================================
== 🎯 Baixar os instaladores 
========================================================================================
▶️ Baixar os instaladores:
▫️ Oracle Linux 9: https://yum.oracle.com/oracle-linux-isos.html
▫️ VirtualBox: https://www.virtualbox.org/wiki/Downloads
▫️ MobaXterm: https://mobaxterm.mobatek.net/download-home-edition.html


========================================================================================
== 🎯 Criar nova VM no VirtualBox
========================================================================================
▶️ Criar nova VM no VirtualBox:
▫️ Nome: OL9M
▫️ Imagem ISO: Selecionar ISO baixada da Internet
▫️ Tipo: Linux / Oracle (64-bit)
▫️ Pular instalação Dessasistida
▫️ RAM: 2048 MB
▫️ CPU: 1
▫️ Disco: 100 GB (VDI, dinâmico)
▫️ Rede: Ativar placa de rede 1 em modo 'Bridge Adapter'


========================================================================================
== 🎯 Instalação do OL9 Minimal Install
========================================================================================
▶️ Escolher idioma Inglês

▶️ Localization
	▫️ Time & Date: Selecionar a sua região

▶️ User Settings
	▫️ Root Password: Definir uma senha (Allow root SSH login with password)
	▫️ User Creation: Criar um usuário administrativo

▶️ Software
	▫️ Software Selection: Minimal Install

▶️ System
	▫️ Network & Host Name: Habilitar placa de rede (default), definir nome e salvar IP (192.168.68.129)
	▫️ Instalation Destination (Custom)
		🔘 /boot     → 1 GB
		🔘 swap      → 4 GB
		🔘 /         → 15 GB
		🔘 /home     → 10 GB
		🔘 /tmp      → 5 GB
		🔘 /opt      → 10 GB
		🔘 /oradata  → 30 GB
		🔘 /backup   → 25 GB

▶️ Durante a instalação, criar um usuário administrativo:
▫️ Nome: marciomandarino
▫️ Grupo: wheel (marcar opção para tornar administrador/superusuário)
▫️ Senha: [defina uma senha forte]
💡 Este usuário poderá executar comandos com sudo após a instalação.


========================================================================================
== 🎯 Conexão com o Moba
========================================================================================
▶️ Descompacte o Moba
▶️ Crie uma nova conexão conexão o servidor


=================================================================
== 🎯 Instalar pacotes adicionais
=================================================================
# dnf install -y mlocate net-tools glibc-all-langpacks langpacks-en wget vim unzip 


=================================================================
== 🎯 Update dos pacotes do Sistema Operacional
=================================================================
# dnf update -y


# df -h
# cat /etc/oracle-release
# lscpu
# free -m


========================================================================================
== 🎯 Boas Práticas 
========================================================================================
💡 Use snapshots do VirtualBox após configurar o sistema
💡 Use Minimal Install + pacotes sob demanda
💡 Automatize inicializações com shell scripts


========================================================================================
== 🎯 Cuidados 
========================================================================================
🔥 Particionamento manual exige atenção com tamanhos
🔥 SSH deve estar ativo para conexão remota


========================================================================================
== 🎯 Conclusão 
========================================================================================
💡 Com o Oracle Linux 9 instalado via Minimal Install e acessível via MobaXterm,
   você tem um ambiente ideal para testes e preparação de servidores Oracle.