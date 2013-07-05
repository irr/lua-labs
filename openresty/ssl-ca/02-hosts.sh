#!/bin/bash
rm -rf myirrlab.???.???

openssl req -newkey rsa:1024 -keyout myirrlab.com.key -nodes -config openssl.cnf -out myirrlab.com.req 
openssl ca -config openssl-multi.cnf -out myirrlab.com.crt -infiles myirrlab.com.req 

openssl req -newkey rsa:1024 -keyout myirrlab.org.key -nodes -config openssl.cnf -out myirrlab.org.req 
openssl ca -config openssl.cnf -out myirrlab.org.crt -infiles myirrlab.org.req 

openssl req -newkey rsa:1024 -keyout myirrlab.net.key -nodes -config openssl.cnf -out myirrlab.net.req 
openssl ca -config openssl.cnf -out myirrlab.net.crt -infiles myirrlab.net.req 