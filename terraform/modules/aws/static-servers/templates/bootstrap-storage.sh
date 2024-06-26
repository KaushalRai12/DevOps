#!/bin/bash
sudo mkdir /fno-storage
sudo apt install -y nfs-common
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_fqn}:/ /fno-storage
sudo chown ubuntu:ubuntu /fno-storage
