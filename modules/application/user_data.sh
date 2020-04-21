#!/usr/bin/env bash

##############
# Install deps
##############

# Apt based distro
if command -v apt-get &>/dev/null; then
  apt-get update
  apt-get install python-pip jq -y

# Yum based distro
elif command -v yum &>/dev/null; then
  yum update -y
  # epel provides python-pip & jq
  yum install -y epel-release
  yum install python-pip jq -y
fi

#####################

pip install --upgrade awscli

##############