# docker build -t gitlab.vumaex.net:4567/internal/devops/ruby-service-psql:2.7.2.11 .
# docker push gitlab.vumaex.net:4567/internal/devops/ruby-service-psql:2.7.2.11
FROM ruby:2.7.2-alpine3.17
LABEL maintainer="Automation Exchange"

RUN apk add --no-cache \
	build-base \
	nodejs \
	postgresql-dev \
	tzdata \
  && rm -rf /var/cache/apk/* \
	&& gem install bundler
