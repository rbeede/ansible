#!/bin/bash

set -o xtrace

echo You need to  source  this

export HTTPS_PROXY=http://127.0.0.1:8080

export HTTP_PROXY=http://127.0.0.1:8080


openssl x509 -inform der -in ~/Documents/burp-ca.crt -out ~/Documents/burp.pem

export AWS_CA_BUNDLE=~/Documents/burp.pem

export NO_PROXY=169.254.169.254

aws --version

aws configure list-profiles

set +o xtrace