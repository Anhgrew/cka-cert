#!/bin/bash
sudo kubeadm reset -f
# Initialize the first master node
sudo kubeadm init --control-plane-endpoint $1:6443 \
    --upload-certs --cri-socket unix:///var/run/containerd/containerd.sock --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Save join command and certificate key for other master nodes
sudo kubeadm token create --print-join-command >/tmp/join_command.sh
sudo kubeadm init phase upload-certs --upload-certs | tail -n 1 >/tmp/certificate_key.txt
kubectl label node $(hostname) node-role.kubernetes.io/master=master
