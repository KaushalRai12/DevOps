# docker build -t gitlab.vumaex.net:4567/internal/devops/devops-server:0.1.20 .
# docker push gitlab.vumaex.net:4567/internal/devops/devops-server:0.1.20
# docker run -it --entrypoint=/bin/sh gitlab.vumaex.net:4567/internal/devops/devops-server:0.1.20
FROM python:3.9.10-slim-bullseye
LABEL maintainer="Automation Exchange"

RUN pip install pip --upgrade
RUN pip install ansible
RUN pip install pywinrm

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sshpass
RUN apt-get install -y openssh-client vim iputils-ping cowsay cron git

# Keepalive - no longer used, since the server runs off crontab.
# Can be used to debug without crontab - but you need to switch the final CMD to run /background/keep_alive.sh instead of run-cron.sh
COPY config/os/keep_alive.sh /background/
RUN chmod +x /background/keep_alive.sh

# Bash functions and aliases
COPY config/os/bashrc /root/.bashrc.d/
RUN echo "for f in ~/.bashrc.d/*; do source \$f; done" >> /root/.bashrc

# SSH configuration
RUN mkdir -p /root/.ssh
COPY config/os/ssh_config /root/.ssh/config

# Configure Ansible
COPY config/ansible /etc/ansible/

# Cron jobs - this server's primatel service is crontab
COPY config/cron/devops-jobs /etc/cron.d/
RUN chmod 0644 /etc/cron.d/devops-jobs
RUN crontab /etc/cron.d/devops-jobs
RUN touch /var/log/cron.log
COPY config/cron/expire-users.sh /root/
RUN chmod 0644 /root/expire-users.sh

# Initialization shell scripts
COPY config/lifecycle/docker-entrypoint.sh /root/
RUN chmod 0777 /root/docker-entrypoint.sh
COPY config/lifecycle/post-start.sh /root/
RUN chmod 0777 /root/post-start.sh

WORKDIR /repos/aws-ansible/plays
CMD /root/docker-entrypoint.sh
