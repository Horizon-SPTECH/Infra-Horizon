# Repositório de Infraestrutura - Projeto Horizon

Este repositório contém os arquivos de configuração e automação necessários para a infraestrutura do **Projeto Pesquisa e Inovação - Grupo 6**. Ele é responsável por fornecer suporte à implantação, execução e gerenciamento do ambiente do projeto, garantindo consistência e eficiência no desenvolvimento.

## 📋 Visão Geral
O repositório de infraestrutura tem como objetivo facilitar a configuração do ambiente do projeto utilizando ferramentas modernas, como Docker e Shell scripts. Ele centraliza os arquivos essenciais para a criação e manutenção do ambiente, permitindo que os desenvolvedores e colaboradores iniciem rapidamente o trabalho com o sistema.

## ✨ Funcionalidades
- **Docker Compose**: Define e gerencia os serviços necessários para a execução do projeto, como banco de dados e backend.
- **Shell Scripts**: Scripts automatizados para inicialização, execução e manutenção do ambiente.
- **Integração Simplificada**: Facilita a integração entre os diferentes componentes do projeto (frontend, backend e banco de dados).

## 🛠️ Tecnologias Utilizadas
- **Docker**: Ferramenta de contêineres para isolar e padronizar o ambiente.
- **Docker Compose**: Orquestração de contêineres para configuração simplificada.
- **Shell**: Scripts para automação de tarefas comuns.
- **Linux/Unix**: Base para execução dos scripts de infraestrutura.

## 📂 Estrutura do Repositório
├── LICENSE               # Arquivo de licença do projeto  
├── README.md             # Documentação deste repositório  
├── compose.sh            # Script para configurar e iniciar o ambiente com Docker Compose  
├── docker-compose.yml    # Arquivo de configuração do Docker Compose  
└── shell.sh              # Script para inicializar as imagens sem docker compose (tem que configurar as variáveis de ambiente)




## 🚀 Como Usar
### Pré-requisitos
Certifique-se de ter as seguintes ferramentas instaladas no seu sistema:
- **Docker**
- **Docker Compose**
- **Bash** (ou outro shell compatível)

### Passos para Configuração
1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/projeto-infra.git
   cd projeto-infra
   ```
2. Arrume as váriaveis de ambiente dentro do arquivo docker-compose.yml
   ```bash
   nano docker-compose.yml
   ```
3. Execute o arquivo compose.sh
   ```bash
   sudo ./compose.sh
   ```

## 📦 Integração com o Repositório Principal
Este repositório deve ser utilizado em conjunto com o [repositório principal do projeto](https://github.com/Horizon-SPTECH/Projeto-Horizon). Certifique-se de que todas as dependências estão instaladas e que as configurações do arquivo .env estão corretas para o ambiente local.
