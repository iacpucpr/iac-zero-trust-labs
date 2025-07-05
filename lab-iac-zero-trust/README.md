
# Laboratório Zero Trust com IaC – Visão Geral

Este laboratório demonstra a evolução de um ambiente tradicional exposto para um ambiente seguro com Zero Trust,
usando Docker, Terraform, Ansible, Checkov e Twingate.

## Estrutura

```
lab-zero-trust-final/
├── etapa1-docker/       # Docker Compose
├── etapa2-terraform/    # Terraform IaC
├── etapa3-ansible/      # Hardening + Checkov + Twingate Verificação
├── exemplos/            # Política YAML
```

## Requisitos

| Ferramenta | Versão |
|-----------|--------|
| Docker | 20.10+ |
| Terraform | 1.5+ |
| Ansible | 2.15+ |
| Checkov | latest (`pip install checkov`) |
| Twingate | conta + client |

## Execução

### Etapa 1 – Docker Compose

```bash
cd etapa1-docker
docker-compose up -d
# Acesse http://localhost:8080
```

### Etapa 2 – Terraform

```bash
cd etapa2-terraform
terraform init
terraform apply -var="twingate_connector_token=seu_token_aqui"
```

### Etapa 3 – Ansible

```bash
cd etapa3-ansible
ansible-playbook -i inventory.ini playbook.yml
```

- Executa validação com Checkov (opcional)
- Aplica hardening no GLPI
- Verifica se o Twingate está funcionando

### Limpeza

```bash
cd etapa2-terraform
terraform destroy -auto-approve

cd etapa1-docker
docker-compose down -v
```

---

Gerado em: 2025-07-04 18:32
