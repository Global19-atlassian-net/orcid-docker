#!/bin/sh

ORCID_HOSTNAME="localhost"
ORCID_PORT="8443"
ORCID_SOURCE="${HOME}/git/ORCID-Source"
RELEASE_TAG="master"

if [ $# -lt 1 ];then
    echo "Usage:\n\t$0 release-number\ne.g.\n\t$0 release-1.2.345\n"
    exit 1
fi

RELEASE_TAG="$1"

cd "${ORCID_SOURCE}/"
git fetch -t
git checkout "$RELEASE_TAG"

echo "https://${ORCID_HOSTNAME}:${ORCID_PORT}/orcid-web/static" > ${ORCID_SOURCE}/orcid-web/src/main/resources/cdn_active_url.txt

cd "${ORCID_SOURCE}/orcid-nodejs"
mvn -P ci -Dnodejs.workingDirectory=${ORCID_SOURCE}/orcid-web/src/main/webapp/static/javascript/ng1Orcid clean compile package

cd "${ORCID_SOURCE}/"
mvn clean install -Dmaven.test.skip=true -Dlicense.skip=true

cp -v "${ORCID_SOURCE}/orcid-web/target/orcid-web.war" "${HOME}/git/orcid-docker/tomcat/webapps/"
