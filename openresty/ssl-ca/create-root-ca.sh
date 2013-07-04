#!/bin/bash
# http://pages.cs.wisc.edu/~zmiller/ca-howto/
rm -rf *.crt *.key
openssl genrsa -des3 -out root-ca.key 1024 
echo "Common Name: ROOT CA"
openssl req -new -x509 -days 3650 -key root-ca.key -out root-ca.crt -config openssl.cnf 
rm -rf IRRSigningCA1
perl mk_new_ca_dir.pl IRRSigningCA1
mv root-ca.crt IRRSigningCA1/signing-ca-1.crt
mv root-ca.key IRRSigningCA1/signing-ca-1.key
ls -al IRRSigningCA1/