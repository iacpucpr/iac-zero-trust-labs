
vault server -dev -dev-root-token-id=root &
sleep 5
export VAULT_ADDR='http://127.0.0.1:8200'
vault kv put secret/app/secret mensagem='Olá do Vault!'
