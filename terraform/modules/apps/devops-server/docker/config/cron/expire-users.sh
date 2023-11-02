#!/bin/bash
. /root/.bashrc
export PATH=$PATH:/usr/local/bin
ansible-playbook /repos/aws-ansible/plays/expire-users.yml
