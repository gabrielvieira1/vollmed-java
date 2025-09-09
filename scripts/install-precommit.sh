#!/usr/bin/env bash
set -euo pipefail

echo "=== Instalador seguro do pre-commit via pipx ==="

# Detecta shell
CURRENT_SHELL=$(basename "$SHELL")
echo "-> Shell detectado: $CURRENT_SHELL"

# 1. Verifica se pipx está instalado
if ! command -v pipx &> /dev/null; then
  echo "-> pipx não encontrado. Instalando..."
  sudo apt update
  sudo apt install -y pipx
  pipx ensurepath
else
  echo "-> pipx já instalado."
fi

# 2. Garante que o PATH do pipx está ativo
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "-> Adicionando ~/.local/bin ao PATH"
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
  else
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  fi
fi

# 3. Instala ou atualiza o pre-commit
if pipx list | grep -q pre-commit; then
  echo "-> pre-commit já instalado. Atualizando..."
  pipx upgrade pre-commit
else
  echo "-> Instalando pre-commit..."
  pipx install pre-commit
fi

# 4. Verificação final
if command -v pre-commit &> /dev/null; then
  echo "✅ pre-commit instalado com sucesso!"
  pre-commit --version
else
  echo "❌ Algo deu errado: pre-commit não foi encontrado no PATH."
  echo "-> Sugestão: feche e reabra o terminal, ou rode manualmente:"
  echo "   export PATH=\$HOME/.local/bin:\$PATH"
fi
