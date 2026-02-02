FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends snort \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/snort /var/log/snort

CMD ["snort", "-i", "eth0", "-c", "/etc/snort/snort.conf", "-l", "/var/log/snort", "-A", "fast", "-k", "none"]
