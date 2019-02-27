#!/bin/bash

key="$1"
WORKDIR=$PWD
CADIR=$WORKDIR/files/ssl
mkdir -p $CADIR

case $key in
    rootca)
    cd $CADIR && cfssl gencert -initca ${WORKDIR}/localfiles/ca-csr.json | cfssljson -bare ca -
    exit $?
    ;;
    *)
    cd $CADIR && echo '{"CN":"$key","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=$CADIR/ca.pem -ca-key=$CADIR/ca-key.pem -config=${WORKDIR}/localfiles/ca-config.json -profile=$key -hostname="$2" - | cfssljson -bare $3
    exit $?
    ;;
esac

exit 1
