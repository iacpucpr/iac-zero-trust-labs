
# 🧪 Lab 2 – Segmentação de Rede com Keycloak, Guacamole e GLPI

Este laboratório demonstra uma arquitetura segmentada com autenticação forte e acesso remoto seguro usando ferramentas Zero Trust.

## 🔧 Serviços envolvidos

- **Keycloak** – Gerenciamento de identidade (porta 8081)
- **Guacamole** – Acesso remoto via navegador (porta 8082)
- **GLPI + MariaDB** – Aplicação legada para gestão de serviços de TI (porta 8083)

## 📦 Estrutura

```
lab2_rede/
├── docker-compose.yml         # Orquestra Keycloak + Guacamole
├── terraform/                 # Provisionamento obrigatório com Terraform
│   └── main.tf
├── guacamole_keycloak/       # Configurações de Guacamole + Keycloak
├── glpi_mariadb/             # Ambiente do GLPI + banco de dados
│   └── docker-compose.yml
└── twingate/ (opcional)
```

## ▶️ Como executar o ambiente

1. **Provisione os serviços principais com Terraform**
```bash
cd terraform
terraform init
terraform apply
```

2. **Suba os serviços do GLPI**
```bash
cd ../glpi_mariadb
docker-compose up -d
```

3. **Verifique se os serviços estão ativos**
```bash
docker ps
```

## 🌐 Endpoints

| Serviço     | URL                       | Credenciais padrão |
|-------------|---------------------------|---------------------|
| Keycloak    | http://localhost:8081     | admin / admin      |
| Guacamole   | http://localhost:8082     | guacadmin / guacadmin |
| GLPI        | http://localhost:8083     | glpi / glpi        |

## 🎯 Objetivos

- Simular segmentação e controle de acesso com autenticação centralizada
- Acessar aplicações (como GLPI) via Guacamole com autenticação forte
- Proteger aplicações legadas com mecanismos Zero Trust
