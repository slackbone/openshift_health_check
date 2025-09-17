#!/bin/bash

# Script para executar health check em múltiplos clusters
# Este script demonstra como usar a nova estrutura de relatórios organizados

set -e

# Configurações
ANSIBLE_PLAYBOOK="playbooks/openshift_health_check.yml"
INVENTORY="inventory/hosts.yml"
REPORTS_DIR="reports"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir ajuda
show_help() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "OPÇÕES:"
    echo "  -h, --help              Exibir esta ajuda"
    echo "  -c, --cluster CLUSTER   Executar apenas no cluster especificado"
    echo "  -l, --list              Listar clusters disponíveis"
    echo "  -d, --dry-run           Executar em modo dry-run"
    echo "  -v, --verbose           Executar em modo verbose"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0                                    # Executar em todos os clusters"
    echo "  $0 -c production-cluster             # Executar apenas no cluster de produção"
    echo "  $0 -c staging-cluster -v             # Executar no staging com verbose"
    echo "  $0 -d                                # Dry-run em todos os clusters"
    echo ""
    echo "CONFIGURAÇÃO:"
    echo "  Configure os clusters no arquivo: inventory/hosts.yml"
    echo "  Configure as credenciais no arquivo: group_vars/all.yml"
}

# Função para listar clusters disponíveis
list_clusters() {
    echo -e "${BLUE}Clusters disponíveis:${NC}"
    if [ -f "$INVENTORY" ]; then
        ansible-inventory -i "$INVENTORY" --list | jq -r 'keys[]' | grep -v "_meta" | sort
    else
        echo -e "${RED}Arquivo de inventário não encontrado: $INVENTORY${NC}"
        exit 1
    fi
}

# Função para executar health check em um cluster
run_health_check() {
    local cluster_name="$1"
    local dry_run="$2"
    local verbose="$3"
    
    echo -e "${BLUE}Executando health check no cluster: $cluster_name${NC}"
    
    # Construir comando ansible-playbook
    local cmd="ansible-playbook -i $INVENTORY $ANSIBLE_PLAYBOOK"
    cmd="$cmd -e cluster_name=$cluster_name"
    
    if [ "$dry_run" = "true" ]; then
        cmd="$cmd --check --diff"
        echo -e "${YELLOW}Modo dry-run ativado${NC}"
    fi
    
    if [ "$verbose" = "true" ]; then
        cmd="$cmd -vvv"
        echo -e "${YELLOW}Modo verbose ativado${NC}"
    fi
    
    # Executar comando
    echo -e "${GREEN}Executando: $cmd${NC}"
    if eval "$cmd"; then
        echo -e "${GREEN}✓ Health check concluído com sucesso para $cluster_name${NC}"
        
        # Exibir localização dos relatórios
        local latest_report=$(ls -t "$REPORTS_DIR"/${cluster_name}_* 2>/dev/null | head -1)
        if [ -n "$latest_report" ]; then
            echo -e "${BLUE}Relatórios gerados em: $latest_report${NC}"
            echo -e "${BLUE}Relatório executivo: $latest_report/html/consolidated/consolidated_health_check_report.html${NC}"
        fi
    else
        echo -e "${RED}✗ Falha no health check para $cluster_name${NC}"
        return 1
    fi
}

# Função para executar em todos os clusters
run_all_clusters() {
    local dry_run="$1"
    local verbose="$2"
    
    echo -e "${BLUE}Executando health check em todos os clusters${NC}"
    
    # Obter lista de clusters
    local clusters
    if [ -f "$INVENTORY" ]; then
        clusters=$(ansible-inventory -i "$INVENTORY" --list | jq -r 'keys[]' | grep -v "_meta")
    else
        echo -e "${RED}Arquivo de inventário não encontrado: $INVENTORY${NC}"
        exit 1
    fi
    
    local failed_clusters=()
    
    # Executar em cada cluster
    for cluster in $clusters; do
        echo -e "\n${YELLOW}=== Processando cluster: $cluster ===${NC}"
        if ! run_health_check "$cluster" "$dry_run" "$verbose"; then
            failed_clusters+=("$cluster")
        fi
    done
    
    # Resumo final
    echo -e "\n${BLUE}=== Resumo da Execução ===${NC}"
    if [ ${#failed_clusters[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ Todos os clusters foram processados com sucesso${NC}"
    else
        echo -e "${RED}✗ Falhas nos seguintes clusters:${NC}"
        for cluster in "${failed_clusters[@]}"; do
            echo -e "${RED}  - $cluster${NC}"
        done
    fi
    
    # Exibir estrutura de relatórios
    echo -e "\n${BLUE}Estrutura de relatórios gerados:${NC}"
    if [ -d "$REPORTS_DIR" ]; then
        ls -la "$REPORTS_DIR" | grep -E "^d.*_[0-9]{8}_[0-9]{6}$"
    fi
}

# Função para limpar relatórios antigos
cleanup_old_reports() {
    local days="${1:-30}"
    
    echo -e "${BLUE}Limpando relatórios com mais de $days dias${NC}"
    
    if [ -d "$REPORTS_DIR" ]; then
        find "$REPORTS_DIR" -maxdepth 1 -type d -name "*_*" -mtime +$days -exec rm -rf {} \;
        echo -e "${GREEN}✓ Limpeza concluída${NC}"
    else
        echo -e "${YELLOW}Diretório de relatórios não encontrado: $REPORTS_DIR${NC}"
    fi
}

# Função para comparar relatórios
compare_reports() {
    local cluster_name="$1"
    
    echo -e "${BLUE}Comparando relatórios do cluster: $cluster_name${NC}"
    
    local reports=($(ls -t "$REPORTS_DIR"/${cluster_name}_* 2>/dev/null | head -2))
    
    if [ ${#reports[@]} -lt 2 ]; then
        echo -e "${YELLOW}Necessário pelo menos 2 execuções para comparação${NC}"
        return 1
    fi
    
    local latest="${reports[0]}"
    local previous="${reports[1]}"
    
    echo -e "${BLUE}Comparando:${NC}"
    echo -e "${BLUE}  Última execução: $(basename $latest)${NC}"
    echo -e "${BLUE}  Execução anterior: $(basename $previous)${NC}"
    
    # Comparar pontuações
    echo -e "\n${YELLOW}Comparação de pontuações:${NC}"
    echo -e "${BLUE}Última execução:${NC}"
    grep "Pontuação Geral:" "$latest/consolidated/consolidated_health_check_report.md" || echo "Relatório não encontrado"
    
    echo -e "${BLUE}Execução anterior:${NC}"
    grep "Pontuação Geral:" "$previous/consolidated/consolidated_health_check_report.md" || echo "Relatório não encontrado"
}

# Parse de argumentos
CLUSTER=""
DRY_RUN="false"
VERBOSE="false"
LIST_CLUSTERS="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--cluster)
            CLUSTER="$2"
            shift 2
            ;;
        -l|--list)
            LIST_CLUSTERS="true"
            shift
            ;;
        -d|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        --cleanup)
            cleanup_old_reports "$2"
            exit 0
            ;;
        --compare)
            if [ -z "$2" ]; then
                echo -e "${RED}Erro: Especifique o nome do cluster para comparação${NC}"
                exit 1
            fi
            compare_reports "$2"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção desconhecida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Executar ação baseada nos argumentos
if [ "$LIST_CLUSTERS" = "true" ]; then
    list_clusters
elif [ -n "$CLUSTER" ]; then
    run_health_check "$CLUSTER" "$DRY_RUN" "$VERBOSE"
else
    run_all_clusters "$DRY_RUN" "$VERBOSE"
fi
