# Guia Completo: Múltiplos Clusters

Este guia explica como configurar e executar o OpenShift Health Check em múltiplos clusters.

## 📋 Índice

1. [Configuração Rápida](#configuração-rápida)
2. [Estrutura do Inventário](#estrutura-do-inventário)
3. [Executando em Múltiplos Clusters](#executando-em-múltiplos-clusters)
4. [Exemplos Práticos](#exemplos-práticos)
5. [Gerenciamento de Tokens](#gerenciamento-de-tokens)
6. [Solução de Problemas](#solução-de-problemas)

## 🚀 Configuração Rápida

### Passo 1: Copie o arquivo de exemplo

```bash
cd ansible/inventory
cp hosts_multiplos_clusters.yml hosts.yml
```

### Passo 2: Edite o arquivo `hosts.yml`

Abra o arquivo e configure seus clusters:

```yaml
openshift_clusters:
  hosts:
    meu-cluster-prod:
      ansible_host: localhost
      ansible_connection: local
      openshift_cluster_url: "https://api.meu-cluster.com:6443"
      openshift_token: "sha256~meu-token"
      cluster_name: "meu-cluster-prod"
    
    meu-cluster-dev:
      ansible_host: localhost
      ansible_connection: local
      openshift_cluster_url: "https://api.dev.meu-cluster.com:6443"
      openshift_token: "sha256~meu-token-dev"
      cluster_name: "meu-cluster-dev"
```

### Passo 3: Execute

```bash
# Em todos os clusters
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters

# Em um cluster específico
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit meu-cluster-prod
```

## 📁 Estrutura do Inventário

### Formato Básico

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        nome-do-cluster-1:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.cluster1.com:6443"
          openshift_token: "sha256~token1"
          cluster_name: "nome-do-cluster-1"
        
        nome-do-cluster-2:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.cluster2.com:6443"
          openshift_token: "sha256~token2"
          cluster_name: "nome-do-cluster-2"
```

### Variáveis Obrigatórias por Cluster

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `openshift_cluster_url` | URL do API Server | `https://api.cluster.com:6443` |
| `openshift_token` | Token de autenticação | `sha256~ABC123...` |
| `cluster_name` | Nome único do cluster | `production-cluster` |

### Variáveis Opcionais por Cluster

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `max_privileged_containers` | Máximo de containers privilegiados | `0` |
| `analyze_cost_optimization` | Analisar custos | `true` |
| `collect_metrics` | Coletar métricas | `true` |
| `collect_events` | Coletar eventos | `true` |

## 🎯 Executando em Múltiplos Clusters

### Método 1: Usando Ansible Playbook Diretamente

#### Executar em todos os clusters:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters
```

#### Executar em um cluster específico:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit production-cluster
```

#### Executar em múltiplos clusters específicos:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit "production-cluster,staging-cluster"
```

#### Executar em paralelo (mais rápido):

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --forks 5
```

### Método 2: Usando Script Automatizado

O projeto inclui um script para facilitar a execução:

```bash
# Listar clusters disponíveis
./ansible/examples/run_health_check_multiple_clusters.sh -l

# Executar em todos os clusters
./ansible/examples/run_health_check_multiple_clusters.sh

# Executar em cluster específico
./ansible/examples/run_health_check_multiple_clusters.sh -c production-cluster

# Modo dry-run
./ansible/examples/run_health_check_multiple_clusters.sh -d

# Modo verbose
./ansible/examples/run_health_check_multiple_clusters.sh -v
```

### Método 3: Execução Sequencial com Loop

```bash
for cluster in production-cluster staging-cluster development-cluster; do
  echo "Executando health check no cluster: $cluster"
  ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
    --limit "$cluster"
done
```

## 💡 Exemplos Práticos

### Exemplo 1: Configuração Básica de 3 Clusters

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        prod:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.prod.example.com:6443"
          openshift_token: "sha256~token-prod"
          cluster_name: "prod"
        
        staging:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.staging.example.com:6443"
          openshift_token: "sha256~token-staging"
          cluster_name: "staging"
        
        dev:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.dev.example.com:6443"
          openshift_token: "sha256~token-dev"
          cluster_name: "dev"
```

**Executar:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters
```

### Exemplo 2: Clusters com Configurações Diferentes

```yaml
openshift_clusters:
  hosts:
    production:
      ansible_host: localhost
      ansible_connection: local
      openshift_cluster_url: "https://api.prod.com:6443"
      openshift_token: "sha256~token-prod"
      cluster_name: "production"
      # Produção: mais rigoroso
      max_privileged_containers: 0
      analyze_cost_optimization: true
      collect_metrics: true
    
    development:
      ansible_host: localhost
      ansible_connection: local
      openshift_cluster_url: "https://api.dev.com:6443"
      openshift_token: "sha256~token-dev"
      cluster_name: "development"
      # Desenvolvimento: mais flexível
      max_privileged_containers: 2
      analyze_cost_optimization: false
      collect_metrics: false
```

### Exemplo 3: Execução com Tags Específicas

```bash
# Apenas análise de segurança em todos os clusters
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --tags seguranca

# Apenas análise de arquitetura em produção
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit production-cluster \
  --tags arquitetura
```

### Exemplo 4: Execução Agendada (Cron)

Crie um script `health_check_all_clusters.sh`:

```bash
#!/bin/bash
cd /path/to/openshift_health_check/ansible
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters
```

Adicione ao crontab:

```bash
# Executar diariamente às 2h da manhã
0 2 * * * /path/to/health_check_all_clusters.sh >> /var/log/health_check.log 2>&1
```

## 🔐 Gerenciamento de Tokens

### Opção 1: Tokens no Inventário (Simples)

```yaml
openshift_clusters:
  hosts:
    cluster1:
      openshift_token: "sha256~token-aqui"
```

**⚠️ Atenção:** Tokens ficam em texto plano no arquivo.

### Opção 2: Ansible Vault (Recomendado)

**1. Criar arquivo vault:**

```bash
ansible-vault create inventory/vault.yml
```

**2. Adicionar tokens:**

```yaml
vault_cluster_tokens:
  production-cluster: "sha256~token-prod"
  staging-cluster: "sha256~token-staging"
  development-cluster: "sha256~token-dev"
```

**3. Referenciar no inventário:**

```yaml
openshift_clusters:
  hosts:
    production-cluster:
      openshift_token: "{{ vault_cluster_tokens['production-cluster'] }}"
    staging-cluster:
      openshift_token: "{{ vault_cluster_tokens['staging-cluster'] }}"
```

**4. Executar com senha do vault:**

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --ask-vault-pass
```

### Opção 3: Variáveis de Ambiente

```bash
export OC_TOKEN_PROD="sha256~token-prod"
export OC_TOKEN_STAGING="sha256~token-staging"

ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  -e "openshift_token={{ lookup('env', 'OC_TOKEN_PROD') }}"
```

## 🔍 Solução de Problemas

### Problema: "Cluster não encontrado no inventário"

**Solução:**
```bash
# Listar clusters disponíveis
ansible-inventory -i inventory/hosts.yml --list

# Verificar sintaxe do inventário
ansible-inventory -i inventory/hosts.yml --list | jq .
```

### Problema: "Token inválido para um cluster"

**Solução:**
```bash
# Testar token manualmente
oc login --token=sha256~token-aqui https://api.cluster.com:6443
oc get nodes
```

### Problema: "Execução muito lenta em múltiplos clusters"

**Solução:**
```bash
# Executar em paralelo
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --forks 5

# Ou executar apenas tags específicas
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --tags seguranca
```

### Problema: "Relatórios misturados"

**Solução:** Cada cluster gera relatórios em diretórios separados:
```
reports/
├── production-cluster_20241215_143022/
├── staging-cluster_20241215_144530/
└── development-cluster_20241215_150145/
```

## 📊 Visualizando Relatórios de Múltiplos Clusters

### Listar todos os relatórios:

```bash
ls -la reports/
```

### Abrir relatório específico:

```bash
# Relatório consolidado de produção
open reports/production-cluster_*/html/consolidated/consolidated_health_check_report.html
```

### Comparar clusters:

```bash
# Comparar relatórios Markdown
diff reports/production-cluster_*/consolidated/consolidated_health_check_report.md \
      reports/staging-cluster_*/consolidated/consolidated_health_check_report.md
```

## 📚 Referências

- [Documentação Principal](../../README.md)
- [Guia de Inventário](./README.md)
- [Script de Múltiplos Clusters](../examples/run_health_check_multiple_clusters.sh)
