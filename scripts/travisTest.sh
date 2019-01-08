#!/bin/bash

##############################################################################
##
##  Travis CI test script
##
##############################################################################

printf "\nmvn -q package\n"
mvn -q package

printf "\nkubectl create configmap greeting-config --from-literal message=Greetings...\n"
kubectl create configmap greeting-config --from-literal message=Greetings...

printf "\nkubectl create secret generic name-credentials --from-literal username=bob --from-literal password=bobpwd\n"
kubectl create secret generic name-credentials --from-literal username=bob --from-literal password=bobpwd

printf "\nkubectl apply -f kubernetes.yaml\n"
kubectl apply -f kubernetes.yaml

printf "\nsleep 120\n"
sleep 120

printf "\nkubectl get pods\n"
kubectl get pods

printf "\minikube ip\n"
echo `minikube ip`

printf "\nmvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dname.message=Greetings...\n"
mvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dname.message=Greetings...

printf "\nkubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep name)\n"
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep name)

printf "\nkubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep ping)\n"
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep ping)
