#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

kubectl create configmap sys-app-name --from-literal name=my-system -o yaml --dry-run | kubectl replace -f 
kubectl create secret generic sys-app-credentials --from-literal username=bob --from-literal password=bobpwd

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

echo `minikube ip`

mvn -Dcluster.ip=`minikube ip` -Dsystem.appName=my-system failsafe:integration-test
mvn failsafe:verify

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)
