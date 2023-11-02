FROM alpine/k8s:1.21.5
LABEL maintainer="Automation Exchange"

RUN mkdir -p /play/config
WORKDIR /play
COPY config /play/config

RUN chmod -R 600 /play/config

ENV KUBECONFIG=/play/config/k8s/config.yaml
ENV AWS_CONFIG_FILE=/play/config/aws/config

ENTRYPOINT []
