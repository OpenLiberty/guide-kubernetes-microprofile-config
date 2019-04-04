#!/bin/bash

set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q package

kubectl create configmap greeting-config --from-literal message=Greetings...

kubectl create secret generic name-credentials --from-literal username=bob --from-literal password=bobpwd

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

echo `minikube ip`

mvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dname.message=Greetings...

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep name)

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep ping)
