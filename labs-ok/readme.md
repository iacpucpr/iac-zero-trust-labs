TELEPORT

Use o docker-compose.yml , ajustando o nome do host.

Crie um diretorio: 
$ mkdir -p teleport/config

Dentro do config coloque o arquivo teleport.yaml, ajustando o nome do host e o que mais precisar.

Crie um dirertorio:
$ mkdir -p teleport/certs 

Gere os arquivos de certificado digital 
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nome_servidor.key -out nome_servidor.pem

Para parar container que eventualmente estejam rodando:
$ docker-compose down -v 

Para iniciar os novos container, na pasta raiz:
$ docker-compose up -d 

Se quiser ver se tudo deu certo:
$ docker-compose logs teleport 

Para criar o primeiro usuário, dar acesso via ssh a um servidor e acessar o Teleport:
$ sudo docker-compose exec teleport tctl users add seu-usuario --roles=editor,access --logins=root,ubuntu

Parar acessar o Telepor na porta escolhida, abra o link gerado no navegador:
  https://teleport.local:443/web/invite/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Confiure a senha e o OTP.

Pronto, agora é so seguir com as demais configurações.

Possível integração com o Ggithub para autenticar usuários:
https://goteleport.com/docs/admin-guides/management/guides/github-integration/

Erros de certificados: Se der algum erro de certificado na conexao com o TSH tente colocar --insecure ao final do comando




