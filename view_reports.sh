#!/bin/bash

# Script para visualizar relatórios HTML gerados pela simulação
# Este script facilita a abertura de todos os relatórios HTML em um navegador

set -e

# Cores para saída
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem Cor

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORTS_DIR="${SCRIPT_DIR}/reports"

# Função para exibir uso
usage() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Visualizador de Relatórios HTML do OpenShift Health Check"
    echo ""
    echo "Opções:"
    echo "  -l, --list              Listar execuções disponíveis"
    echo "  -e, --execution ID      Especificar ID da execução"
    echo "  -a, --all               Abrir todos os relatórios"
    echo "  -c, --consolidated      Abrir apenas relatório consolidado"
    echo "  -h, --help              Mostrar esta mensagem de ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -l                   # Listar execuções disponíveis"
    echo "  $0 -e demo-cluster_20250923_155944  # Abrir relatórios de execução específica"
    echo "  $0 -a                   # Abrir todos os relatórios da execução mais recente"
    echo "  $0 -c                   # Abrir apenas relatório consolidado da execução mais recente"
}

# Função para listar execuções disponíveis
list_executions() {
    echo -e "${BLUE}Execuções disponíveis:${NC}"
    if [ -d "$REPORTS_DIR" ]; then
        find "$REPORTS_DIR" -maxdepth 1 -type d -name "*_*" | sort -r | while read -r dir; do
            execution_id=$(basename "$dir")
            echo "  - $execution_id"
        done
    else
        echo "  Nenhuma execução encontrada."
    fi
}

# Função para obter a execução mais recente
get_latest_execution() {
    if [ -d "$REPORTS_DIR" ]; then
        find "$REPORTS_DIR" -maxdepth 1 -type d -name "*_*" | sort -r | head -1 | xargs basename
    else
        echo ""
    fi
}

# Função para abrir relatório no navegador
open_report() {
    local report_path="$1"
    local report_name="$2"
    
    if [ -f "$report_path" ]; then
        echo -e "${GREEN}✓${NC} Abrindo: $report_name"
        xdg-open "$report_path" 2>/dev/null || {
            echo -e "${YELLOW}⚠${NC} Não foi possível abrir automaticamente. Acesse:"
            echo "   file://$report_path"
        }
    else
        echo -e "${YELLOW}⚠${NC} Relatório não encontrado: $report_name"
    fi
}

# Função para abrir todos os relatórios de uma execução
open_all_reports() {
    local execution_id="$1"
    local execution_dir="$REPORTS_DIR/$execution_id"
    
    if [ ! -d "$execution_dir" ]; then
        echo -e "${YELLOW}⚠${NC} Execução não encontrada: $execution_id"
        return 1
    fi
    
    echo -e "${BLUE}Abrindo relatórios da execução: $execution_id${NC}"
    echo ""
    
    # Relatório consolidado
    open_report "$execution_dir/html/consolidated/consolidated_health_check_report.html" "Relatório Consolidado"
    sleep 2
    
    # Relatórios individuais
    open_report "$execution_dir/html/data_collection/data_collection_report.html" "Relatório de Coleta de Dados"
    sleep 1
    
    open_report "$execution_dir/html/architecture_analysis/architecture_analysis_report.html" "Relatório de Arquitetura"
    sleep 1
    
    open_report "$execution_dir/html/security_analysis/security_analysis_report.html" "Relatório de Segurança"
    sleep 1
    
    open_report "$execution_dir/html/best_practices_analysis/best_practices_analysis_report.html" "Relatório de Boas Práticas"
    sleep 1
    
    open_report "$execution_dir/html/resource_optimization/resource_optimization_report.html" "Relatório de Otimização de Recursos"
    
    echo ""
    echo -e "${GREEN}✅ Todos os relatórios foram abertos!${NC}"
}

# Função para abrir apenas relatório consolidado
open_consolidated_report() {
    local execution_id="$1"
    local execution_dir="$REPORTS_DIR/$execution_id"
    
    if [ ! -d "$execution_dir" ]; then
        echo -e "${YELLOW}⚠${NC} Execução não encontrada: $execution_id"
        return 1
    fi
    
    echo -e "${BLUE}Abrindo relatório consolidado da execução: $execution_id${NC}"
    open_report "$execution_dir/html/consolidated/consolidated_health_check_report.html" "Relatório Consolidado"
}

# Função para exibir informações da execução
show_execution_info() {
    local execution_id="$1"
    local execution_dir="$REPORTS_DIR/$execution_id"
    
    if [ ! -d "$execution_dir" ]; then
        echo -e "${YELLOW}⚠${NC} Execução não encontrada: $execution_id"
        return 1
    fi
    
    echo -e "${BLUE}Informações da execução: $execution_id${NC}"
    echo ""
    
    # Verificar arquivos JSON para extrair informações
    if [ -f "$execution_dir/data_collection/cluster_info.json" ]; then
        echo -e "${GREEN}📊 Dados do Cluster:${NC}"
        cat "$execution_dir/data_collection/cluster_info.json" | grep -E '"name"|"version"|"platform"' | sed 's/^/   /'
        echo ""
    fi
    
    # Listar relatórios disponíveis
    echo -e "${GREEN}📋 Relatórios disponíveis:${NC}"
    find "$execution_dir/html" -name "*.html" | while read -r file; do
        rel_path=$(echo "$file" | sed "s|$execution_dir/||")
        echo "   - $rel_path"
    done
    echo ""
}

# Parse command line arguments
EXECUTION_ID=""
LIST_ONLY=false
OPEN_ALL=false
OPEN_CONSOLIDATED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        -e|--execution)
            EXECUTION_ID="$2"
            shift 2
            ;;
        -a|--all)
            OPEN_ALL=true
            shift
            ;;
        -c|--consolidated)
            OPEN_CONSOLIDATED=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${YELLOW}⚠${NC} Opção desconhecida: $1"
            usage
            exit 1
            ;;
    esac
done

# Executar ações baseadas nos parâmetros
if [ "$LIST_ONLY" = true ]; then
    list_executions
    exit 0
fi

# Se nenhuma execução foi especificada, usar a mais recente
if [ -z "$EXECUTION_ID" ]; then
    EXECUTION_ID=$(get_latest_execution)
    if [ -z "$EXECUTION_ID" ]; then
        echo -e "${YELLOW}⚠${NC} Nenhuma execução encontrada. Execute primeiro a simulação."
        echo "   Use: python3 simulate_execution.py"
        exit 1
    fi
    echo -e "${BLUE}Usando execução mais recente: $EXECUTION_ID${NC}"
fi

# Mostrar informações da execução
show_execution_info "$EXECUTION_ID"

# Executar ação solicitada
if [ "$OPEN_ALL" = true ]; then
    open_all_reports "$EXECUTION_ID"
elif [ "$OPEN_CONSOLIDATED" = true ]; then
    open_consolidated_report "$EXECUTION_ID"
else
    # Por padrão, abrir apenas o relatório consolidado
    open_consolidated_report "$EXECUTION_ID"
fi
