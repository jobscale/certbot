FROM node:lts-bullseye-slim
SHELL ["bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl git vim unzip tree \
 tmux openssh-client iproute2 dnsutils iputils-ping netcat ncat procps \
 bc certbot
RUN rm -fr /var/lib/apt/lists/*
COPY . .
