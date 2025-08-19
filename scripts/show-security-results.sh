#!/bin/bash

# Script para mostrar resultados de segurança de forma limpa
# Uso: ./scripts/show-security-results.sh [all|snyk|gitleaks|semgrep]

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para mostrar header
show_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}🔒 RELATÓRIO DE SEGURANÇA${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Função para mostrar resultados do Snyk
show_snyk_results() {
    echo -e "${BLUE}🛡️  SNYK SECURITY SCAN${NC}"
    echo -e "${BLUE}─────────────────────────${NC}"

    if [[ -f "logs/snyk.log" ]]; then
        if command -v jq >/dev/null 2>&1; then
            JSON_CONTENT=$(sed -n '/{/,$p' logs/snyk.log 2>/dev/null)

            if [[ -n "$JSON_CONTENT" ]] && echo "$JSON_CONTENT" | jq -e '.vulnerabilities' >/dev/null 2>&1; then
                VULN_COUNT=$(echo "$JSON_CONTENT" | jq '.vulnerabilities | length' 2>/dev/null || echo "0")

                if [[ "$VULN_COUNT" -gt 0 ]]; then
                    echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                    echo ""
                    echo "$JSON_CONTENT" | jq -r '.vulnerabilities[] | "• \(.title) em \(.packageName)\n  - Versão vulnerável: \(.version)\n  - Severidade: \(.severity)\n  - ID: \(.id)\n"'
                else
                    echo -e "${GREEN}✅ Nenhuma vulnerabilidade detectada${NC}"
                fi
            else
                if grep -q "found [0-9]* issues\|vulnerabilities found" logs/snyk.log; then
                    echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                    echo ""
                    grep -E "found [0-9]* issues|vulnerabilities found" logs/snyk.log | sed 's/^/   /'
                else
                    echo -e "${GREEN}✅ Nenhuma vulnerabilidade crítica encontrada${NC}"
                fi
            fi
        else
            if grep -q "found [0-9]* issues\|vulnerabilities found" logs/snyk.log; then
                echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                echo ""
                grep -E "found [0-9]* issues|vulnerabilities found" logs/snyk.log | sed 's/^/   /'
            else
                echo -e "${GREEN}✅ Nenhuma vulnerabilidade crítica encontrada${NC}"
            fi
        fi

        echo ""
        echo -e "${YELLOW}💡 Para detalhes completos: cat logs/snyk.log${NC}"
    else
        echo -e "${YELLOW}⚠️  Log não encontrado: logs/snyk.log${NC}"
    fi
    echo ""
}

# Função para mostrar resultados do GitLeaks
show_gitleaks_results() {
    echo -e "${PURPLE}🕵️  GITLEAKS SECRETS SCANNER${NC}"
    echo -e "${PURPLE}──────────────────────────────${NC}"

    if [[ -f "logs/gitleaks.log" ]]; then
        if grep -q "leaks found:" logs/gitleaks.log; then
            echo -e "${RED}❌ SEGREDOS ENCONTRADOS:${NC}"
            echo ""
            awk '/File:/ {file=$2} /Secret:/ {secret=$2} /RuleID:/ {rule=$2; printf "• Credencial: %s\n  - Local: %s\n  - Regra: %s\n\n", secret, file, rule}' logs/gitleaks.log
            echo -e "${YELLOW}💡 Para detalhes completos: cat logs/gitleaks.log${NC}"
        else
            echo -e "${GREEN}✅ Nenhum segredo detectado${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Log não encontrado: logs/gitleaks.log${NC}"
    fi
    echo ""
}

# Função para mostrar resultados do Semgrep
show_semgrep_results() {
    echo -e "${CYAN}🔎 SEMGREP SAST SCANNER${NC}"
    echo -e "${CYAN}─────────────────────────${NC}"

    if [[ -f "logs/semgrep.log" ]]; then
        if grep -q '"results":\[{' logs/semgrep.log; then
            echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
            echo ""

            if command -v jq >/dev/null 2>&1; then
                JSON_PART=$(grep -A 10000 '^{' logs/semgrep.log | head -n 1)
                if [[ -n "$JSON_PART" ]]; then
                    echo "$JSON_PART" | jq -r '.results[] | "• \(.extra.message)\n  - Vulnerabilidade: \(.check_id)\n  - Severidade: \(.extra.severity)\n  - Arquivo: \(.path):\(.start.line)\n"'
                else
                    echo -e "   📊 Vulnerabilidades detectadas no scan"
                fi
            else
                echo -e "   📊 Vulnerabilidades detectadas (instale 'jq' para detalhes)"
            fi

            echo ""
            echo -e "${YELLOW}💡 Para detalhes completos: cat logs/semgrep.log${NC}"
        else
            echo -e "${GREEN}✅ Nenhuma vulnerabilidade crítica encontrada${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Log não encontrado: logs/semgrep.log${NC}"
    fi
    echo ""
}

# Função para mostrar todos os resultados
show_all_results() {
    show_header
    show_snyk_results
    show_gitleaks_results
    show_semgrep_results

    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}📁 LOGS COMPLETOS EM: ./logs/${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo "  all        Mostra todos os resultados (padrão)"
    echo "  snyk       Mostra apenas resultados do Snyk"
    echo "  gitleaks   Mostra apenas resultados do GitLeaks"
    echo "  semgrep    Mostra apenas resultados do Semgrep"
    echo "  help       Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                    # Mostra todos os resultados"
    echo "  $0 all               # Mostra todos os resultados"
    echo "  $0 snyk              # Mostra apenas Snyk"
}

# Main
case "${1:-all}" in
    "all")
        show_all_results
        ;;
    "snyk")
        show_header
        show_snyk_results
        ;;
    "gitleaks")
        show_header
        show_gitleaks_results
        ;;
    "semgrep")
        show_header
        show_semgrep_results
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Opção inválida: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac