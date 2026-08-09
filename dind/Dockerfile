FROM ubuntu:22.04

# Let's start with some basic stuff.
COPY entry.sh /entrypoint.sh
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \ 
    && curl -sSL https://get.docker.com/ | sh \
    && chmod +x /entrypoint.sh \
    && mkdir -p /var/lib/docker

VOLUME /var/lib/

ENTRYPOINT ["/entrypoint.sh"]

CMD ["dockerd", "--host=unix:///var/run/docker.sock", "&"]
