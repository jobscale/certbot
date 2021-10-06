FROM debian:bullseye-slim
SHELL ["bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y vim git zip unzip curl tree \
 tmux openssh-client iproute2 dnsutils iputils-ping netcat ncat procps \
 certbot
RUN rm -fr /var/lib/apt/lists/*
COPY . .
