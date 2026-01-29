# Guia: Múltiplos Clusters com Bastions Dedicados

Este guia explica como configurar o OpenShift Health Check quando **cada cluster tem seu próprio bastion** com acesso exclusivo.

## Arquitetura

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Seu Host      │         │   Seu Host      │         │   Seu Host      │
│  (Controlador)  │         │  (Controlador)  │         │  (Controlador)  │
└────────┬────────┘         └────────┬────────┘         └────────┬────────┘
         │                          │                          │
         │ SSH                     │ SSH                     │ SSH
         │                          │                          │
    ┌────▼────┐                ┌────▼────┐                ┌────▼────┐
    │ Bastion │                │ Bastion │                │ Bastion │
    │   Dev   │                │  Prod   │                │ Staging │
    │timbiras │                │bastion- │                │bastion- │
    │-bastion │                │  prod   │                │staging  │
    └────┬────┘                └────┬────┘                └────┬────┘
         │                          │                          │
         │                          │                          │
    ┌────▼────┐                ┌────▼────┐                ┌────▼────┐
    │ Cluster │                │ Cluster │                │ Cluster │
    │   Dev   │                │  Prod   │                │ Staging │
    └─────────┘                └─────────┘                └─────────┘
```

**Características:**
- Cada cluster tem seu próprio bastion
- Cada bastion só tem acesso ao seu cluster específico
- O playbook é executado remotamente em cada bastion via SSH
- Os relatórios são gerados localmente em cada bastion

## Configuração do Inventário

### Exemplo Completo

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        # Cluster de Desenvolvimento
        development-cluster:
          # Bastion específico para este cluster
          ansible_host: timbiras-bastion
          ansible_user: roberto.menezes
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          
          # Configurações do cluster (acessível apenas deste bastion)
          openshift_cluster_url: "https://api.ocp-dev.cloud.prodesp.sp.gov.br:6443"
          openshift_token: "sha256~token-dev"
          openshift_username: "roberto.menezes"
          cluster_name: "development-cluster"
        
        # Cluster de Produção
        production-cluster:
          # Bastion específico para este cluster
          ansible_host: bastion-prod.example.com
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          
          # Configurações do cluster (acessível apenas deste bastion)
          openshift_cluster_url: "https://api.production.example.com:6443"
          openshift_token: "sha256~token-prod"
          openshift_username: "usuario-prod"
          cluster_name: "production-cluster"
        
        # Cluster de Staging
        staging-cluster:
          # Bastion específico para este cluster
          ansible_host: bastion-staging.example.com
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          
          # Configurações do cluster (acessível apenas deste bastion)
          openshift_cluster_url: "https://api.staging.example.com:6443"
          openshift_token: "sha256~token-staging"
          openshift_username: "usuario-staging"
          cluster_name: "staging-cluster"
```

## Pré-requisitos

### 1. Acesso SSH aos Bastions

Certifique-se de que você tem acesso SSH a todos os bastions:

```bash
# Testar acesso ao bastion do dev
ssh roberto.menezes@timbiras-bastion

# Testar acesso ao bastion de produção
ssh admin@bastion-prod.example.com
```

### 2. Chave SSH Configurada

Configure suas chaves SSH para acesso sem senha:

```bash
# Copiar chave pública para o bastion
ssh-copy-id roberto.menezes@timbiras-bastion
ssh-copy-id admin@bastion-prod.example.com
```

### 3. Código do Playbook nos Bastions

O código do playbook precisa estar disponível em cada bastion. Você tem duas opções:

#### Opção A: Código já existe nos bastions

Se o código já está em cada bastion (mesmo caminho), configure apenas o inventário.

#### Opção B: Usar Ansible para copiar o código

Use o módulo `synchronize` ou `copy` do Ansible para copiar o código antes de executar:

```yaml
- name: Copiar código do playbook para bastion
  synchronize:
    src: "{{ playbook_dir }}"
    dest: "/tmp/openshift_health_check"
    delete: false
  delegate_to: "{{ ansible_host }}"
```

## Execução

### 1. Testar Conectividade

Antes de executar, teste a conectividade SSH com todos os bastions:

```bash
ansible -i inventory/hosts.yml openshift_clusters -m ping
```

**Saída esperada:**
```
development-cluster | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
production-cluster | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 2. Executar em Todos os Clusters

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters
```

Isso executará:
- No bastion `timbiras-bastion` para o cluster `development-cluster`
- No bastion `bastion-prod.example.com` para o cluster `production-cluster`
- No bastion `bastion-staging.example.com` para o cluster `staging-cluster`

### 3. Executar em um Cluster Específico

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit development-cluster
```

Isso executará apenas no bastion `timbiras-bastion` para o cluster `development-cluster`.

### 4. Executar em Paralelo

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --forks 5
```

Isso executará em até 5 bastions simultaneamente.

## Onde os Relatórios são Gerados?

Os relatórios são gerados **localmente em cada bastion** no diretório:
```
/tmp/openshift_health_check/reports/{cluster_name}_{timestamp}/
```

Para coletar os relatórios de volta para seu host:

```bash
# Criar diretório local para receber relatórios
mkdir -p reports/

# Copiar relatórios do bastion dev
scp -r roberto.menezes@timbiras-bastion:/tmp/openshift_health_check/reports/* reports/

# Copiar relatórios do bastion prod
scp -r admin@bastion-prod.example.com:/tmp/openshift_health_check/reports/* reports/
```

Ou use Ansible para coletar automaticamente:

```yaml
- name: Coletar relatórios dos bastions
  fetch:
    src: "/tmp/openshift_health_check/reports/{{ cluster_name }}_{{ timestamp }}/"
    dest: "reports/"
    flat: no
  delegate_to: "{{ ansible_host }}"
```

## Configuração de SSH

### Usando Arquivo de Config SSH

Configure `~/.ssh/config` para facilitar o acesso:

```
Host timbiras-bastion
    HostName timbiras-bastion
    User roberto.menezes
    IdentityFile ~/.ssh/id_rsa

Host bastion-prod
    HostName bastion-prod.example.com
    User admin
    IdentityFile ~/.ssh/id_rsa

Host bastion-staging
    HostName bastion-staging.example.com
    User admin
    IdentityFile ~/.ssh/id_rsa
```

Então no inventário você pode usar apenas:

```yaml
ansible_host: timbiras-bastion  # Usa a configuração do ~/.ssh/config
```

### Usando Diferentes Chaves SSH

Se cada bastion usa uma chave SSH diferente:

```yaml
development-cluster:
  ansible_host: timbiras-bastion
  ansible_user: roberto.menezes
  ansible_ssh_private_key_file: ~/.ssh/id_rsa_dev

production-cluster:
  ansible_host: bastion-prod.example.com
  ansible_user: admin
  ansible_ssh_private_key_file: ~/.ssh/id_rsa_prod
```

## Solução de Problemas

### Erro: "Host key verification failed"

**Solução:**
```bash
# Adicionar bastions ao known_hosts
ssh-keyscan timbiras-bastion >> ~/.ssh/known_hosts
ssh-keyscan bastion-prod.example.com >> ~/.ssh/known_hosts
```

Ou configure no `ansible.cfg`:
```ini
[defaults]
host_key_checking = False
```

### Erro: "Permission denied (publickey)"

**Causa:** Chave SSH não está configurada ou não tem acesso.

**Solução:**
```bash
# Verificar se a chave está sendo usada
ssh -v roberto.menezes@timbiras-bastion

# Copiar chave pública
ssh-copy-id -i ~/.ssh/id_rsa.pub roberto.menezes@timbiras-bastion
```

### Erro: "No route to host"

**Causa:** Bastion não está acessível da sua máquina.

**Solução:**
```bash
# Testar conectividade
ping timbiras-bastion
telnet timbiras-bastion 22
```

### Erro: "Playbook não encontrado no bastion"

**Causa:** O código do playbook não está no bastion.

**Solução:** Copie o código antes de executar ou use `ansible-playbook` com `--become` para copiar via SCP.

## Exemplo Completo de Execução

```bash
# 1. Testar conectividade
ansible -i inventory/hosts.yml openshift_clusters -m ping

# 2. Executar em todos os clusters
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  --limit openshift_clusters \
  --forks 3

# 3. Coletar relatórios
mkdir -p reports/
for cluster in development-cluster production-cluster staging-cluster; do
  bastion=$(ansible-inventory -i inventory/hosts.yml --host $cluster | jq -r '.ansible_host')
  user=$(ansible-inventory -i inventory/hosts.yml --host $cluster | jq -r '.ansible_user')
  scp -r ${user}@${bastion}:/tmp/openshift_health_check/reports/* reports/ 2>/dev/null || true
done
```

## Referências

- [Guia de Múltiplos Clusters](./GUIA_MULTIPLOS_CLUSTERS.md)
- [Documentação do Inventário](./README.md)
- [Geração Dinâmica de Kubeconfig](./KUBECONFIG_DINAMICO.md)
