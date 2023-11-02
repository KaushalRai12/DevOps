# docker build -t gitlab.vumaex.net:4567/internal/devops/postgres-with-config:0.1.3 .
# docker push gitlab.vumaex.net:4567/internal/devops/postgres-with-config:0.1.3
FROM postgres:13.3-alpine3.14
LABEL maintainer="Automation Exchange"

COPY alter_pg_hba.sh /docker-entrypoint-initdb.d/
RUN chmod -R +x /docker-entrypoint-initdb.d/

CMD ["postgres", "-c", "wal_level=logical"]
