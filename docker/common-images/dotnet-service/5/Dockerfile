# docker build -t gitlab.vumaex.net:4567/internal/devops/dotnet-service:5.0.302.0 .
# docker push gitlab.vumaex.net:4567/internal/devops/dotnet-service:5.0.302.0
FROM mcr.microsoft.com/dotnet/sdk:5.0.302
LABEL maintainer="Automation Exchange"

# Allows connection to legacy SQL servers by downgrading TLS
RUN sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf

# Copies library shims for use by end-user docker files
RUN mkdir -p /config
COPY config/ /config/

WORKDIR /App

