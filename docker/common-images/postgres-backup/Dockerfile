# docker build -t gitlab.vumaex.net:4567/internal/devops/postgres-backup:2.2.9 .
# docker push gitlab.vumaex.net:4567/internal/devops/postgres-backup:2.2.9
FROM ubuntu:20.04
LABEL maintainer="Automation Exchange"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get -y install awscli wget tar lsb-release gnupg
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql-client-13

COPY config/backup.sh /
RUN chmod +x /backup.sh

ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=service
ENV AWS_ACCESS_KEY_ID=AKIAR6DEOFNAAJBX2SXJ
ENV AWS_DEFAULT_REGION=af-south-1
ENV S3_BUCKET=db-backups.aex


ENTRYPOINT "/backup.sh"
