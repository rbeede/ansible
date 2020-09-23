#!/bin/bash

set -o xtrace

echo You need to  source  this

# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-proxy.html
# Must be upper-case names
export HTTPS_PROXY=http://127.0.0.1:8080
export HTTP_PROXY=$HTTPS_PROXY


export AWS_CA_BUNDLE=~/Documents/burp-ca.pem

export NO_PROXY=169.254.169.254

aws --version

aws configure list-profiles
