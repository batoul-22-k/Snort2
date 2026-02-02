FROM python:3.11-alpine

WORKDIR /srv

COPY index.html /srv/index.html

EXPOSE 8080

CMD ["python", "-m", "http.server", "8080"]
