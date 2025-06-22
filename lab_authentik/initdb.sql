-- /docker-stack/guacamole/init/initdb.sql

-- Cria o usuário para o banco de dados do Guacamole
CREATE USER ${GUACAMOLE_DB_USER} WITH PASSWORD '${GUACAMOLE_DB_PASSWORD}';

-- Cria o banco de dados
CREATE DATABASE ${GUACAMOLE_DB_NAME} WITH OWNER = ${GUACAMOLE_DB_USER};

-- Conecta ao novo banco de dados para executar os próximos comandos
\c ${GUACAMOLE_DB_NAME}

-- Importa o schema oficial do Guacamole que estará disponível dentro do contêiner
\i /docker-entrypoint-initdb.d/schema/001-create-database.sql
\i /docker-entrypoint-initdb.d/schema/002-create-admin-user.sql

-- Concede todos os privilégios ao usuário no novo banco de dados
GRANT ALL PRIVILEGES ON DATABASE ${GUACAMOLE_DB_NAME} TO ${GUACAMOLE_DB_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${GUACAMOLE_DB_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${GUACAMOLE_DB_USER};

