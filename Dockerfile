FROM debian:buster-slim
SHELL ["bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y vim git zip unzip curl \
 tmux openssh-client net-tools dnsutils iputils-ping netcat ncat procps \
 certbot
COPY . .
RUN rm -fr /var/lib/apt/lists/*
