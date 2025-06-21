TELEPORT

Use o docker-compose.yml , ajustando o nome do host.
Crie um diretorio teleport/config
Dentro do config coloque o arquivo teleport.yaml, ajustando o nome do host e o que mais precisar
Crie um dirertorio teleport/certs e gere os arquivos de certificado digital 
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nome_servidor.key -out nome_servidor.pem
$ docker-compose down -v (para parar container que eventualmente estejam rodando
$ docker-compose up -d (para iniciar os novos container)
$ docker-compose logs teleport (se quiser ver se tudo deu certo)
$ sudo docker-compose exec teleport tctl users add seu-usuario --roles=editor,access --logins=root,ubuntu
Abra o link gerado no navegador https://teleport.local:443/web/invite/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Confiure a senha e o OTP.
Pronto, agora é so seguir com as demais configurações.


