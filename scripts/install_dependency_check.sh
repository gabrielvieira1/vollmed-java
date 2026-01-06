#!/bin/bash

# --- TROUBLESHOOTING ---
# Se o script falhar, verifique se você tem 'wget' e 'unzip' instalados.
# Exemplo (Ubuntu/Debian): sudo apt-get install wget unzip
# Exemplo (Fedora): sudo dnf install wget unzip
# Exemplo (macOS Homebrew): brew install wget unzip

# URL para obter o número da versão mais recente
VERSION_URL="https://dependency-check.github.io/DependencyCheck/current.txt"

# Nome da pasta após a descompactação
DC_FOLDER="dependency-check"
DC_PATH="$HOME/$DC_FOLDER"
DC_DATA_PATH="$DC_PATH/data"

echo "### Script de Instalação e Atualização do Dependency-Check ###"
echo "----------------------------------------------------"

# 1. Obter a chave de API do NVD a partir do arquivo .env
API_KEY=""
if [ -f .env ]; then
    echo "Lendo a chave de API do arquivo .env..."
    API_KEY=$(grep -E '^DEPENDENCY_CHECK_API_KEY=' .env | sed -E 's/DEPENDENCY_CHECK_API_KEY=(.*)/\1/')
else
    echo "ERRO: O arquivo .env não foi encontrado. Por favor, crie um arquivo .env com sua chave de API."
    echo "Exemplo: DEPENDENCY_CHECK_API_KEY=sua-chave-aqui"
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo "ERRO: A variável DEPENDENCY_CHECK_API_KEY não foi encontrada ou está vazia no arquivo .env."
    exit 1
fi

echo "Chave de API do NVD lida com sucesso."
echo "----------------------------------------------------"

# 2. Verificar se o Dependency-Check já está instalado (agora mais robusto)
if [ -d "$DC_PATH" ]; then
    echo "O diretório '$DC_PATH' já foi encontrado. Pulando a instalação do binário."
else
    # 2.1. Obter a última versão e construir a URL de download
    echo "Buscando a última versão do Dependency-Check..."
    VERSION=$(curl -s $VERSION_URL)
    if [ -z "$VERSION" ]; then
        echo "ERRO: Falha ao obter o número da última versão. Verifique a URL ou sua conexão."
        exit 1
    fi
    DC_DOWNLOAD_URL="https://github.com/jeremylong/DependencyCheck/releases/download/v$VERSION/dependency-check-$VERSION-release.zip"

    # 2.2. Baixar o Dependency-Check
    echo "Baixando o Dependency-Check v$VERSION..."
    curl -Ls "$DC_DOWNLOAD_URL" --output dc_latest.zip
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao baixar o arquivo. Verifique sua conexão com a internet."
        exit 1
    fi
    echo "Download concluído."

    # 2.3. Descompactar o arquivo
    echo "Descompactando o arquivo..."
    unzip -q dc_latest.zip
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao descompactar o arquivo. Verifique se o arquivo não está corrompido."
        rm -f dc_latest.zip
        exit 1
    fi
    rm -f dc_latest.zip
    echo "Descompactação concluída."

    # 2.4. Corrigir a estrutura de diretórios (se necessário)
    if [ -d "$DC_PATH/$DC_FOLDER" ]; then
        echo "Corrigindo a estrutura de diretórios..."
        mv "$DC_PATH/$DC_FOLDER"/* "$DC_PATH/"
        rmdir "$DC_PATH/$DC_FOLDER"
    fi

    # 2.5. Configurar o Alias (Bash ou Zsh)
    echo "Configurando alias..."
    SHELL_RC=""
    if [[ "$SHELL" =~ "bash" ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ "$SHELL" =~ "zsh" ]]; then
        SHELL_RC="$HOME/.zshrc"
    fi

    if [ -n "$SHELL_RC" ]; then
        echo "alias dependency-check='$DC_PATH/bin/dependency-check.sh'" >> "$SHELL_RC"
        echo "Alias 'dependency-check' adicionado ao $SHELL_RC."
        echo "Por favor, execute 'source $SHELL_RC' ou reinicie seu terminal para aplicar as mudanças."
    else
        echo "AVISO: Shell não suportado. O alias não foi configurado automaticamente."
    fi
fi

# 3. Verificar e atualizar a base do NVD
echo "----------------------------------------------------"
if [ -d "$DC_DATA_PATH" ]; then
    echo "Diretório de dados '$DC_DATA_PATH' encontrado. Apenas atualizando a base do NVD."
    echo "Isso pode levar alguns minutos..."
    "$DC_PATH/bin/dependency-check.sh" --nvdApiKey "$API_KEY" --updateonly
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao atualizar a base do NVD. Verifique se a chave de API está correta ou se há problemas de conectividade."
    else
        echo "Sucesso! A base do NVD foi atualizada."
    fi
else
    echo "Diretório de dados não encontrado. Iniciando o primeiro download da base do NVD."
    echo "Isso pode levar bastante tempo (10-30 minutos, dependendo da sua conexão)..."
    "$DC_PATH/bin/dependency-check.sh" --nvdApiKey "$API_KEY" --updateonly
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao baixar a base do NVD. Verifique a chave de API e a conexão."
    else
        echo "Sucesso! A base do NVD foi baixada e o Dependency-Check está pronto para usar."
    fi
fi

echo "----------------------------------------------------"
echo "Operação concluída."
echo "Para executar o Dependency-Check, use o comando 'dependency-check' após reiniciar o terminal."
