# docker build -t gitlab.vumaex.net:4567/internal/devops/dotnet-docs:5.0 .
# docker push gitlab.vumaex.net:4567/internal/devops/dotnet-docs:5.0
FROM mcr.microsoft.com/dotnet/sdk:5.0.302
LABEL maintainer="Automation Exchange"

RUN apt-get update && apt-get install -y doxygen graphviz
