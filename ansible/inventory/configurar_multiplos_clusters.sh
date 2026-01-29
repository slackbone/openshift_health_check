#!/bin/bash

# Script para configurar múltiplos clusters no inventário
# Este script ajuda a adicionar clusters ao arquivo hosts.yml

set -e

INVENTORY_FILE="ansible/inventory/hosts.yml"
EXAMPLE_FILE="ansible/inventory/hosts_multiplos_clusters.yml"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Configuração de Múltiplos Clusters${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar se o arquivo de exemplo existe
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo -e "${YELLOW}Arquivo de exemplo não encontrado: $EXAMPLE_FILE${NC}"
    exit 1
fi

# Perguntar se deseja usar o arquivo de exemplo
echo -e "${YELLOW}Deseja copiar o arquivo de exemplo para hosts.yml?${NC}"
echo -e "${YELLOW}(Isso irá sobrescrever o arquivo atual)${NC}"
read -p "Digite 'sim' para continuar: " resposta

if [ "$resposta" != "sim" ]; then
    echo "Operação cancelada."
    exit 0
fi

# Fazer backup do arquivo atual se existir
if [ -f "$INVENTORY_FILE" ]; then
    BACKUP_FILE="${INVENTORY_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${BLUE}Fazendo backup do arquivo atual para: $BACKUP_FILE${NC}"
    cp "$INVENTORY_FILE" "$BACKUP_FILE"
fi

# Copiar arquivo de exemplo
echo -e "${GREEN}Copiando arquivo de exemplo...${NC}"
cp "$EXAMPLE_FILE" "$INVENTORY_FILE"

echo ""
echo -e "${GREEN}✓ Arquivo copiado com sucesso!${NC}"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Edite o arquivo: $INVENTORY_FILE"
echo "2. Configure as URLs e tokens dos seus clusters"
echo "3. Execute: ansible-playbook -i $INVENTORY_FILE playbooks/openshift_health_check.yml --limit openshift_clusters"
echo ""
echo -e "${YELLOW}Para obter as informações necessárias:${NC}"
echo "  - URL do cluster: oc cluster-info"
echo "  - Token: oc whoami -t"
echo ""
