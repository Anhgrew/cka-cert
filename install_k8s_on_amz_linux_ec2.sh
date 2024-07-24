#!/bin/bash

# Update the system
sudo yum update -y

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system


# Download and install containerd
CONTAINERD_VERSION="1.7.20"
wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
sudo tar -C /usr/local -xzf containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

# Create containerd service file
cat containerd.service | sudo tee /etc/systemd/system/containerd.service

ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH=amd64 ;;
    aarch64) ARCH=arm64 ;;
    armv7l) ARCH=arm ;;
    *) echo "Unsupported architecture"; exit 1 ;;
esac

# Replace v1.1.13 with the desired version
RUNC_VERSION="v1.1.13"
wget "https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.${ARCH}"

sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Installing CNI plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl enable --now containerd

# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install kubelet, kubeadm, and kubectl
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet


# Master Node
sudo kubeadm init --cri-socket unix:///var/run/containerd/containerd.sock --pod-network-cidr=10.244.0.0/16
# Set up kubectl configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel network plugin
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# After worker node created
kubectl label node <node-name> node-role.kubernetes.io/worker=worker

# Worker Node
sudo kubeadm join 172.31.41.232:6443 --token t997ee.8jkv2j2im296mu0l \
	--discovery-token-ca-cert-hash sha256:42d7d860bf875a4410ab13578776e5af463ccb0ed9b275b3bbcb8a829226bc4b 

# Open connection from external
# On Local
scp -i "anhdrew.pem" ec2-user@47.128.151.18:/home/ec2-user/.kube/config ~/.kube/config

# On Master Node
sudo rm /etc/kubernetes/pki/apiserver.*
sudo kubeadm init phase certs apiserver --apiserver-cert-extra-sans=47.128.151.18
# Update k8s cluster IP for local kube config file

# Open port 6443 for 0.0.0.0/0