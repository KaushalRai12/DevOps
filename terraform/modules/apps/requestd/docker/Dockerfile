# docker build -t gitlab.vumaex.net:4567/internal/devops/requestd:1.1.0 .
# docker push gitlab.vumaex.net:4567/internal/devops/requestd:1.1.0
FROM hackerplanet/requestd:v1.1.0
LABEL maintainer="Automation Exchange"

USER app
RUN wget https://files.vivancos.eu/GeoLite2-City.mmdb
