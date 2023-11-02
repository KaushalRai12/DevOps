# https://hub.docker.com/r/nosinovacao/dotnet-sonar
# docker build -t gitlab.vumaex.net:4567/internal/devops/dotnet-core-sonar:5.0 .
# docker push gitlab.vumaex.net:4567/internal/devops/dotnet-core-sonar:5.0
FROM nosinovacao/dotnet-sonar:21.11.1
LABEL maintainer="Automation Exchange"

RUN dotnet tool install --global dotnet-sonarscanner

ENV SCANNER_VERSION "5.3.2"
ADD config/SonarQube.Analysis.xml /sonar-scanner/

ENV PATH="/root/.dotnet/tools:${PATH}"

RUN mkdir /project
WORKDIR /project

unit 27 terenue estate orange river drive