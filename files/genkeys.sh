#!/bin/sh

set -e

CACERT=$1
KEY=$2
CERT=$3
PASS=$4
TMPCERT=`mktemp cert.XXXXXXX`
TMPKS=`mktemp cert.XXXXXXX`

cd /etc/activemq

keytool -import -alias "My CA" -file $1 \
  -keystore truststore.jks -noprompt -storepass $4

cat $2 $3 > $TMPCERT

openssl pkcs12 -export -in $TMPCERT -out $TMPKS -name activemq -password pass:$4

rm $TMPCERT

keytool -importkeystore  -destkeystore keystore.jks -srckeystore $TMPKS -srcstoretype PKCS12 -alias activemq -srcstorepass $4 -deststorepass $4

rm $TMPKS
