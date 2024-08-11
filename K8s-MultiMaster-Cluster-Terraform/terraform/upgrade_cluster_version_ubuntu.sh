#!/bin/bash

VERSION=1.30.3-00
# Master Node
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.30.3

sudo apt-cache madison kubeadm | tac

sudo apt-mark unhold kubeadm kubectl kubelet

sudo apt-get install -y kubeadm=$VERSION kubectl=$VERSION kubelet=$VERSION

sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Worker Node

sudo apt-mark unhold kubeadm kubectl kubelet

sudo apt-get install -y kubeadm=$VERSION kubectl=$VERSION kubelet=$VERSION

sudo systemctl daemon-reload
sudo systemctl restart kubelet

