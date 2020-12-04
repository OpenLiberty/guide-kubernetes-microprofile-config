#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  GH actions CI test script
##
##############################################################################

# Set up Minikube

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo ln -s $(pwd)/kubectl /usr/local/bin/kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.28.2/minikube-linux-amd64 -q -O minikube
chmod +x minikube

sudo apt-get update -y
sudo apt-get install -y conntrack

sudo minikube start --vm-driver=none --bootstrapper=kubeadm

# Test app

mvn -q package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

kubectl create configmap sys-app-name --from-literal name=my-system -o yaml --dry-run | kubectl apply -f -
kubectl create secret generic sys-app-credentials --from-literal username=bob --from-literal password=bobpwd --dry-run -o yaml |
    kubectl apply -f -

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

echo $(minikube ip)

mvn -Dcluster.ip=$(minikube ip) -Dsystem.appName=my-system failsafe:integration-test
mvn failsafe:verify

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)
