#!/bin/bash
while getopts t:d: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    *) echo "Invalid option";;
    esac
done

echo "Testing latest OpenLiberty Docker image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/""$DATE""/""$DRIVER""</runtimeUrl></install></configuration>" inventory/pom.xml system/pom.xml
cat inventory/pom.xml system/pom.xml

sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java11-openj9-ubi;g" inventory/Dockerfile system/Dockerfile
sed -i "s;RUN features.sh;#RUN features.sh;g" inventory/Dockerfile system/Dockerfile
cat inventory/Dockerfile system/Dockerfile

echo "$DOCKER_PASSWORD" | sudo -u runner docker login -u "$DOCKER_USERNAME" --password-stdin cp.stg.icr.io
sudo -u runner docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java11-openj9-ubi"
sudo -u runner echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" cp.stg.icr.io/cp/olc/open-liberty-daily:full-java11-openj9-ubi

sudo -u runner ../scripts/testApp.sh
