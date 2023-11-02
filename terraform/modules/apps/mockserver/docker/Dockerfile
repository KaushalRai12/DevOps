# docker build -t gitlab.vumaex.net:4567/internal/devops/mock-server:1.0.14 .
# docker push gitlab.vumaex.net:4567/internal/devops/mock-server:1.0.14
FROM mockserver/mockserver:latest
LABEL maintainer="Automation Exchange"

WORKDIR /app

COPY ./config /config
