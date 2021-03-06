#!/usr/bin/env bash
set -e

VERSION_FILE="./node_modules/bio-user-platform/package.json"
VERSION=$(cat ./auth-version.txt)

MODULETMPDIR="/tmp/bio-user-platform/npm"

correct_cwd () {
    if [ ! -f "package.json" ]
    then
        echo "current working directory error: are you in the genome-designer root directory?"
        exit 1
    fi
    PROJECT=$(grep '"name":' package.json | tr -d ' ' | tr -d ',' | tr -d '"' | cut -f 2 -d :)
    if [ "$PROJECT" != "genetic-constructor" ]
    then
        echo "unexpected project name: $PROJECT"
        exit 1
    fi
}

install_platform () {
    if [ -f "$VERSION_FILE" ]
    then
        CURRENT_VERSION=$(grep '"version":' ${VERSION_FILE} | tr -d ' ' | tr -d ',' | tr -d '"' | cut -f 2 -d :)
        if [ "$CURRENT_VERSION" == "$VERSION" ]
        then
            return 0
        fi
    fi
    mkdir -p ${MODULETMPDIR}
    aws s3 cp s3://bionano-devops-build-artifacts/bio-user-platform/npm/bio-user-platform-${VERSION}.tgz ${MODULETMPDIR}/
    npm install ${MODULETMPDIR}/bio-user-platform-${VERSION}.tgz
}

correct_cwd
install_platform

TARGET="npm start"
if [ "$COMMAND" != "" ]
then
    TARGET=${COMMAND}
fi

echo "executing $TARGET with authentication enabled..."
BIO_NANO_AUTH=1 ${TARGET}
