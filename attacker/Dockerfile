FROM alpine:3.19

RUN apk add --no-cache bash curl nmap hping3 iproute2

WORKDIR /attacks

COPY scripts /attacks/scripts

CMD ["sleep", "infinity"]
