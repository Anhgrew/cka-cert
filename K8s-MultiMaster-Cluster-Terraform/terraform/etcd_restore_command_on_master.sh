#!/bin/bash
BACKUP_NAME=$1
export ETCDCTL_API=3

BACKUP_DIR="etcd-backup"

mkdir k8s-manifests

sudo rm -rf /var/lib/etcd/member
# Restore command
sudo etcdutl snapshot restore ${BACKUP_DIR}/${BACKUP_NAME} --data-dir /var/lib/etcd

sudo mv /etc/kubernetes/manifests/* ./k8s-manifests
sudo mv ./k8s-manifests/* /etc/kubernetes/manifests

echo "Restore completed successfully"
