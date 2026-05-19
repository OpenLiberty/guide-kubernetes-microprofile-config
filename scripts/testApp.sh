#!/bin/bash
set -euxo pipefail
./mvnw -version

##############################################################################
##
##  GH actions CI test script
##
##############################################################################

#../scripts/startMinikube.sh
minikube start
minikube status
#kubectl cluster-info
#kubectl get services --all-namespaces
#kubectl config view
eval "$(minikube docker-env)"

# Test app

./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q package

docker pull -q icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

docker images

kubectl create configmap sys-app-root --from-literal contextRoot=/dev -o yaml --dry-run=none | kubectl apply -f -
kubectl create secret generic sys-app-credentials --from-literal username=alice --from-literal password=wonderland --dry-run=none -o yaml | kubectl apply -f -

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

minikube ip
curl "http://$(minikube ip):31000/health"
curl "http://$(minikube ip):32000/health"

# Debug
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)

kubectl exec $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system) -- env | grep SYSTEM_APP

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)

kubectl get secret sys-app-credentials -o jsonpath='{.data.username}' | base64 -d
kubectl get secret sys-app-credentials -o jsonpath='{.data.password}' | base64 -d

curl -v -u alice:wonderland http://$(minikube ip):31000/dev/system/properties/


./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.context.root=/dev \
    -Dsystem.service.root="$(minikube ip):31000" -Dinventory.service.root="$(minikube ip):32000" \
    failsafe:integration-test
./mvnw -ntp failsafe:verify

kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)"
kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)"

#../scripts/stopMinikube.sh
eval "$(minikube docker-env -u)"
minikube stop
