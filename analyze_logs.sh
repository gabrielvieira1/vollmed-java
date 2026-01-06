#!/bin/bash

echo "Resumo de Vulnerabilidades"
echo "=========================="

echo -e "
--- Snyk ---"
if [ -f "logs/snyk.log" ]; then
    if grep -q "Vulnerability found" "logs/snyk.log"; then
        grep -A 2 "Vulnerability found" "logs/snyk.log"
    else
        echo "Nenhuma vulnerabilidade encontrada pelo Snyk."
    fi
else
    echo "Log do Snyk não encontrado."
fi

echo -e "
--- Gitleaks ---"
if [ -f "logs/gitleaks.log" ]; then
    if grep -q "leaks found" "logs/gitleaks.log"; then
        grep -B 2 -A 5 "leaks found" "logs/gitleaks.log"
    else
        echo "Nenhum segredo vazado encontrado pelo Gitleaks."
    fi
else
    echo "Log do Gitleaks não encontrado."
fi

echo -e "
--- Semgrep ---"
if [ -f "logs/semgrep.log" ]; then
    if grep -q ""error_count": 0" "logs/semgrep.log"; then
        echo "Nenhuma vulnerabilidade encontrada pelo Semgrep."
    else
        echo "Vulnerabilidades encontradas pelo Semgrep. Verifique o arquivo logs/semgrep.log para mais detalhes."
    fi
else
    echo "Log do Semgrep não encontrado."
fi
