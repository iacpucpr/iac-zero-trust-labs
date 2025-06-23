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
Claro\! Com base em toda a nossa configuração, aqui está a árvore de diretórios final e recomendada para o seu projeto. Esta estrutura organiza os arquivos de configuração, os dados persistentes e os scripts de inicialização de forma lógica e limpa.

```
/meu-projeto-sso/
├── docker-compose.yml          # O coração da sua infraestrutura, define todos os serviços.
├── .env                        # Arquivo para TODOS os seus segredos e senhas.
│
├── authentik/                  # Diretório para dados e customizações do Authentik.
│   ├── geoip/                  # Para dados de geolocalização de IP.
│   ├── media/                  # Para ícones de aplicativos, logos, etc.
│   └── templates/              # Para customização de e-mails e páginas.
│
├── guacamole/                  # Diretório para configurações e extensões do Guacamole.
│   └── extensions/             # Onde ficam os plugins de autenticação.
│       └── guacamole-auth-oidc-1.5.5.jar
│
├── postgres/                   # Diretório para scripts de inicialização do PostgreSQL.
│   └── init/
│       └── init-guacamole-db.sh  # Script que cria o usuário e DB do Guacamole.
│
└── traefik/                    # Diretório para configurações do Traefik.
    ├── certs/                  # Onde os certificados (autoassinados ou Let's Encrypt) ficam.
    └── dynamic.yml             # Arquivo de configuração dinâmica do Traefik (TLS, etc).
```

### Legenda e Finalidade de Cada Diretório

  * **`/meu-projeto-sso/` (Raiz)**

      * É aqui que você executa os comandos `docker-compose`.
      * **`docker-compose.yml`**: Define todos os contêineres (Traefik, Authentik, Guacamole, Postgres, Redis), suas redes, volumes e configurações.
      * **`.env`**: Centraliza todas as informações sensíveis (senhas, chaves de API, segredos de OIDC), mantendo seu `docker-compose.yml` limpo e seguro.

  * **`authentik/`**

      * Contém dados que o Authentik precisa que persistam. Ao separar esses dados, você pode atualizar a imagem do Authentik sem perder suas customizações, mídias ou configurações.

  * **`guacamole/`**

      * **`extensions/`**: O ponto mais importante aqui. É o local onde você coloca as extensões (`.jar`) que adicionam funcionalidades ao Guacamole, como a autenticação OIDC que permite a integração com o Authentik.

  * **`postgres/`**

      * **`init/`**: O contêiner oficial do PostgreSQL executa automaticamente qualquer script `.sh` ou `.sql` que esteja nesta pasta na primeira vez que ele é iniciado. Usamos isso para criar de forma automatizada o usuário e o banco de dados secundário para o Guacamole, sem precisar de intervenção manual.

  * **`traefik/`**

      * **`certs/`**: O Traefik precisa de um local para armazenar os certificados TLS que ele usa para prover HTTPS aos seus serviços.
      * **`dynamic.yml`**: Usado para configurações que o Traefik pode recarregar sem precisar ser reiniciado. É ideal para definir provedores de TLS e outras configurações dinâmicas.

Manter esta estrutura organizada facilita a manutenção, o backup (essencialmente, você só precisa fazer backup desta pasta inteira) e a compreensão de como os diferentes componentes do seu sistema interagem.

     
Ajustes de permissões
        chmod +x ./guacamole/init/initdb.sh
        sudo chmod -R 755 ./traefik/certs
        sudo chown -R 1000:1000 ./authentik/

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

       Ajuste seu arquivo hosts local:
    Para que seu navegador consiga acessar os serviços usando os nomes de domínio (ex: guacamole.seu-dominio-local.lab), você precisa dizer ao seu sistema operacional para onde ele deve apontar.

        Encontre o IP do seu servidor Docker. Se estiver rodando localmente, será 127.0.0.1. Se for outra máquina na sua rede, use o IP dela.

        Edite o arquivo hosts:

        sudo vim /etc/hosts 
        
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
        docker compose down -v

        Apagando os dockers para liberar espaço na máquina
        docker system prune --all 
        

    Configure o Authentik:

        Aguarde alguns minutos para que todos os serviços subam.

        Acesse https://auth.seu-dominio/if/flow/initial-setup/   Na primeira vez, você será guiado para criar uma conta de administrador. O usuario padrao é akadmin mas voce pode criar mais um.

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

