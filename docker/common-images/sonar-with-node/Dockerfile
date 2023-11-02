# docker build -t gitlab.vumaex.net:4567/internal/devops/sonar-with-node:4.7.0 .
# docker push gitlab.vumaex.net:4567/internal/devops/sonar-with-node:4.7.0
# escape=`
FROM node:14
LABEL maintainer="Automation Exchange"

ARG SONAR_VERSION=4.7.0.2747-linux

RUN apt-get update && apt-get install unzip wget
RUN mkdir /downloads -p && wget -O /downloads/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VERSION.zip
RUN unzip -q /downloads/sonar-scanner.zip -d /downloads
RUN mv /downloads/sonar-scanner-$SONAR_VERSION /opt/sonar-scanner

# None of this works!!!  giving up for now
RUN sed -i 's/export PATH/export PATH="\/opt\/sonar-scanner\/bin:\$PATH"/g' /etc/profile
RUN echo 'export PATH="/opt/sonar-scanner/bin:$PATH"' >> ~/.bashrc

RUN echo '#!/bin/bash' >> ~/scan.sh && \
    echo '/opt/sonar-scanner/bin/sonar-scanner -Dsonar.qualitygate.wait=true' >> ~/scan.sh
RUN chmod +x ~/scan.sh
