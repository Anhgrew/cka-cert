
# Certified Kubernetes Administrator (CKA) Prep and Practice

## Kubernetes Setup Script

This script automates the setup of a Kubernetes cluster on a Linux system using `yum`. It performs the following tasks:

1. **System Updates & Configuration:**
   - Updates the system.
   - Configures network settings for Kubernetes.

2. **Install Containerd:**
   - Downloads and installs Containerd and its service file.
   - Configures and starts Containerd.

3. **Install Required Components:**
   - Downloads and installs `runc`, CNI plugins, and Kubernetes packages (`kubelet`, `kubeadm`, `kubectl`).

4. **Kubernetes Initialization:**
   - Initializes the Kubernetes master node with `kubeadm`.
   - Configures `kubectl` for cluster access.
   - Installs the Flannel network plugin.
   - Joins worker nodes to the cluster.

5. **Configuration Adjustments:**
   - Sets SELinux to permissive mode.
   - Disables swap.
   - Updates the Kubernetes repository.
   - Updates Kubernetes API server certificates and configures external access.

6. **Post-Setup:**
   - Opens port 6443 for external connections.
   - Provides instructions for syncing kubeconfig and updating cluster IP settings.

**Usage:**
Run this script as a root user or with `sudo` on each node of your Kubernetes cluster to set up both master and worker nodes.
