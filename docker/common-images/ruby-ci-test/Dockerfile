# docker build -t gitlab.vumaex.net:4567/internal/devops/ruby-ci-test:2.7.1.2 .
# docker push gitlab.vumaex.net:4567/internal/devops/ruby-ci-test:2.7.1.2
FROM ruby:2.7.1-alpine3.11
LABEL maintainer="Automation Exchange"

RUN apk add --update \
	bind-tools \
	build-base \
	curl \
	freetds freetds-dev \
	git \
	openssh openssh-client openssl openssl-dev \
	ruby-dev \
	sqlite sqlite-dev sqlite-libs \
	unixodbc unixodbc-dev \
	file-dev \
	libc6-compat libssl1.1 libressl-dev \
	cyrus-sasl-dev \
	tzdata \
	nodejs \
	postgresql-dev \
	imagemagick-dev \
	zbar

RUN rm -rf /var/cache/apk/*
RUN gem install nexus
