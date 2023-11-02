# Copy SSH key
cp /root/tmp/id_rsa /root/.ssh/ && chmod -R 600 /root/.ssh
# Clone ansible repo
mkdir -p /repos && cd /repos && rm -rf aws-ansible
git clone git@gitlab.vumaex.net:shared/aws-ansible.git && cd aws-ansible && git checkout master
ansible-galaxy install -r /repos/aws-ansible/plays/roles/requirements.yml
