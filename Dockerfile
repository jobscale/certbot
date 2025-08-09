FROM node:lts-bookworm-slim
SHELL ["bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl git vim zip unzip tree tmux \
  openssh-client iproute2 dnsutils iputils-ping ncat netcat-openbsd \
  procps bc certbot \
 && apt-get clean && rm -fr /var/lib/apt/lists/*

COPY package.json .
RUN npm i --dev=omit
COPY app app
COPY ddns-hook-auth.sh .
COPY ddns-hook-cleanup.sh .
COPY certonly .
COPY simple .
