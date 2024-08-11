#!/bin/bash
# kubectl -n kube-system get pod kube-apiserver-ip-172-31-41-32.ap-southeast-1.compute.internal  -o=jsonpath='{.spec.containers[0].command}' |jq |grep etcd

# sudo cp -r /etc/kubernetes/pki/ /home/ec2-user/certs
# sudo chown -R $USER:$USER /home/ec2-user/certs/
# scp -r -i anhdrew.pem ec2-user@13.229.88.245:/home/ec2-user/certs ./terraform/backup/certs

# export ETCDCTL_CACERT=./terraform/backup/certs/ca.crt
# export ETCDCTL_CERT=./terraform/backup/certs/server.crt
# export ETCDCTL_KEY=./terraform/backup/certs/server.key
export ETCDCTL_API=3

BACKUP_DIR="etcd-backup"

CERT_DIR="/etc/kubernetes/pki/etcd"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Backup command
sudo etcdctl snapshot save --endpoints=https://127.0.0.1:2379 ${BACKUP_DIR}/etcd-backup-$(date +%Y-%m-%d_%H-%M-%S).db \
  --cacert=${CERT_DIR}/ca.crt \
  --cert=${CERT_DIR}/server.crt \
  --key=${CERT_DIR}/server.key

# Verify backup
sudo etcdutl --write-out=table snapshot status ${BACKUP_DIR}/etcd-backup-$(date +%Y-%m-%d_%H-%M-%S).db

echo "Backup completed successfully"
