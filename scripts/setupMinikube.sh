#!/bin/bash

# Set up kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
ln -s -f "$(pwd)/kubectl" "/usr/local/bin/kubectl"

# Install Minikube
wget https://github.com/kubernetes/minikube/releases/download/v1.20.0/minikube-linux-amd64 -q -O minikube
chmod +x minikube
PATH = "$(pwd):$PATH"
export PATH

apt-get update -y
apt-get install -y conntrack

sysctl fs.protected_regular=0

# Start Minikube
minikube start --driver=none --bootstrapper=kubeadm
#eval "$(minikube docker-env)"
