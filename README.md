🚀 ADEUS WINDOWS 10!
A ferramenta definitiva  e 100% Brasileira para instalar o Windows 11, mesmo que seu hardware diga 'não' ao TPM, Secure Boot ou CPU antiga!
Este é um utilitário PowerShell com interface gráfica (GUI) criado para simplificar e automatizar o processo de instalação do Windows 11 em computadores que não atendem aos requisitos mínimos de hardware da Microsoft, como TPM 2.0, Secure Boot, e requisitos de RAM/CPU específicos.

✨ Recursos
O ADEUS WINDOWS 10! é mais do que um simples bypass; ele é um conjunto completo de ferramentas para sua transição para o Windows 11:
Bypass de Requisitos Essenciais: Aplica automaticamente as modificações necessárias no Registro do Windows para contornar as verificações de TPM 2.0, Secure Boot, RAM e CPU durante a instalação do Windows 11.

Backup e Restauração Segura: Antes de qualquer alteração, o script cria um backup das chaves de registro afetadas, permitindo que você restaure as configurações originais do sistema a qualquer momento, garantindo sua tranquilidade.

Opções Flexíveis de Download de ISO:
Fido.ps1 Integrado: Inicia o popular script Fido para baixar imagens ISO oficiais do Windows diretamente dos servidores da Microsoft, permitindo escolher a versão e edição desejada.
Media Creation Tool (MCT): Baixa e inicia a ferramenta oficial da Microsoft para criar sua própria ISO ou mídia de instalação do Windows 11.

Instalação Simplificada: Após selecionar a imagem ISO do Windows 11, o script a monta automaticamente como uma unidade virtual e inicia o setup.exe com um clique, agilizando o processo.
Verificação de Compatibilidade de CPU (POPCNT): Inclui uma verificação crucial para garantir que seu processador suporta a instrução POPCNT (ou SSE4.2). Este é um requisito fundamental para o Windows 11 24H2 e versões futuras que não pode ser contornado por software.

O script irá avisá-lo e desativar as funções de instalação e bypass se sua CPU não for compatível.
Interface Gráfica Intuitiva (GUI): Desenvolvido com Windows Forms, oferece uma interface de usuário amigável e passo a passo, tornando o processo acessível a todos.
Log de Status em Tempo Real: Acompanhe o progresso e qualquer mensagem importante através do console de status integrado.

⚠️ Requisitos
Sistema Operacional: Windows 10 (ou uma versão anterior do Windows que suporte PowerShell 5.1+).
PowerShell: Versão 5.1 ou superior (geralmente já instalada por padrão no Windows 10/11).

Permissões: É necessário executar o script como Administrador (o script solicitará a elevação automaticamente).
Conexão com a Internet: Essencial para baixar as ferramentas de download de ISO (Fido, MCT) e as próprias imagens.
Processador com POPCNT: ATENÇÃO! Seu processador DEVE suportar a instrução POPCNT (ou SSE4.2). Para o Windows 11 24H2 e futuras versões, este é um requisito de hardware que NÃO PODE SER CONTORNADO por software. 
O script verifica essa compatibilidade e irá bloquear as funções de bypass e instalação se seu processador não atender a esse requisito.

🛠️ Como Usar
Baixe o Script: Faça o download do arquivo ADEUS WINDOWS 10!.ps1 para o seu computador.

Execute como Administrador:
Método Recomendado: Clique com o botão direito no arquivo ADEUS WINDOWS 10!.ps1 e selecione "Executar com PowerShell". O script solicitará automaticamente as permissões de administrador.
Método Alternativo: Abra o PowerShell como Administrador.

Navegue até o diretório onde o script foi salvo e execute-o. Pode ser necessário ajustar a Política de Execução para permitir scripts:

````Set-ExecutionPolicy Bypass -Scope Process -Force; .\"ADEUS WINDOWS 10!.ps1"````
Use esse código com CUIDADO!

Powershell
Siga as Instruções na GUI:
Etapa 1: Backup e Bypass:
Clique em "Aplicar Bypass e Fazer Backup" para que o script prepare seu sistema para a instalação do Windows 11, criando também um backup de suas configurações de registro.
O botão "Restaurar do Backup" ficará ativo se um backup anterior for detectado, permitindo reverter as alterações.

Etapa 1.5 (Opcional): Obtenha sua ISO do Windows:
Use "Baixar ISO (via Fido)" para acessar diversas versões do Windows 11 diretamente dos servidores da Microsoft.
Ou utilize "Criar ISO (MCT Oficial)" para baixar a ferramenta oficial de criação de mídia da Microsoft.

Etapa 2: Selecione a ISO e Instale:
Clique em "Selecionar Arquivo ISO..." para escolher a imagem ISO do Windows 11 que você deseja instalar.
Uma vez selecionada a ISO, clique em "Iniciar Instalação". O script montará a ISO e abrirá o instalador do Windows 11 para você prosseguir.

🛑 Disclaimer
USE POR SUA CONTA E RISCO. Este script é uma ferramenta para facilitar a instalação do Windows 11 em hardware não suportado, mas não oferece garantias de compatibilidade total ou de que o sistema funcionará sem problemas após a instalação.
O script modifica o Registro do Windows. É altamente recomendável criar um ponto de restauração do sistema ou um backup completo do seu sistema operacional antes de utilizar esta ferramenta.
A instalação do Windows 11 em hardware oficialmente não suportado pode levar a problemas de desempenho, falta de drivers para componentes específicos, e, mais importante, a Microsoft pode restringir atualizações de segurança futuras para sistemas não conformes.
A verificação de POPCNT é uma barreira física. Se seu processador não a suportar, a instalação do Windows 11 24H2 e versões subsequentes irá falhar, e este script não poderá contornar essa limitação de hardware.
Este script não se responsabiliza por quaisquer danos, perdas de dados ou instabilidades no sistema que possam ocorrer.

🤝 Contribuições
Contribuições, sugestões e relatórios de bugs são muito bem-vindos! Sinta-se à vontade para abrir uma issue ou enviar um pull request.
