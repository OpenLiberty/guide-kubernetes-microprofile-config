#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  GH actions CI test script
##
##############################################################################

# ../scripts/startMinikube.sh
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# shellcheck source=./scripts/startMinikube.sh
source "$SCRIPTPATH"/startMinikube.sh

# Test app

mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q package

docker pull openliberty/open-liberty:full-java11-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

kubectl create configmap sys-app-root --from-literal contextRoot=/dev -o yaml --dry-run | kubectl apply -f -
kubectl create secret generic sys-app-credentials --from-literal username=alice --from-literal password=wonderland --dry-run -o yaml | 
kubectl apply -f -

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

minikube ip
mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.context.root=/dev \
    -Dsystem.service.root="$(minikube ip):31000" -Dinventory.service.root="$(minikube ip):32000" \
    failsafe:integration-test
mvn failsafe:verify

kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)"
kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)"

# ../scripts/stopMinikube.sh
# shellcheck source=./scripts/stopMinikube.sh
source "$SCRIPTPATH"/stopMinikube.sh
