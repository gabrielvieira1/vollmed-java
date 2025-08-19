#!/bin/bash

# Script para mostrar resumo executivo de segurança
# Uso: ./scripts/security-summary.sh

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔒 RESUMO EXECUTIVO DE SEGURANÇA${NC}"
echo -e "${CYAN}=================================${NC}"
echo ""

# Contador de problemas
TOTAL_ISSUES=0

# Snyk
if [[ -f "logs/snyk.log" ]]; then
    if command -v jq >/dev/null 2>&1; then
        # Extrai JSON do log do Snyk via Docker
        JSON_CONTENT=$(sed -n '/{/,$p' logs/snyk.log 2>/dev/null)

        if [[ -n "$JSON_CONTENT" ]] && echo "$JSON_CONTENT" | jq -e '.vulnerabilities' >/dev/null 2>&1; then
            SNYK_ISSUES=$(echo "$JSON_CONTENT" | jq '.vulnerabilities | length' 2>/dev/null || echo "0")
        else
            # Fallback para formato texto
            SNYK_ISSUES=$(grep -o "found [0-9]* issues" logs/snyk.log 2>/dev/null | grep -o "[0-9]*" || echo "0")
        fi
    else
        SNYK_ISSUES=$(grep -o "found [0-9]* issues" logs/snyk.log 2>/dev/null | grep -o "[0-9]*" || echo "0")
    fi

    if [[ "$SNYK_ISSUES" =~ ^[0-9]+$ ]] && [[ "$SNYK_ISSUES" -gt 0 ]]; then
        echo -e "${RED}🛡️  Snyk: ${SNYK_ISSUES} vulnerabilidades de dependências${NC}"
        TOTAL_ISSUES=$((TOTAL_ISSUES + SNYK_ISSUES))
        if [[ -n "$JSON_CONTENT" ]] && command -v jq >/dev/null 2>&1; then
            echo -e "${YELLOW}   Dependências vulneráveis:${NC}"
            echo "$JSON_CONTENT" | jq -r '.vulnerabilities[] | "   - " + .packageName + "@" + .version + " (" + .severity + ")"'
        fi
    else
        echo -e "${GREEN}🛡️  Snyk: ✅ OK${NC}"
    fi
else
    echo -e "${GREEN}🛡️  Snyk: ✅ OK${NC}"
fi
echo ""

# GitLeaks
if [[ -f "logs/gitleaks.log" ]] && grep -q "leaks found:" logs/gitleaks.log; then
    GITLEAKS_ISSUES=$(grep -o "leaks found: [0-9]*" logs/gitleaks.log | grep -o "[0-9]*")
    echo -e "${RED}🕵️  GitLeaks: ${GITLEAKS_ISSUES} segredos detectados${NC}"
    TOTAL_ISSUES=$((TOTAL_ISSUES + GITLEAKS_ISSUES))
    echo -e "${YELLOW}   Credenciais encontradas:${NC}"
    # Robust awk script that processes leaks in blocks (records) separated by blank lines.
    awk 'BEGIN {RS="" ; FS="\n" } { file="[não especificado]"; secret=""; rule=""; for (i=1; i<=NF; i++) { if (match($i, /File:[ \t]+(.+)/, m)) { file=m[1] } if (match($i, /Secret:[ \t]+(.+)/, m)) { secret=m[1] } if (match($i, /RuleID:[ \t]+(.+)/, m)) { rule=m[1] } } if (rule != "" && secret != "") { printf "   - No arquivo %s foi encontrada a credencial %s (Regra: %s)\n", file, secret, rule } }' logs/gitleaks.log
else
    echo -e "${GREEN}🕵️  GitLeaks: ✅ OK${NC}"
fi
echo ""

# Semgrep
if [[ -f "logs/semgrep.log" ]]; then
    # Find the line containing the JSON results, which starts with {"version":
    JSON_PART=$(grep '^{"version":' logs/semgrep.log)

    # Check if we found the JSON part
    if [[ -n "$JSON_PART" ]]; then
        if command -v jq >/dev/null 2>&1; then
            SEMGREP_ISSUES=$(echo "$JSON_PART" | jq '.results | length' 2>/dev/null || echo "0")
            if [[ "$SEMGREP_ISSUES" =~ ^[0-9]+$ ]] && [[ "$SEMGREP_ISSUES" -gt 0 ]]; then
                echo -e "${RED}🔎 Semgrep: ${SEMGREP_ISSUES} vulnerabilidades SAST${NC}"
                TOTAL_ISSUES=$((TOTAL_ISSUES + SEMGREP_ISSUES))
                echo -e "${YELLOW}   Vulnerabilidades no código:${NC}"
                # JQ query with improved formatting to include location and line number.
                echo "$JSON_PART" | jq -r '.results[] | "   - Vulnerabilidade: " + .extra.message + "\n     Severidade: " + .extra.severity + "\n     Local: " + .path + ":" + (.start.line|tostring) + "\n     Tipo: " + .check_id + "\n"'
            else
                echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
            fi
        else
            # Fallback for no jq
            echo -e "${YELLOW}🔎 Semgrep: ⚠️  Vulnerabilidades detectadas (instale jq para detalhes)${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    else
        # No JSON line found, but the log exists. Check for textual summary.
        if grep -q "Ran .* rules on .* files: .* findings" logs/semgrep.log; then
             FINDING_COUNT=$(grep "Ran .* rules on .* files: .* findings" logs/semgrep.log | sed 's/.*: \([0-9]*\) findings\./\1/')
             if [[ "$FINDING_COUNT" -gt 0 ]]; then
                echo -e "${RED}🔎 Semgrep: ${FINDING_COUNT} vulnerabilidades SAST (análise de texto)${NC}"
                TOTAL_ISSUES=$((TOTAL_ISSUES + FINDING_COUNT))
             else
                echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
             fi
        else
            echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
        fi
    fi
else
    echo -e "${YELLOW}🔎 Semgrep: ⚠️  Log não encontrado${NC}"
fi
echo ""

echo -e "${CYAN}=================================${NC}"

if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ STATUS: SEGURO - Nenhuma vulnerabilidade detectada${NC}"
else
    echo -e "${RED}❌ STATUS: ATENÇÃO - ${TOTAL_ISSUES}+ problemas de segurança encontrados${NC}"
fi

echo -e "${CYAN}=================================${NC}"
echo ""

echo -e "${BLUE}💡 Para detalhes completos:${NC}"
echo -e "   ./scripts/show-security-results.sh"
echo -e "   ./scripts/show-security-results.sh [snyk|gitleaks|semgrep]"
echo ""
