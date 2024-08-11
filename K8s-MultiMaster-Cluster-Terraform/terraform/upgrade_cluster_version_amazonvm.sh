#!/bin/bash

# Master Node

VERSION=1.30.3
# Plan the upgrade
sudo kubeadm upgrade plan
# Apply the upgrade to the specific version
sudo kubeadm upgrade apply $VERSION

# List all available versions of kubeadm, sorted in reverse order
yum list --showduplicates kubeadm | tac

# Remove version locks if they exist
sudo yum versionlock delete kubeadm kubectl kubelet

# Install the specific versions of kubeadm, kubectl, and kubelet
sudo yum install -y kubeadm-$VERSION kubectl-$VERSION kubelet-$VERSION

# Reload the systemd configuration and restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Worker Node

# Remove version locks if they exist
sudo yum versionlock delete kubeadm kubectl kubelet

# Install the specific versions of kubeadm, kubectl, and kubelet
sudo yum install -y kubeadm-$VERSION kubectl-$VERSION kubelet-$VERSION

# Reload the systemd configuration and restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
