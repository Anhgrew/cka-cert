#!/bin/bash
# Generate a token for a service account from a secret
kubectl get secret demo -n demo -o json | jq -r .data.token  | base64 --decode | kubectl view-serviceaccount-kubeconfig > kube-tmp

# List the resources in the demo namespace wiih the token
kubectl get all --kubeconfig kube-tmp -n demo

# Create a token for the service account and save it to a file
kubectl create token demo -n demo | kubectl view-serviceaccount-kubeconfig > kube-token-tmp

# List the resources in the demo namespace with the token
kubectl get all --kubeconfig kube-tmp -n demo
