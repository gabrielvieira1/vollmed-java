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
        JSON_CONTENT=$(sed -n '/^{/,$p' logs/snyk.log 2>/dev/null)

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
    else
        echo -e "${GREEN}🛡️  Snyk: ✅ OK${NC}"
    fi
else
    echo -e "${GREEN}🛡️  Snyk: ✅ OK${NC}"
fi

# OWASP Dependency Check
if [[ -f "reports/dependency-check-report.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
        # Analisa o relatório JSON do Dependency Check - conta todas as vulnerabilidades
        DEP_CHECK_ISSUES=$(jq '[.dependencies[]? | select(.vulnerabilities != null) | .vulnerabilities[]] | length' reports/dependency-check-report.json 2>/dev/null || echo "0")
        DEP_CHECK_CRITICAL=$(jq '[.dependencies[]? | select(.vulnerabilities != null) | .vulnerabilities[] | select(.severity == "CRITICAL")] | length' reports/dependency-check-report.json 2>/dev/null || echo "0")
        DEP_CHECK_HIGH=$(jq '[.dependencies[]? | select(.vulnerabilities != null) | .vulnerabilities[] | select(.severity == "HIGH")] | length' reports/dependency-check-report.json 2>/dev/null || echo "0")
        
        if [[ "$DEP_CHECK_ISSUES" =~ ^[0-9]+$ ]] && [[ "$DEP_CHECK_ISSUES" -gt 0 ]]; then
            if [[ "$DEP_CHECK_CRITICAL" -gt 0 ]] || [[ "$DEP_CHECK_HIGH" -gt 0 ]]; then
                echo -e "${RED}📦 Dependency Check: ${DEP_CHECK_ISSUES} vulnerabilidades (${DEP_CHECK_CRITICAL} críticas, ${DEP_CHECK_HIGH} altas)${NC}"
            else
                echo -e "${YELLOW}📦 Dependency Check: ${DEP_CHECK_ISSUES} vulnerabilidades (baixo/médio risco)${NC}"
            fi
            TOTAL_ISSUES=$((TOTAL_ISSUES + DEP_CHECK_ISSUES))
        else
            echo -e "${GREEN}📦 Dependency Check: ✅ OK${NC}"
        fi
    else
        # Sem jq, verifica se o arquivo não está vazio e contém vulnerabilidades
        if grep -q '"vulnerabilities"' reports/dependency-check-report.json 2>/dev/null; then
            echo -e "${YELLOW}📦 Dependency Check: ⚠️  Vulnerabilidades detectadas (instale jq para detalhes)${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        else
            echo -e "${GREEN}📦 Dependency Check: ✅ OK${NC}"
        fi
    fi
elif [[ -f "logs/dependency-check.log" ]]; then
    # Fallback para o log se o JSON não existir
    if grep -q "vulnerabilities found" logs/dependency-check.log 2>/dev/null; then
        DEP_CHECK_COUNT=$(grep -o "[0-9]* vulnerabilities found" logs/dependency-check.log | grep -o "^[0-9]*" || echo "0")
        if [[ "$DEP_CHECK_COUNT" =~ ^[0-9]+$ ]] && [[ "$DEP_CHECK_COUNT" -gt 0 ]]; then
            echo -e "${RED}📦 Dependency Check: ${DEP_CHECK_COUNT} vulnerabilidades encontradas${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + DEP_CHECK_COUNT))
        else
            echo -e "${GREEN}📦 Dependency Check: ✅ OK${NC}"
        fi
    else
        echo -e "${GREEN}📦 Dependency Check: ✅ OK${NC}"
    fi
else
    echo -e "${YELLOW}📦 Dependency Check: ⚠️  Relatório não encontrado${NC}"
fi

# GitLeaks
if [[ -f "logs/gitleaks.log" ]] && grep -q "leaks found:" logs/gitleaks.log; then
    GITLEAKS_ISSUES=$(grep -o "leaks found: [0-9]*" logs/gitleaks.log | grep -o "[0-9]*")
    echo -e "${RED}🕵️  GitLeaks: ${GITLEAKS_ISSUES} segredos detectados${NC}"
    TOTAL_ISSUES=$((TOTAL_ISSUES + GITLEAKS_ISSUES))
else
    echo -e "${GREEN}🕵️  GitLeaks: ✅ OK${NC}"
fi

# Semgrep
if [[ -f "logs/semgrep.log" ]]; then
    # Verifica se há findings no JSON (procura por "results":[{)
    if grep -q '"results":\[{' logs/semgrep.log; then
        if command -v jq >/dev/null 2>&1; then
            # Extrai apenas o JSON da saída (procura pela linha que começa com {)
            JSON_PART=$(grep -A 10000 '^{' logs/semgrep.log | head -n 1)
            if [[ -n "$JSON_PART" ]]; then
                SEMGREP_ISSUES=$(echo "$JSON_PART" | jq '.results | length' 2>/dev/null || echo "0")
                if [[ "$SEMGREP_ISSUES" =~ ^[0-9]+$ ]] && [[ "$SEMGREP_ISSUES" -gt 0 ]]; then
                    echo -e "${RED}🔎 Semgrep: ${SEMGREP_ISSUES} vulnerabilidades SAST${NC}"
                    TOTAL_ISSUES=$((TOTAL_ISSUES + SEMGREP_ISSUES))
                else
                    echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
                fi
            else
                echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
            fi
        else
            # Sem jq, verifica se há resultados básicos
            echo -e "${YELLOW}🔎 Semgrep: ⚠️  Vulnerabilidades detectadas${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    else
        echo -e "${GREEN}🔎 Semgrep: ✅ OK${NC}"
    fi
else
    echo -e "${YELLOW}🔎 Semgrep: ⚠️  Log não encontrado${NC}"
fi

# Bandit
if [[ -f "logs/bandit.log" ]]; then
    if command -v jq >/dev/null 2>&1 && grep -q '"results": \[' logs/bandit.log; then
        # Extrai apenas a parte JSON (a partir da linha que contém {)
        LINE_NUM=$(grep -n '^{' logs/bandit.log | cut -d: -f1)
        if [[ -n "$LINE_NUM" ]]; then
            BANDIT_ISSUES=$(tail -n +$LINE_NUM logs/bandit.log | jq '.results | length' 2>/dev/null || echo "0")
            if [[ "$BANDIT_ISSUES" =~ ^[0-9]+$ ]] && [[ "$BANDIT_ISSUES" -gt 0 ]]; then
                echo -e "${RED}🐍 Bandit: ${BANDIT_ISSUES} vulnerabilidades Python${NC}"
                TOTAL_ISSUES=$((TOTAL_ISSUES + BANDIT_ISSUES))
            else
                echo -e "${GREEN}🐍 Bandit: ✅ OK${NC}"
            fi
        else
            echo -e "${YELLOW}🐍 Bandit: ⚠️  Vulnerabilidades detectadas${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    else
        if grep -q '"results":' logs/bandit.log; then
            echo -e "${YELLOW}🐍 Bandit: ⚠️  Vulnerabilidades detectadas${NC}"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        else
            echo -e "${GREEN}🐍 Bandit: ✅ OK${NC}"
        fi
    fi
else
    echo -e "${YELLOW}🐍 Bandit: ⚠️  Log não encontrado${NC}"
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
echo -e "   ./scripts/show-security-results.sh [gitleaks|semgrep|dependency-check]"
echo ""
