# Setup your kube config for AWS
Follow instructions in [this Confluence document](https://automationexchange.atlassian.net/wiki/spaces/DOC/pages/2087550977/Setting+up+k8s+access+to+AWS)

# Set up a new Node
## Install [Docker](https://docs.docker.com/engine/install/ubuntu/)
**Note**: if this stops at some point, just resume from the next command
```bash
sudo apt-get update
# Install a bunch of tools
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common net-tools
# Add a static route so that docker install does not kick you off the VPN
sudo route add -net 172.17.6.40/30 gw 10.69.11.1 ens160
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
# Setup docker permissions
sudo groupadd docker
sudo usermod -aG docker $USER
```
* Logout and login to allow access to docker commands; test with `docker ps`

## Install [Kubernetes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
**Note**: if this stops at some point, just resume from the next command
```bash
sudo modprobe br_netfilter
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
# Note: ensure you install the same version as other cluster members - example below is v1.20.1
sudo sudo apt-get install kubelet=1.20.1-00 kubeadm=1.20.1-00 kubectl=1.20.1-00
# lock the kubernetes package versions - prevent accidental upgrade
sudo apt-mark hold kubelet kubeadm kubectl
# disable swap
sudo swapoff -a
```
## Register the node with the cluster

### Set up a Virtual IP with keepalived
* **Note:** _{virtual-ip}_ **prod** = 10.69.11.200
* **Note:** verify the interface param, `ens160` works for our Reflex VM's, but may not work for other clusters
* **On each master node:**
```bash
sudo apt install keepalived -y
sudo bash -c 'cat << EOF > /etc/keepalived/keepalived.conf
global_defs {
  notification_email {
    devops@automationexchange.co.za
  }
}

vrrp_instance k8s-vip {
  state BACKUP
  priority 255
  interface ens160
  virtual_router_id 60
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  virtual_ipaddress {
    {virtual-ip}/24
  }
}
EOF'
sudo systemctl enable keepalived
sudo systemctl restart keepalived
```

To test from the first master: `ip -brief address show`

### Join the First Master to the cluster
* **Note:** _{virtual-ip}_ **prod** = 10.69.11.200
* Setup Networking (CNI), use [Canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel) (Calico with Flannel):
```bash
curl https://docs.projectcalico.org/manifests/canal.yaml -O
kubectl apply -f canal.yaml
```
* init the master node
```bash
kubeadm init --pod-network-cidr 10.244.0.0/16 --control-plane-endpoint {virtual ip} --upload-certs
````
* Set up a Docker registry login.
Do this for each namespace for which you will pull images (e.g. _aex-stage_, _aex-devops_, _aex-prod_):
```bash
kubectl create secret docker-registry gitlab-docker-registry --docker-server=gitlab.automationexchange.co.za:4567 --docker-username=service --docker-email=gilbertg@automationexchange.co.za --docker-password={gitlab password for service user} --namespace={namespace}
````

#### For all Masters
* Setup kubectl - every master should be able to run kubectl commands.
*From your home folder:*
```bash
mkdir .kube
sudo cp /etc/kubernetes/admin.conf .kube/config
sudo chown aex:aex .kube/config
```
then test with `kubectl get nodes`
* setup shell auto-completion for [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion)
```bash
kubectl completion bash > kubectl
sudo mv kubectl /etc/bash_completion.d/
sudo chown root:root /etc/bash_completion.d/kubectl
source .bashrc
```

### Join another Master to the cluster

**From an existing master node:**
* Get a join command: `kubeadm token create --print-join-command`
* Get a new certificate key: `sudo kubeadm init phase upload-certs --upload-certs`

**From the new master node:**

**Note:** The master node must have a DNS resolvable hostname (else Kube VIP will fail), if it does not. Use `hostnamectl` to set the hostname, and verify you can ping it.
* Join the master node, run the above output join command, appending the options
  * `--control-plane`
  * `--certificate-key {the cert key from the above upload certs command}`
* Setup the [Kube VIP](https://kube-vip.io/control-plane/) manifest.
**Note:** _{virtual-ip}_ **prod** = 10.69.11.200
```bash
sudo docker run --network host --rm plndr/kube-vip:0.2.1 manifest pod --interface ens160 --vip {virtual ip} --arp --leaderElection | sudo tee /etc/kubernetes/manifests/vip.yaml
```

* Follow **For all Masters** section (above)

### Join a Worker to the cluster
* Setup [NFS](https://www.tecmint.com/install-nfs-server-on-ubuntu/) client.
**Note:** Initially you'll need to setup the NFS server as well, however for the existing clusters it's already done: **prod** = 10.69.11.27  **dev** = 10.69.11.19.
The following instructions are for client only.

**TBI:** not sure it's necessary to mount the `/kubedata` folder on every machine.
It will take up more space, and it still works without the mount. Does it help with redundancy?
```
sudo apt-get install -y nfs-common
sudo mkdir /kubedata
sudo mount {nfs server}:/kubedata /kubedata
```
**From a master node:**
* Get a join command: `kubeadm token create --print-join-command`
it will look something like this:
```bash
kubeadm join 10.69.11.200:6443 --token 9j9y0n.mfwy192jwx46ak6a --discovery-token-ca-cert-hash sha256:c6784a24ceb37d6e16432ea2f76c459c1c6fd006e2dfca9776451767d4117552`
```
**From the worker:**
* Run the join command output from the last statement (you might need to prefix it with `sudo`)

---

# Setting up Users
Replace all _username_ in the below to the required username.

## For users who have been given key files
* Copy the {user}.crt and {user}.key files to your local machine `$HOME/.kube` folder
* copy the files `ca.crt` & `ca-prod.crt` (from the _kubernetes_ folder in this repo) to `$HOME/.kube`
* set the `KUSER` variable:
  * linux: `KUSER={my user name}`
  * windows powershell: `Set-Variable -Name "KUSER" -Value "{my user name}"`
* run the following (for dev cluster)
```bash
kubectl config set-cluster aex-dev --server=https://dev.k8s-rosebank.aex.systems:6443 --certificate-authority=$HOME/.kube/ca.crt
kubectl config set-credentials $KUSER --client-key=$HOME/.kube/$KUSER.key --client-certificate=$HOME/.kube/$KUSER.crt
kubectl config set-context aex-dev --cluster=aex-dev --namespace=aex-devops --user=$KUSER
kubectl config use-context aex-dev
```
* for your prod certs, your user will likely be {user}-prod, run the following script for prod cluster
```bash
kubectl config set-cluster aex-prod --server=https://k8s-rosebank.aex.systems:7443 --certificate-authority=$HOME/.kube/ca-prod.crt
kubectl config set-credentials $KUSER-prod --client-key=$HOME/.kube/$KUSER-prod.key --client-certificate=$HOME/.kube/$KUSER-prod.crt
kubectl config set-context aex-prod --cluster=aex-prod --namespace=aex-devops --user=$KUSER-prod
```

## For administrators who want to create users
To create the `k8s-user` bash function (linux):
* make a bash extensions folder `mkdir -p ~/.bashrc.d`
* create a _functions_ file `vi ~/.bashrc.d/functions`
* copy the function code (below) into the new file, save & close
```bash
function k8s-user {
  KUSER=$1
  openssl req -new -newkey rsa:4096 -nodes -keyout $KUSER.key -out $KUSER.csr -subj "/CN=$KUSER/o=aex"
  cat << EOF > k8s-csr.yml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $KUSER
  namespace: aex-devops
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
    - system:authenticated
  request: $(cat $KUSER.csr | base64 | tr -d '\n')
  usages:
    - client auth
EOF

	kubectl apply -f k8s-csr.yml
	kubectl certificate approve $KUSER
	CERT=$(kubectl get csr/$KUSER -o yaml | sed -n 's/  certificate: \([0-9a-zA-Z=+\/]*\)/\1/p')
	echo $CERT | base64 -d - > $KUSER.crt
	rm k8s-csr.yml
	rm $KUSER.csr
}
```
* edit the bash file `vi ~/.bashrc`
* add the line (if not already there) `for f in ~/.bashrc.d/*; do source $f; done`
* re-initialize the shell `source ~/.bashrc`
* test the function `k8s-user blah` - you should see blah.key and blah.crt

**Note:** You need the base64 utility installed
...then your kube config must be pointing to your target cluster - namespace doesn't matter
Then you can run the function `k8s-user {user}` e.g. `k8s-user tinusg`
---

# Utilities

## Change cluster IP pool
**flannel**: https://serverfault.com/questions/976513/is-it-possible-to-change-cidr-network-flannel-and-kubernetes
**calico**: https://stackoverflow.com/questions/60176343/how-to-make-the-pod-cidr-range-larger-in-kubernetes-cluster-deployed-with-kubead

# Converting a single master cluster to HA
An excellent article: https://blog.scottlowe.org/2019/08/12/converting-kubernetes-to-ha-control-plane/

# Deprecated

## Kube VIP Virtual IP
Manifest, that used be in `/etc/kubernetes/manifests/vip.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: kube-vip
  namespace: kube-system
spec:
  containers:
  - args:
    - start
    env:
    - name: vip_arp
      value: "true"
    - name: vip_interface
      value: ens160
    - name: vip_leaderelection
      value: "true"
    - name: vip_leaseduration
      value: "5"
    - name: vip_renewdeadline
      value: "3"
    - name: vip_retryperiod
      value: "1"
    - name: vip_address
      value: 10.69.11.200
    image: plndr/kube-vip:0.2.1
    imagePullPolicy: Always
    name: kube-vip
    resources: {}
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - SYS_TIME
    volumeMounts:
    - mountPath: /etc/kubernetes/admin.conf
      name: kubeconfig
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/admin.conf
    name: kubeconfig
  - hostPath:
      path: /etc/ssl/certs
    name: ca-certs
status: {}
```
This can be re-generated like:
```bash
sudo mkdir -p /etc/kubernetes/manifests
sudo docker run --network host --rm plndr/kube-vip:0.2.1 manifest pod --interface ens160 --vip {virtual ip} --arp --leaderElection | sudo tee /etc/kubernetes/manifests/vip.yaml
```
