#!/bin/bash

# Atualizar os pacotes do sistema
echo "Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

# Função para instalar ou atualizar o Docker Compose
instalar_ou_atualizar_docker_compose() {
    # Verificar se o Docker Compose já está instalado
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose já está instalado. Atualizando para a versão mais recente..."
        # Baixar e atualizar o Docker Compose para a versão mais recente
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    else
        echo "Docker Compose não está instalado. Instalando a versão mais recente..."
        # Baixar e instalar o Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    fi

}

# Chamar a função para instalar ou atualizar o Docker Compose
instalar_ou_atualizar_docker_compose

# Verificar a versão do Docker Compose para confirmar a instalação ou atualização
echo "Verificando a instalação do Docker Compose..."
docker-compose --version

# Executar o Docker Compose
echo "Executando docker-compose up -d..."
sudo docker-compose up -d
