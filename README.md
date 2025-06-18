# Laboratórios Práticos – IaC e Zero Trust

Este repositório contém dois laboratórios práticos que simulam a aplicação de boas práticas de segurança em ambientes provisionados com Infrastructure as Code (IaC) e princípios de Zero Trust.

## Estrutura

- `labs/lab1_credenciais`: Uso de Authelia e Vault com aplicação Flask
- `labs/lab2_rede`: Segmentação com Guacamole, Keycloak e Terraform
- `docs/`: Guias passo a passo
- `Dockerfile`: Ambiente Dev completo
- `docker-compose.yml`: Execução local
- `.devcontainer/`: Execução via VS Code

## Requisitos

- Docker e Docker Compose
- VS Code (opcional)
- (opcional) Terraform CLI

## Como executar (exemplo com Lab 1)

```bash
cd labs/lab1_credenciais/ansible
ansible-playbook playbook.yml
```

## Como usar com VS Code

1. Instale a extensão **Dev Containers** no VS Code.
2. Abra o repositório.
3. Escolha: “Reabrir em Container”.

O ambiente virá com Docker, Ansible, Terraform e Python 3 prontos para uso.
