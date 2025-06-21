
# Laboratórios Zero Trust com IaC e Containers

Este pacote contém dois laboratórios práticos voltados à aplicação de conceitos de Zero Trust em ambientes provisionados com Infrastructure as Code (IaC) e containers.

---

## 📦 Estrutura do Pacote

```
labs/
├── lab1_credenciais/
│   ├── docker-compose.yml
│   ├── authelia/
│   ├── vault/
│   ├── app/
│   ├── ansible/
│   └── terraform/
├── lab2_rede/
│   ├── docker-compose.yml
│   ├── terraform/
│   ├── guacamole_keycloak/
│   └── glpi_mariadb/
├── .env.example
├── Checklist_Execucao_Minicurso_ZeroTrust_v2.txt
└── README.md
```

---

## ✅ Lab 1: Gerenciamento de Credenciais com Vault + Authelia

### Objetivo:
- Demonstrar autenticação forte com Authelia
- Gerenciar segredos com Vault
- Usar uma aplicação Flask como cliente seguro

### Como Executar:
1. Copie `.env.example` para `.env` e ajuste se necessário.
2. Acesse o diretório `lab1_credenciais/`.
3. Execute o provisionamento via Terraform (em `terraform/`):
   ```
   terraform init
   terraform apply
   ```
4. Execute o playbook Ansible (em `ansible/`):
   ```
   ansible-playbook playbook.yml
   ```
5. Inicie os serviços:
   ```
   docker-compose up -d
   ```

---

## 🔐 Lab 2: Segmentação de Rede com Keycloak + Guacamole + GLPI

### Objetivo:
- Demonstrar acesso remoto controlado com Guacamole
- Implementar autenticação e SSO com Keycloak
- Integrar com sistema GLPI + MariaDB como alvo de acesso remoto

### Como Executar:
1. Copie `.env.example` para `.env`.
2. Acesse o diretório `lab2_rede/`.
3. Execute o provisionamento com Terraform:
   ```
   terraform init
   terraform apply
   ```
4. Inicie os containers:
   ```
   docker-compose up -d
   ```

---

## ⚙️ Requisitos

- Docker
- Docker Compose
- Terraform
- Ansible
- Git (para clonar o repositório, se necessário)

---

## 📋 Checklist de Execução

Consulte o arquivo `Checklist_Execucao_Minicurso_ZeroTrust_v2.txt` para um passo a passo guiado.

---

## 🧪 Extensões Futuras

- Autenticação via authentik
- Integração com Twingate ou Teleport
- Deploy via pipelines CI/CD
