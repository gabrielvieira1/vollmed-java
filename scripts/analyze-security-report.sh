#!/bin/bash

# Script para analisar relatórios do OWASP Dependency-Check
# Mostra um resumo das vulnerabilidades encontradas

echo "📊 Análise dos Relatórios de Segurança - OWASP Dependency-Check"
echo "================================================================"

# Verificar se o relatório JSON existe
if [ ! -f "reports/dependency-check-report.json" ]; then
    echo "❌ Relatório JSON não encontrado: reports/dependency-check-report.json"
    echo "Execute o dependency-check primeiro"
    exit 1
fi

echo "✅ Analisando: reports/dependency-check-report.json"
echo ""

# Estatísticas gerais
echo "📈 Estatísticas Gerais:"
echo "======================="
TOTAL_DEPS=$(jq '.dependencies | length' reports/dependency-check-report.json 2>/dev/null || echo "N/A")
TOTAL_VULNS=$(jq '[.dependencies[]? | select(.vulnerabilities?) | .vulnerabilities[]] | length' reports/dependency-check-report.json 2>/dev/null || echo "0")
DEPS_WITH_VULNS=$(jq '[.dependencies[]? | select(.vulnerabilities?)] | length' reports/dependency-check-report.json 2>/dev/null || echo "0")

echo "📦 Total de dependências analisadas: $TOTAL_DEPS"
echo "🚨 Total de vulnerabilidades encontradas: $TOTAL_VULNS"
echo "⚠️  Dependências com vulnerabilidades: $DEPS_WITH_VULNS"

if [ "$TOTAL_VULNS" != "0" ] && [ "$TOTAL_VULNS" != "N/A" ]; then
    echo ""
    echo "🔍 Resumo por Severidade:"
    echo "========================="

    # Contar por severidade
    jq -r '
    [.dependencies[]? | select(.vulnerabilities?) | .vulnerabilities[] | select(.severity?) | .severity]
    | sort
    | group_by(.)
    | map({severity: .[0], count: length})
    | .[]
    | "  \(.severity): \(.count) vulnerabilidade(s)"
    ' reports/dependency-check-report.json 2>/dev/null | while read -r line; do
        case $line in
            *"CRITICAL"*) echo "🚨 $line" ;;
            *"HIGH"*) echo "🟠 $line" ;;
            *"MEDIUM"*) echo "🟡 $line" ;;
            *"LOW"*) echo "🔵 $line" ;;
            *) echo "  $line" ;;
        esac
    done

    echo ""
    echo "🎯 Top 10 Vulnerabilidades Mais Críticas:"
    echo "=========================================="
    jq -r '
    [.dependencies[]? | select(.vulnerabilities?) | .vulnerabilities[] | select(.severity?) | {
        cve: .name // "N/A",
        severity: .severity,
        score: .cvssV3?.baseScore // .cvssV2?.score // 0,
        description: .description // "Sem descrição"
    }]
    | sort_by(.score) | reverse | .[0:10]
    | .[]
    | "  \(.cve) (\(.severity) - Score: \(.score))\n    \(.description[0:100])..."
    ' reports/dependency-check-report.json 2>/dev/null | head -20

    echo ""
    echo "📋 Dependências Mais Vulneráveis:"
    echo "=================================="
    jq -r '
    [.dependencies[]? | select(.vulnerabilities?) | {
        file: .fileName,
        vulns: (.vulnerabilities | length)
    }]
    | sort_by(.vulns) | reverse | .[0:5]
    | .[]
    | "  \(.file): \(.vulns) vulnerabilidade(s)"
    ' reports/dependency-check-report.json 2>/dev/null
fi

echo ""
echo "📄 Relatórios Disponíveis:"
echo "=========================="
ls -la reports/ | grep -E "\.(html|json|xml|csv)$" | awk '{print "  📄 " $9 " (" $5 " bytes)"}'

echo ""
echo "💡 Próximos Passos:"
echo "==================="
echo "  1. Abrir relatório HTML: xdg-open reports/dependency-check-report.html"
echo "  2. Revisar vulnerabilidades CRITICAL e HIGH"
echo "  3. Atualizar dependências vulneráveis"
echo "  4. Adicionar supressões para falsos positivos"
echo ""

if [ "$TOTAL_VULNS" != "0" ] && [ "$TOTAL_VULNS" != "N/A" ]; then
    echo "⚠️  Atenção: Foram encontradas $TOTAL_VULNS vulnerabilidades!"
    echo "Revise o relatório HTML para mais detalhes."
    exit 1
else
    echo "✅ Nenhuma vulnerabilidade encontrada! Projeto está seguro."
    exit 0
fi
