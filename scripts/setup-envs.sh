#!/bin/bash

# Setup script para configurar Snyk no projeto
echo "🔧 Setup das Envs Security Scanner"
echo "================================="
echo ""

# Verifica se .env existe
if [ -f .env ]; then
    echo "✅ Arquivo .env encontrado"
    if grep -q "SNYK_TOKEN" .env; then
        echo "✅ SNYK_TOKEN configurado em .env"
    else
        echo "⚠️  SNYK_TOKEN não encontrado em .env"
    fi
else
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo "✅ Arquivo .env criado (copie de .env.example)"
fi

echo ""
echo "📋 Próximos passos:"
echo "1. Acesse https://app.snyk.io/account"
echo "2. Copie seu API Token"
echo "3. Edite o arquivo .env e substitua 'your_snyk_token_here' pelo seu token"
echo ""
echo "🧪 Para testar a configuração, execute:"
echo "   docker run --rm -e SNYK_TOKEN=\"\$SNYK_TOKEN\" -v \$(pwd):/project -w /project snyk/snyk:node snyk --version"
echo ""
echo "🔒 O token será usado automaticamente pelos hooks do pre-commit"
