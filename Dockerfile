FROM ubuntu:22.04

LABEL maintainer="Minicurso SBSEG 2025"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl wget git unzip vim gnupg2 lsb-release software-properties-common \
    python3 python3-pip \
    docker.io docker-compose \
    ansible \
    net-tools iputils-ping \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip && \
    unzip terraform_1.7.5_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.7.5_linux_amd64.zip

RUN useradd -ms /bin/bash devuser
USER devuser
WORKDIR /home/devuser

CMD ["/bin/bash"]
