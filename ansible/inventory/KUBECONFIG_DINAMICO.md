# Geração Dinâmica de Kubeconfig

Este documento explica como o playbook gera automaticamente o arquivo `kubeconfig` usando usuário e token fornecidos como variáveis.

## Como Funciona

O playbook agora gera automaticamente o arquivo `kubeconfig` dentro do diretório `ansible/.kube/config` usando as credenciais fornecidas (usuário e token). Isso elimina a necessidade de ter um arquivo `kubeconfig` pré-existente.

## Variáveis Necessárias

Para gerar o kubeconfig dinamicamente, você precisa fornecer:

1. **`openshift_cluster_url`** - URL do API Server do cluster
2. **`openshift_token`** - Token de autenticação
3. **`openshift_username`** - Nome do usuário do OpenShift

## Exemplo de Configuração no Inventário

```yaml
all:
  children:
    localhost:
      hosts:
        localhost:
          ansible_connection: local
          openshift_cluster_url: "https://api.cluster.example.com:6443"
          openshift_token: "sha256~seu-token-aqui"
          openshift_username: "usuario@example.com"
          cluster_name: "meu-cluster"
```

## Como Obter as Informações

### URL do Cluster
```bash
oc cluster-info
# Saída: Kubernetes control plane is running at https://api.cluster.example.com:6443
```

### Token de Autenticação
```bash
oc whoami -t
# Saída: sha256~ABC123XYZ...
```

### Usuário do OpenShift
```bash
oc whoami
# Saída: usuario@example.com ou usuario
```

## Processo de Geração

O playbook segue esta ordem:

1. **Cria o diretório** `ansible/.kube/` se não existir
2. **Tenta gerar usando `oc login`** (método preferido)
3. **Se falhar, gera manualmente** criando o arquivo kubeconfig com a estrutura correta
4. **Valida** se o arquivo foi criado com sucesso

## Localização do Kubeconfig Gerado

Por padrão, o kubeconfig é gerado em:
```
ansible/.kube/config
```

Este arquivo é criado automaticamente e usado durante toda a execução do playbook.

## Usando Kubeconfig Existente (Opcional)

Se você já tem um kubeconfig e prefere usá-lo ao invés de gerar um novo, você pode:

### Opção 1: Via Variável no Inventário
```yaml
openshift_kubeconfig: "~/.kube/config"
```

### Opção 2: Via Linha de Comando
```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e kubeconfig_path="~/.kube/config" \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~token"
```

**Nota:** Quando `kubeconfig_path` é fornecido, o playbook **não gera** um novo kubeconfig e usa o arquivo especificado. Neste caso, `openshift_username` não é obrigatório.

## Exemplos de Execução

### Exemplo 1: Usando Inventário (Geração Automática)

```bash
# Configure o inventário com usuário e token
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml
```

O kubeconfig será gerado automaticamente em `ansible/.kube/config`.

### Exemplo 2: Via Linha de Comando

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~token-aqui" \
  -e cluster_username="usuario@example.com" \
  -e cluster_name="meu-cluster"
```

### Exemplo 3: Múltiplos Clusters

```yaml
openshift_clusters:
  hosts:
    cluster1:
      openshift_cluster_url: "https://api.cluster1.com:6443"
      openshift_token: "sha256~token1"
      openshift_username: "usuario1"
      cluster_name: "cluster1"
    
    cluster2:
      openshift_cluster_url: "https://api.cluster2.com:6443"
      openshift_token: "sha256~token2"
      openshift_username: "usuario2"
      cluster_name: "cluster2"
```

Cada cluster terá seu próprio kubeconfig gerado durante a execução.

## Segurança

- O arquivo kubeconfig gerado tem permissões `0600` (apenas leitura/escrita para o proprietário)
- O diretório `.kube` tem permissões `0700`
- O kubeconfig gerado contém o token em texto plano - mantenha o diretório seguro
- Considere limpar o arquivo após a execução se necessário

## Limpeza

Para remover o kubeconfig gerado após a execução:

```bash
rm -rf ansible/.kube/
```

Ou adicione ao `.gitignore`:

```
ansible/.kube/
```

## Solução de Problemas

### Erro: "Não foi possível gerar o kubeconfig"

**Causa:** O comando `oc login` falhou ou não está disponível.

**Solução:**
1. Verifique se `oc` está instalado: `which oc`
2. Verifique se o token é válido: `oc whoami -t`
3. Teste o login manualmente: `oc login --token=TOKEN URL`

### Erro: "Variável 'openshift_username' é obrigatória"

**Causa:** O usuário não foi fornecido e nenhum kubeconfig_path foi especificado.

**Solução:** Adicione `openshift_username` no inventário ou via `-e cluster_username="usuario"`.

### Erro: "Cannot connect to OpenShift cluster"

**Causa:** O kubeconfig gerado não está funcionando corretamente.

**Solução:**
1. Verifique se o arquivo foi criado: `ls -la ansible/.kube/config`
2. Teste manualmente: `oc --kubeconfig=ansible/.kube/config get nodes`
3. Verifique as credenciais (URL, token, usuário)

## Referências

- [Documentação do Inventário](./README.md)
- [Guia de Múltiplos Clusters](./GUIA_MULTIPLOS_CLUSTERS.md)
- [Documentação Principal](../../README.md)
