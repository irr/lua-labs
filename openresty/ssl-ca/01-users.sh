#!/bin/bash
rm -rf irrlab.???
openssl req -newkey rsa:1024 -keyout irrlab.key -config openssl.cnf -out irrlab.req 
openssl ca -config openssl.cnf -out irrlab.crt -infiles irrlab.req
