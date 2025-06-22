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
|-- .env                     # Arquivo de variáveis de ambiente
|-- docker-compose.yml       # Nosso arquivo principal
|
|-- traefik/
|   |-- traefik.yml          # Configuração estática do Traefik
|   |-- acme.json            # Arquivo para os certificados SSL (crie vazio)
|
|-- authentik/               # Diretórios para dados persistentes
|   |-- media/
|   |-- templates/
|   |-- geoip/
|
|-- guacamole/
|   |-- data/
|   |-- init/
|   |   |-- initdb.sql       # Script de inicialização do BD do Guacamole
|
|-- nginx/
|   |-- html/
|   |   |-- index.html       # Página de exemplo para o Nginx

======

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

