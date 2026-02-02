FROM alpine:3.19

RUN apk add --no-cache bash

CMD ["sh", "-c", "tail -F /var/log/snort/alert.fast"]
