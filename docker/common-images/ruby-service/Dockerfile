# docker build -t gitlab.vumaex.net:4567/internal/devops/ruby-service:2.7.2 .
# docker push gitlab.vumaex.net:4567/internal/devops/ruby-service:2.7.2
FROM ruby:2.7.1-alpine3.11
LABEL maintainer="Automation Exchange"

RUN apk add --update \
  bind-tools build-base freetds freetds-dev tzdata git

RUN rm -rf /var/cache/apk/*
RUN gem install bundler
