#!/bin/bash

# Script para mostrar resultados de segurança de forma limpa
# Uso: ./scripts/show-security-results.sh [all|snyk|gitleaks|semgrep|bandit]

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
        # Tenta extrair JSON se existir, caso contrário usa texto
        if command -v jq >/dev/null 2>&1; then
            # Extrai JSON do log (pode ter texto misturado no início)
            JSON_CONTENT=$(sed -n '/^{/,$p' logs/snyk.log 2>/dev/null)

            if [[ -n "$JSON_CONTENT" ]] && echo "$JSON_CONTENT" | jq -e '.vulnerabilities' >/dev/null 2>&1; then
                # Formato JSON do Snyk via Docker
                VULN_COUNT=$(echo "$JSON_CONTENT" | jq '.vulnerabilities | length' 2>/dev/null || echo "0")

                if [[ "$VULN_COUNT" -gt 0 ]]; then
                    echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                    echo ""
                    echo -e "   📊 ${VULN_COUNT} vulnerabilidades detectadas"

                    # Conta por severidade
                    HIGH_COUNT=$(echo "$JSON_CONTENT" | jq '[.vulnerabilities[] | select(.severity=="high")] | length' 2>/dev/null || echo "0")
                    MEDIUM_COUNT=$(echo "$JSON_CONTENT" | jq '[.vulnerabilities[] | select(.severity=="medium")] | length' 2>/dev/null || echo "0")
                    CRITICAL_COUNT=$(echo "$JSON_CONTENT" | jq '[.vulnerabilities[] | select(.severity=="critical")] | length' 2>/dev/null || echo "0")

                    if [[ "$CRITICAL_COUNT" -gt 0 ]]; then
                        echo -e "   💀 ${CRITICAL_COUNT} vulnerabilidades CRITICAL"
                    fi
                    if [[ "$HIGH_COUNT" -gt 0 ]]; then
                        echo -e "   🔥 ${HIGH_COUNT} vulnerabilidades HIGH"
                    fi
                    if [[ "$MEDIUM_COUNT" -gt 0 ]]; then
                        echo -e "   ⚠️  ${MEDIUM_COUNT} vulnerabilidades MEDIUM"
                    fi

                    echo ""
                    echo -e "   🔍 Top vulnerabilidades:"
                    echo "$JSON_CONTENT" | jq -r '.vulnerabilities[:3][] | "   • \(.title) (\(.severity))"' 2>/dev/null || true
                else
                    echo -e "${GREEN}✅ Nenhuma vulnerabilidade detectada${NC}"
                fi
            else
                # Fallback para formato texto
                if grep -q "found [0-9]* issues\|vulnerabilities found" logs/snyk.log; then
                    echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                    echo ""
                    grep -E "found [0-9]* issues|vulnerabilities found" logs/snyk.log | sed 's/^/   /' | head -5
                else
                    echo -e "${GREEN}✅ Nenhuma vulnerabilidade crítica encontrada${NC}"
                fi
            fi
        else
            # Sem jq, usa análise de texto simples
            if grep -q "found [0-9]* issues\|vulnerabilities found" logs/snyk.log; then
                echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
                echo ""
                grep -E "found [0-9]* issues|vulnerabilities found" logs/snyk.log | sed 's/^/   /' | head -5
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

            # Extrai o número total de segredos
            LEAK_COUNT=$(grep "leaks found:" logs/gitleaks.log | grep -o "[0-9]*" | head -1)
            echo -e "   📊 ${LEAK_COUNT} segredos detectados"

            # Mostra tipos de segredos encontrados (por RuleID)
            if grep -q "RuleID:" logs/gitleaks.log; then
                echo ""
                echo -e "   🔍 Tipos de segredos encontrados:"
                grep "RuleID:" logs/gitleaks.log | awk '{print $2}' | sort | uniq -c | head -5 | while read count rule; do
                    case $rule in
                        "generic-api-key"|"api-key")
                            echo -e "   🔑 API Keys: ${count} ocorrência(s)"
                            ;;
                        "aws-access-token"|"aws-secret-key")
                            echo -e "   ☁️  AWS Tokens: ${count} ocorrência(s)"
                            ;;
                        "github-pat"|"github-token")
                            echo -e "   🐙 GitHub Tokens: ${count} ocorrência(s)"
                            ;;
                        "password"|"generic-password")
                            echo -e "   🔐 Senhas: ${count} ocorrência(s)"
                            ;;
                        "private-key"|"rsa-private-key")
                            echo -e "   🗝️  Chaves Privadas: ${count} ocorrência(s)"
                            ;;
                        *)
                            echo -e "   🔍 ${rule}: ${count} ocorrência(s)"
                            ;;
                    esac
                done
            fi

            # Mostra alguns exemplos de arquivos afetados
            if grep -q "File:" logs/gitleaks.log; then
                echo ""
                echo -e "   📁 Arquivos afetados:"
                grep "File:" logs/gitleaks.log | awk '{print $2}' | sort | uniq | head -3 | while read file; do
                    echo -e "   • ${file}"
                done

                TOTAL_FILES=$(grep "File:" logs/gitleaks.log | awk '{print $2}' | sort | uniq | wc -l)
                if [[ "$TOTAL_FILES" -gt 3 ]]; then
                    echo -e "   • ... e mais $((TOTAL_FILES - 3)) arquivo(s)"
                fi
            fi

            echo ""
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
        # Verifica se há vulnerabilidades no JSON (procura por "results":[{)
        if grep -q '"results":\[{' logs/semgrep.log; then
            echo -e "${RED}❌ VULNERABILIDADES ENCONTRADAS:${NC}"
            echo ""

            # Tenta extrair número de findings se disponível
            if command -v jq >/dev/null 2>&1; then
                # Extrai apenas o JSON da saída (procura pela linha que começa com {)
                JSON_PART=$(grep -A 10000 '^{' logs/semgrep.log | head -n 1)
                if [[ -n "$JSON_PART" ]]; then
                    FINDINGS=$(echo "$JSON_PART" | jq '.results | length' 2>/dev/null || echo "N/A")
                    ERROR_COUNT=$(echo "$JSON_PART" | jq '[.results[] | select(.extra.severity == "ERROR")] | length' 2>/dev/null || echo "0")
                    WARNING_COUNT=$(echo "$JSON_PART" | jq '[.results[] | select(.extra.severity == "WARNING")] | length' 2>/dev/null || echo "0")

                    echo -e "   📊 ${FINDINGS} vulnerabilidades detectadas"
                    echo -e "   🔴 Erros:      ${ERROR_COUNT}"
                    echo -e "   🟡 Avisos:     ${WARNING_COUNT}"

                    # Mostra tipos de vulnerabilidades encontradas
                    echo ""
                    echo -e "   🔍 Tipos de vulnerabilidades:"
                    echo "$JSON_PART" | jq -r '.results[] | .extra.metadata.category // .check_id' 2>/dev/null | sort | uniq -c | head -5 | while read count category; do
                        case $category in
                            *"sql-injection"*|*"sqli"*)
                                echo -e "   💉 SQL Injection: ${count} ocorrência(s)"
                                ;;
                            *"xss"*|*"cross-site"*)
                                echo -e "   🌐 XSS: ${count} ocorrência(s)"
                                ;;
                            *"command-injection"*|*"shell"*)
                                echo -e "   ⚡ Command Injection: ${count} ocorrência(s)"
                                ;;
                            *"path-traversal"*|*"directory"*)
                                echo -e "   📁 Path Traversal: ${count} ocorrência(s)"
                                ;;
                            *"crypto"*|*"hash"*)
                                echo -e "   🔐 Criptografia: ${count} ocorrência(s)"
                                ;;
                            *)
                                # Remove prefixos longos para exibição limpa
                                CLEAN_CAT=$(echo "$category" | sed 's/^.*\.\([^.]*\)$/\1/' | sed 's/-/ /g' | tr '[:lower:]' '[:upper:]')
                                echo -e "   🔍 ${CLEAN_CAT}: ${count} ocorrência(s)"
                                ;;
                        esac
                    done

                    # Mostra arquivos mais afetados
                    echo ""
                    echo -e "   📁 Arquivos mais afetados:"
                    echo "$JSON_PART" | jq -r '.results[].path' 2>/dev/null | sort | uniq -c | sort -nr | head -3 | while read count file; do
                        BASENAME=$(basename "$file")
                        echo -e "   • ${BASENAME}: ${count} problema(s)"
                    done
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

# Função para mostrar resultados do Bandit
show_bandit_results() {
    echo -e "${YELLOW}🐍 BANDIT PYTHON SCANNER${NC}"
    echo -e "${YELLOW}──────────────────────────${NC}"

    if [[ -f "logs/bandit.log" ]]; then
        # Extrai métricas do JSON se disponível
        if command -v jq >/dev/null 2>&1 && grep -q '"results": \[' logs/bandit.log; then
            # Extrai apenas a parte JSON (a partir da linha que contém {)
            LINE_NUM=$(grep -n '^{' logs/bandit.log | cut -d: -f1)
            if [[ -n "$LINE_NUM" ]]; then
                HIGH=$(tail -n +$LINE_NUM logs/bandit.log | jq '.metrics._totals["SEVERITY.HIGH"]' 2>/dev/null || echo "0")
                MEDIUM=$(tail -n +$LINE_NUM logs/bandit.log | jq '.metrics._totals["SEVERITY.MEDIUM"]' 2>/dev/null || echo "0")
                LOW=$(tail -n +$LINE_NUM logs/bandit.log | jq '.metrics._totals["SEVERITY.LOW"]' 2>/dev/null || echo "0")
                TOTAL_RESULTS=$(tail -n +$LINE_NUM logs/bandit.log | jq '.results | length' 2>/dev/null || echo "0")

                if [[ "$TOTAL_RESULTS" -gt 0 ]]; then
                    echo -e "${RED}❌ VULNERABILIDADES PYTHON ENCONTRADAS:${NC}"
                    echo ""
                    echo -e "   📊 ${TOTAL_RESULTS} vulnerabilidades detectadas"
                    echo -e "   🔥 Alta:       ${HIGH}"
                    echo -e "   ⚠️  Média:      ${MEDIUM}"
                    echo -e "   ℹ️  Baixa:      ${LOW}"

                    # Mostra tipos de vulnerabilidades por test_id
                    echo ""
                    echo -e "   🔍 Tipos de vulnerabilidades:"
                    tail -n +$LINE_NUM logs/bandit.log | jq -r '.results[].test_id' 2>/dev/null | sort | uniq -c | head -5 | while read count test_id; do
                        case $test_id in
                            "B101")
                                echo -e "   🧪 Assert statements: ${count} ocorrência(s)"
                                ;;
                            "B102"|"B103")
                                echo -e "   🔐 Exec/Eval usage: ${count} ocorrência(s)"
                                ;;
                            "B104"|"B105"|"B106")
                                echo -e "   💉 Hardcoded passwords: ${count} ocorrência(s)"
                                ;;
                            "B201"|"B202")
                                echo -e "   📁 Path traversal: ${count} ocorrência(s)"
                                ;;
                            "B301"|"B302"|"B303")
                                echo -e "   🌐 Unsafe URL/requests: ${count} ocorrência(s)"
                                ;;
                            "B501"|"B502"|"B503")
                                echo -e "   🔒 SSL/TLS issues: ${count} ocorrência(s)"
                                ;;
                            "B601"|"B602"|"B603")
                                echo -e "   ⚡ Shell injection: ${count} ocorrência(s)"
                                ;;
                            "B701"|"B702")
                                echo -e "   🧬 Deserialization: ${count} ocorrência(s)"
                                ;;
                            *)
                                echo -e "   🔍 ${test_id}: ${count} ocorrência(s)"
                                ;;
                        esac
                    done

                    # Mostra arquivos mais problemáticos
                    echo ""
                    echo -e "   📁 Arquivos mais problemáticos:"
                    tail -n +$LINE_NUM logs/bandit.log | jq -r '.results[].filename' 2>/dev/null | sort | uniq -c | sort -nr | head -3 | while read count file; do
                        BASENAME=$(basename "$file")
                        echo -e "   • ${BASENAME}: ${count} problema(s)"
                    done

                    echo ""
                    echo -e "${YELLOW}💡 Para detalhes completos: cat logs/bandit.log${NC}"
                else
                    echo -e "${GREEN}✅ Código Python sem vulnerabilidades críticas${NC}"
                fi
            else
                echo -e "${RED}❌ VULNERABILIDADES PYTHON ENCONTRADAS${NC}"
                echo -e "${YELLOW}💡 Para detalhes: cat logs/bandit.log${NC}"
            fi
        else
            # Fallback se jq não estiver disponível
            if grep -q '"results":' logs/bandit.log; then
                echo -e "${RED}❌ VULNERABILIDADES PYTHON ENCONTRADAS${NC}"
                echo -e "${YELLOW}💡 Para detalhes: cat logs/bandit.log${NC}"
            else
                echo -e "${GREEN}✅ Código Python sem vulnerabilidades críticas${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Log não encontrado: logs/bandit.log${NC}"
    fi
    echo ""
}

# Função para mostrar todos os resultados
show_all_results() {
    show_header
    show_snyk_results
    show_gitleaks_results
    show_semgrep_results
    show_bandit_results

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
    echo "  bandit     Mostra apenas resultados do Bandit"
    echo "  help       Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                    # Mostra todos os resultados"
    echo "  $0 all               # Mostra todos os resultados"
    echo "  $0 snyk              # Mostra apenas Snyk"
    echo "  $0 bandit            # Mostra apenas Bandit"
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
    "bandit")
        show_header
        show_bandit_results
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
