**AUTHENTIK**

Visão Geral da Arquitetura

    Traefik (Gateway/Reverse Proxy): Será a porta de entrada para todas as suas aplicações. Ele gerenciará os certificados SSL (via Let's Encrypt) e roteará o tráfego para o serviço correto.
    Authentik (Provedor de Identidade): Todos os acessos a serviços protegidos (como o Guacamole) passarão primeiro pela autenticação do Authentik.
    Guacamole (Acesso Remoto): Sua aplicação principal, que ficará acessível apenas para usuários autenticados.
    Nginx (Servidor Web Isolado): Um servidor web que rodará em uma rede separada, mas que ainda será acessível publicamente através do Traefik.
    Redes:
        proxy: Rede principal onde o Traefik se comunica com os serviços que ele expõe (Authentik, Guacamole).
        nginx-net: Rede isolada para o servidor Nginx. O Traefik também participará desta rede para poder alcançá-lo.
        Redes internas (authentik-internal, guacamole-internal) para comunicação segura entre os componentes de cada aplicação (ex: Guacamole e seu banco de dados).

Pré-requisitos

    Docker e Docker Compose instalados no seu servidor.
    Domínio e DNS: Você precisará de 4 subdomínios apontando para o IP público do seu servidor. Para este exemplo, usaremos:
        traefik.seu-dominio.com
        auth.seu-dominio.com
        guacamole.seu-dominio.com
        nginx.seu-dominio.com
    Portas 80 e 443 abertas no seu firewall.

Estrutura de Diretórios

Para uma melhor organização, recomendo a seguinte estrutura de arquivos. Crie estes diretórios e arquivos vazios antes de começar:

    /docker-stack/
    -- .env                     # Arquivo de variáveis de ambiente
    -- docker-compose.yml       # Nosso arquivo principal
    
    -- traefik/
       |-- traefik.yml          # Configuração estática do Traefik
       |-- acme.json            # Arquivo para os certificados SSL (crie vazio)
    
    -- authentik/               # Diretórios para dados persistentes
       |-- media/
       |-- templates/
       |-- geoip/
    
    -- guacamole/
       |-- data/
       |-- init/
       |   |-- initdb.sh       # Script de inicialização do BD do Guacamole
    
    -- nginx/
       |-- html/
       |   |-- index.html       # Página de exemplo para o Nginx

Ajustes de permissões
        chmod +x ./guacamole/init/initdb.sh
        sudo chmod 644 ./traefik/certs/*

Passo a Passo para Gerar Certificados Autoassinados

Para que o Traefik possa servir suas aplicações via HTTPS, ele precisa de um arquivo de certificado e uma chave privada. Siga estes passos no seu terminal, na máquina que roda o Docker.

    Crie um diretório para os certificados:
    Dentro do seu diretório principal /docker-stack/, crie uma pasta para armazenar os certificados.

    mkdir -p docker-stack/traefik/certs

    Gere o certificado e a chave:
    Execute o comando openssl abaixo. Ele criará dois arquivos: cert.pem (o certificado público) e key.pem (a chave privada) dentro do diretório traefik/certs.

    Importante: Substitua seu-dominio-local.lab pelo domínio que você usará internamente. Pode ser qualquer nome, mas você deve usá-lo de forma consistente. Você também pode usar o endereço IP da sua máquina Docker se preferir.

    openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout docker-stack/traefik/certs/key.pem \
      -out docker-stack/traefik/certs/cert.pem \
      -sha256 -days 365 \
      -subj "/CN=seu-dominio-local.lab" \
      -addext "subjectAltName = DNS:seu-dominio-local.lab"

ou via linha de comando direto
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout seu-dominio.key -out seu-dominio.pem

    chmod 600 seu-dominio.key

    Ajuste seu arquivo hosts local:
    Para que seu navegador consiga acessar os serviços usando os nomes de domínio (ex: guacamole.seu-dominio-local.lab), você precisa dizer ao seu sistema operacional para onde ele deve apontar.

        Encontre o IP do seu servidor Docker. Se estiver rodando localmente, será 127.0.0.1. Se for outra máquina na sua rede, use o IP dela.

        Edite o arquivo hosts:

            Windows: C:\Windows\System32\drivers\etc\hosts (edite como Administrador).

            Linux/macOS: /etc/hosts (edite com sudo).

        Adicione as seguintes linhas, substituindo 192.168.1.100 pelo IP do seu servidor Docker e seu-dominio-local.lab pelo domínio que você usou no certificado:

    192.168.1.100   traefik.seu-dominio-local.lab
    192.168.1.100   auth.seu-dominio-local.lab
    192.168.1.100   guacamole.seu-dominio-local.lab
    192.168.1.100   nginx.seu-dominio-local.lab

Agora que os certificados estão prontos, vamos atualizar os arquivos de configuração.


Como Colocar Tudo Para Rodar

    Prepare os Arquivos:
        Crie a estrutura de diretórios conforme descrito.
        Preencha o arquivo .env com suas informações (domínio, e-mail e senhas seguras).
        Crie o arquivo traefik/acme.json vazio e ajuste suas permissões: chmod 600 traefik/acme.json.
        Popule os outros arquivos (traefik.yml, initdb.sql, index.html) com o conteúdo fornecido.

    Inicie a Stack:
        Navegue até o diretório raiz /docker-stack/ no seu terminal.
        Execute o comando:
        Bash

        docker compose up -d

        Verifique os logs 
        docker compose logs

        Parando o docker compose e zerando

        docker compose down -y

        Apagando os dockers para liberar espaço na máquina

        docker system prune --all 
        

    Configure o Authentik:

        Aguarde alguns minutos para que todos os serviços subam.

        Acesse https://auth.seu-dominio.com. Na primeira vez, você será guiado para criar uma conta de administrador.

        Crie um Provedor (Provider):
            No menu, vá em Applications -> Providers e clique em Create.
            Selecione Proxy Provider.
            Name: Dê um nome, como Traefik Guard.
            Authorization flow: Selecione default-provider-authorization-explicit-consent.
            Mode: forward_auth (single application).
            External host: IMPORTANTE, digite a URL completa do serviço que você quer proteger, por exemplo: https://guacamole.seu-dominio.com.
            Salve.

        Crie uma Aplicação (Application):
            Vá em Applications -> Applications e clique em Create.
            Name: Guacamole.
            Slug: guacamole.
            Provider: Selecione o provedor Traefik Guard que você acabou de criar.
            Salve a aplicação. Por padrão, ela já deve permitir o acesso a todos os usuários logados.

        Para proteger o Dashboard do Traefik e o Nginx, repita o processo: crie um novo Provider para cada um (alterando o campo External host para https://traefik.seu-dominio.com e https://nginx.seu-dominio.com, respectivamente) e, em seguida, crie uma Application para cada um.

Verificação Final

    Tente acessar https://guacamole.seu-dominio.com. Você deve ser redirecionado para a tela de login do Authentik. Após o login, o acesso ao Guacamole será liberado.
    Acesse https://nginx.seu-dominio.com. Você verá a página de exemplo diretamente (ou passará pela autenticação se você ativou o middleware para ele).
    Use o comando docker network inspect nginx-net para confirmar que apenas os contêineres traefik e nginx-server estão nessa rede.

