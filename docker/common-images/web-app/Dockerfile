# docker build -t gitlab.vumaex.net:4567/internal/devops/web-app:1.21.6 .
# docker push gitlab.vumaex.net:4567/internal/devops/web-app:1.21.6
# docker run -it --entrypoint /bin/bash gitlab.vumaex.net:4567/internal/devops/web-app:1.21.6
FROM nginx:1.21.6-alpine
LABEL maintainer="Automation Exchange"

COPY config/. /etc/nginx/

EXPOSE 80
