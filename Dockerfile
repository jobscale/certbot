FROM debian:buster-slim
SHELL ["bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y vim git zip unzip curl tree \
 tmux openssh-client iproute2 dnsutils iputils-ping netcat ncat procps \
 certbot
RUN rm -fr /var/lib/apt/lists/*
RUN git clone https://github.com/jobscale/getssl.git && mv getssl/.git . && rm -fr getssl && git checkout .
RUN ./getssl -c jsx.jp || echo -n \
 && sed -i -s 's/#VALIDATE_VIA_DNS="true"/VALIDATE_VIA_DNS="true"/' .getssl/getssl.cfg \
 && sed -i -s 's/#DNS_ADD_COMMAND=/DNS_ADD_COMMAND=dns_scripts\/dns_add_clouddns/' .getssl/getssl.cfg \
 && sed -i -s 's/#DNS_DEL_COMMAND=/DNS_DEL_COMMAND=dns_scripts\/dns_del_clouddns/' .getssl/getssl.cfg
# RUN ./getssl jsx.jp
COPY certbot .
