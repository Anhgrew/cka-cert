#!/bin/bash
KUBECONFIG=~/.kube/config:kubeconfig kubectl config view --flatten > .kube/new_config
