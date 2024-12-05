#!/bin/bash

# Variáveis de containers e rede
MYSQL_CONTAINER="mysql-horizon"
NODE_CONTAINER="node-horizon"
JAVA_CONTAINER="java-horizon"
NETWORK_NAME="redeHorizon"

# Variáveis de configuração do MySQL
MYSQL_ROOT_PASSWORD=""
MYSQL_DATABASE=""
MYSQL_USER=""
MYSQL_PASSWORD=""

# Variáveis de ambiente para o container Java
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_SESSION_TOKEN=""
DB_URL="jdbc:mysql://ipdainstancia:3306/projetoHorizon"
DB_USERNAME="Horizon"
DB_PASSWORD="horizon123"
NAME_BUCKET="nomedobucket"

# Verificação e instalação do Docker
echo "Verificando se o Docker está instalado..."
if ! [ -x "$(command -v docker)" ]; then
    echo "Docker não está instalado. Instalando Docker..."
    sudo apt update
    sudo apt install -y docker.io
else
    echo "Docker já está instalado. Realizando upgrade..."
    sudo apt update
    sudo apt upgrade -y docker.io
fi

# Função para verificar se o container existe
function container_exists() {
    docker ps -a --format '{{.Names}}' | grep -Eq "^${1}$"
}

# Criar rede se não existir
if ! docker network ls --format '{{.Name}}' | grep -Eq "^${NETWORK_NAME}$"; then
    echo "Criando rede $NETWORK_NAME..."
    docker network create $NETWORK_NAME
else
    echo "Rede $NETWORK_NAME já existe."
fi

# Criação e verificação do container MySQL
if container_exists $MYSQL_CONTAINER; then
    if docker ps --format '{{.Names}}' | grep -Eq "^${MYSQL_CONTAINER}$"; then
        echo "Container $MYSQL_CONTAINER já está rodando."
    else
        echo "Iniciando container $MYSQL_CONTAINER..."
        docker start $MYSQL_CONTAINER
    fi
else
    echo "Criando e rodando container $MYSQL_CONTAINER..."
    docker run -d \
        --name $MYSQL_CONTAINER \
        --network $NETWORK_NAME \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -e MYSQL_USER=$MYSQL_USER \
        -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
        -v $(pwd)/init-db:/docker-entrypoint-initdb.d \
        -p 3306:3306 \
        mysql:8.0
    echo "Aguardando MySQL iniciar..."
    sleep 5
fi

# Verificação e cópia do arquivo SQL
mkdir -p init-db
if [ ! -f "init-db/script.sql" ]; then
    if [ -f "$HOME/aws/script.sql" ]; then
        echo "Copiando script.sql de $HOME/aws/script.sql para init-db..."
        cp "$HOME/aws/script.sql" init-db/
    else
        echo "O arquivo script.sql não foi encontrado. Adicione seu script SQL em $HOME/aws."
        exit 1
    fi
fi

# Criação e verificação do container Node
if container_exists $NODE_CONTAINER; then
    if docker ps --format '{{.Names}}' | grep -Eq "^${NODE_CONTAINER}$"; then
        echo "Container $NODE_CONTAINER já está rodando. Atualizando o repositório..."
        cd projeto/Projeto-Horizon && git pull
    else
        echo "Iniciando container $NODE_CONTAINER e atualizando o repositório..."
        cd projeto/Projeto-Horizon && git pull
        docker start $NODE_CONTAINER
    fi
else
    echo "Clonando repositório e configurando container Node..."
    mkdir -p projeto
    rm -rf projeto/Projeto-Horizon
    git clone https://github.com/Horizon-SPTECH/Projeto-Horizon.git projeto/Projeto-Horizon

    cat <<EOF > projeto/Projeto-Horizon/Dockerfile
FROM node:20

# Define o diretório de trabalho na raiz do projeto
WORKDIR /app

# Instala git e clona o repositório diretamente no Dockerfile
RUN apt-get update && apt-get install -y git && \
    git clone https://github.com/Horizon-SPTECH/Projeto-Horizon.git .

# Define o diretório correto para o projeto Node
WORKDIR /app/web-data-viz

# Instala as dependências
RUN npm install

# Exponha a porta necessária
EXPOSE 3333

# Comando de inicialização
CMD ["npm", "start"]
EOF

    # Constrói e executa o container Node
    cd projeto/Projeto-Horizon
    docker build -t my-node-app .
    docker run -d --name $NODE_CONTAINER --network $NETWORK_NAME -p 3333:3333 my-node-app
fi

# Criação e verificação do container Java
if container_exists $JAVA_CONTAINER; then
    echo "Container $JAVA_CONTAINER já existe. Iniciando..."
    docker start $JAVA_CONTAINER
else
    echo "Configurando container Java..."
    mkdir -p javaProjeto/Horizon-Java

    cat <<EOF > javaProjeto/Horizon-Java/Dockerfile
FROM openjdk:21-jdk-bullseye
SHELL ["/bin/bash", "-c"]
RUN if [ ! -d "/app" ]; then apt-get update && apt-get install -y git && git clone https://github.com/Horizon-SPTECH/Horizon-Java.git /app; fi
WORKDIR /app/target
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
ENV URL_SQL=$DB_URL
ENV USER=$DB_USERNAME
ENV SENHA=$DB_PASSWORD
ENV NAME_BUCKET=$NAME_BUCKET
EXPOSE 8080
CMD ["java", "-jar", "conexao-banco-de-dados-1.0-SNAPSHOT-jar-with-dependencies.jar"]
EOF

    cd javaProjeto/Horizon-Java
    docker build -t script-java .
    docker run -d --name $JAVA_CONTAINER --network $NETWORK_NAME -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -e URL_SQL=$DB_URL -e USER=$DB_USERNAME -e SENHA=$DB_PASSWORD script-java
fi

echo "Containers MySQL, Node e Java foram verificados e iniciados (ou criados, se necessário)."
