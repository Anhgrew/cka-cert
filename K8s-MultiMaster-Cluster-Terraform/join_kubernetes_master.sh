#!/bin/bash -x

# Variables
FIRST_MASTER_IP=$1
SECRET=$2
USER=ec2-user
# Copy the join command and certificate key from the first master node
scp -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@${FIRST_MASTER_IP}:/tmp/join_command.sh /tmp/join_command.sh
scp -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@${FIRST_MASTER_IP}:/tmp/certificate_key.txt /tmp/certificate_key.txt

# Execute the join command with control-plane and certificate key options
sudo kubeadm reset -f
ssh -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@$FIRST_MASTER_IP "kubectl delete node $(hostname) --ignore-not-found"
sudo bash /tmp/join_command.sh --control-plane --certificate-key $(cat /tmp/certificate_key.txt)

ssh -o StrictHostKeyChecking=no -i ${SECRET} ${USER}@$FIRST_MASTER_IP "kubectl label node $(hostname) node-role.kubernetes.io/master=master"
