# Guia de Configuração do Inventário

Este diretório contém os arquivos de inventário para o OpenShift Health Check.

## Arquivos Disponíveis

- **`hosts.yml`** - Arquivo principal de inventário (use este)
- **`hosts.yml.example`** - Exemplo completo com todas as opções
- **`hosts.yml.simple`** - Exemplo mínimo e direto ao ponto
- **`GUIA_MULTIPLOS_CLUSTERS.md`** - Guia completo para múltiplos clusters

## Configuração Rápida

### Para um único cluster:

```bash
cp inventory/hosts.yml.simple inventory/hosts.yml
```

### Para múltiplos clusters:

```bash
# Opção 1: Usar script auxiliar
./ansible/inventory/configurar_multiplos_clusters.sh

# Opção 2: Copiar manualmente
cp inventory/hosts.yml.example inventory/hosts.yml
# Depois edite hosts.yml e descomente a seção openshift_clusters
```

**Consulte o [Guia de Múltiplos Clusters](./GUIA_MULTIPLOS_CLUSTERS.md) para mais detalhes.**

### Passo 2: Edite o arquivo `hosts.yml`

Abra o arquivo e ajuste as **3 variáveis obrigatórias**:

```yaml
openshift_cluster_url: "https://api.cluster.example.com:6443"
openshift_token: "sha256~seu-token-aqui"
cluster_name: "meu-cluster"
```

### Passo 3: Obtenha as informações necessárias

**URL do Cluster:**
```bash
oc cluster-info
# Saída: Kubernetes control plane is running at https://api.cluster.example.com:6443
```

**Token de Autenticação:**
```bash
oc whoami -t
# Saída: sha256~ABC123XYZ...
```

**Usuário do OpenShift:**
```bash
oc whoami
# Saída: usuario@example.com ou usuario
```

**Nome do Cluster:**
- Escolha um nome descritivo (ex: `production-cluster`, `staging-cluster`)
- Este nome será usado para organizar os relatórios

**Nota:** O playbook gera automaticamente o arquivo `kubeconfig` dentro do diretório do playbook usando o usuário e token fornecidos. Não é necessário ter um kubeconfig pré-existente.

### Passo 4: Execute o playbook

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml
```

## Exemplos de Configuração

### Exemplo 1: Execução Local Simples

```yaml
all:
  children:
    localhost:
      hosts:
        localhost:
          ansible_connection: local
          ansible_python_interpreter: "{{ ansible_playbook_python }}"
          openshift_cluster_url: "https://api.production.example.com:6443"
          openshift_token: "sha256~ABC123XYZ..."
          openshift_username: "usuario@example.com"
          cluster_name: "production-cluster"
```

**Nota:** O kubeconfig será gerado automaticamente em `ansible/.kube/config` usando o usuário e token fornecidos.

### Exemplo 2: Múltiplos Clusters

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        production-cluster:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.prod.example.com:6443"
          openshift_token: "sha256~token-prod"
          openshift_username: "usuario-prod"
          cluster_name: "production-cluster"
          
        staging-cluster:
          ansible_host: localhost
          ansible_connection: local
          openshift_cluster_url: "https://api.staging.example.com:6443"
          openshift_token: "sha256~token-staging"
          openshift_username: "usuario-staging"
          cluster_name: "staging-cluster"
```

### Exemplo 3: Execução Remota (Bastion Dedicado por Cluster)

Quando cada cluster tem seu próprio bastion com acesso exclusivo:

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        # Cluster Dev - Bastion dev-bastion
        development-cluster:
          ansible_host: dev-bastion
          ansible_user: roberto.menezes
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          openshift_cluster_url: "https://api.dev.example.com:6443"
          openshift_token: "sha256~token-dev"
          openshift_username: "roberto.menezes"
          cluster_name: "development-cluster"
        
        # Cluster Prod - Bastion dedicado
        production-cluster:
          ansible_host: bastion-prod.example.com
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          openshift_cluster_url: "https://api.prod.example.com:6443"
          openshift_token: "sha256~token-prod"
          openshift_username: "usuario-prod"
          cluster_name: "production-cluster"
```

**Nota:** Cada bastion só tem acesso ao seu cluster específico. O playbook será executado remotamente em cada bastion via SSH. Para mais detalhes, consulte: **[Guia de Bastions Múltiplos](./GUIA_BASTIONS_MULTIPLOS.md)**

## Variáveis Obrigatórias

| Variável | Descrição | Como Obter |
|----------|-----------|------------|
| `openshift_cluster_url` | URL do API Server do cluster | `oc cluster-info` |
| `openshift_token` | Token de autenticação | `oc whoami -t` |
| `openshift_username` | Usuário do OpenShift | `oc whoami` |
| `cluster_name` | Nome do cluster | Escolha um nome descritivo |

## Variáveis Opcionais

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `openshift_kubeconfig` | Caminho para kubeconfig (se não fornecido, será gerado em `ansible/.kube/config`) | Gerado automaticamente |
| `kubeconfig_path` | Caminho alternativo para kubeconfig (via `-e`) | Gerado automaticamente |
| `openshift_context` | Contexto do Kubernetes | - |
| `collect_metrics` | Coletar métricas | `true` |
| `collect_events` | Coletar eventos | `true` |
| `analyze_cost_optimization` | Analisar custos (desabilitado por padrão) | `false` |

**Importante:** Se você fornecer `kubeconfig_path` via `-e`, o playbook usará esse arquivo ao invés de gerar um novo. Caso contrário, o kubeconfig será gerado automaticamente em `ansible/.kube/config` usando o usuário e token fornecidos.
| `max_privileged_containers` | Máximo de containers privilegiados | `0` |

## Formas de Execução

### 1. Usando Variáveis do Inventário

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml
```

### 2. Sobrescrevendo Variáveis via Linha de Comando

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~token-aqui" \
  -e cluster_username="usuario@example.com" \
  -e cluster_name="meu-cluster"
```

**Nota:** O kubeconfig será gerado automaticamente usando essas credenciais.

### 3. Executando em Cluster Específico (Múltiplos Clusters)

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit production-cluster
```

### 4. Executando com Tags Específicas

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~token-aqui" \
  --tags seguranca
```

## Segurança

### Protegendo Tokens com Ansible Vault

Para proteger tokens sensíveis, use Ansible Vault:

**1. Crie um arquivo vault:**
```bash
ansible-vault create inventory/vault.yml
```

**2. Adicione o token:**
```yaml
openshift_token: "sha256~seu-token-aqui"
```

**3. Referencie no inventário:**
```yaml
openshift_token: "{{ vault_openshift_token }}"
```

**4. Execute com senha do vault:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --ask-vault-pass
```

## Solução de Problemas

### Erro: "Variável obrigatória não foi definida"

**Causa:** As variáveis obrigatórias não foram configuradas.

**Solução:** Verifique se `openshift_cluster_url`, `openshift_token` e `cluster_name` estão definidas no inventário ou via `-e`.

### Erro: "Não é possível conectar ao cluster"

**Causa:** URL ou token incorretos.

**Solução:**
1. Verifique a URL: `oc cluster-info`
2. Verifique o token: `oc whoami -t`
3. Teste a conexão: `oc get nodes`

### Erro: "Forbidden (403)"

**Causa:** Token sem permissões suficientes.

**Solução:** Verifique se o usuário tem permissões de `cluster-reader` ou superior:
```bash
oc auth can-i list nodes --all-namespaces
```

## Próximos Passos

Após configurar o inventário:

1. **Teste a conexão:**
   ```bash
   oc cluster-info
   oc get nodes
   ```

2. **Execute o health check:**
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml
   ```

3. **Visualize os relatórios:**
   ```bash
   ls -la reports/
   ```

## Múltiplos Clusters

Se você tem vários clusters, consulte o guia completo:

- **[Guia de Múltiplos Clusters](./GUIA_MULTIPLOS_CLUSTERS.md)** - Guia detalhado
- **[Exemplo de Inventário](./hosts.yml.example)** - Arquivo de exemplo

### Execução Rápida em Múltiplos Clusters:

```bash
# Em todos os clusters configurados
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters

# Em um cluster específico
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit production-cluster

# Em paralelo (mais rápido)
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters --forks 5
```

## Referências

- [Documentação Principal](../../README.md)
- [Exemplos de Uso](../examples/)
- [Guia de Simulação](../../SIMULACAO.md)
- [Guia de Múltiplos Clusters](./GUIA_MULTIPLOS_CLUSTERS.md)
- [Guia de Bastions Múltiplos](./GUIA_BASTIONS_MULTIPLOS.md) - Quando cada cluster tem seu próprio bastion
- [Geração Dinâmica de Kubeconfig](./KUBECONFIG_DINAMICO.md)
