#!/bin/bash
# /guacamole/init/initdb.sh
set -e

# Executa os comandos SQL usando psql, que entende as variáveis de ambiente
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Cria o usuário e o banco de dados para o Guacamole
    CREATE USER ${GUACAMOLE_DB_USER} WITH PASSWORD '${GUACAMOLE_DB_PASSWORD}';
    CREATE DATABASE ${GUACAMOLE_DB_NAME};
    GRANT ALL PRIVILEGES ON DATABASE ${GUACAMOLE_DB_NAME} TO ${GUACAMOLE_DB_USER};
EOSQL

# Conecta ao banco de dados recém-criado do Guacamole para importar o schema
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${GUACAMOLE_DB_NAME}" <<-EOSQL
    -- Importa o schema oficial do Guacamole
    \i /docker-entrypoint-initdb.d/schema/001-create-database.sql
    \i /docker-entrypoint-initdb.d/schema/002-create-admin-user.sql

    -- Concede os privilégios necessários nas tabelas
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${GUACAMOLE_DB_USER};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${GUACAMOLE_DB_USER};
EOSQL
