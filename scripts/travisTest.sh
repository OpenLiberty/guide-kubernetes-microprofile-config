#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q package

docker pull open-liberty

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

kubectl create configmap sys-app-name --from-literal name=my-system
kubectl create secret generic sys-app-credentials --from-literal username=bob --from-literal password=bobpwd

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

echo `minikube ip`

mvn failsafe:integration-test -Dcluster.ip=`minikube ip` -Dsystem.appName=my-system
mvn failsafe:verify

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)
