#!/bin/bash -x

# Variables
FIRST_MASTER_IP=$1
SECRET=$2
USER=ec2-user
# Copy the join command from the first master node
scp -o StrictHostKeyChecking=no -i ${SECRET} ec2-user@${FIRST_MASTER_IP}:/tmp/join_command.sh /tmp/join_command.sh
# Execute the join command
sudo kubeadm reset -f
ssh -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@$FIRST_MASTER_IP "kubectl delete node $(hostname) --ignore-not-found"
sudo $(cat /tmp/join_command.sh)
ssh -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@$FIRST_MASTER_IP "kubectl label node $(hostname) node-role.kubernetes.io/worker=worker"
