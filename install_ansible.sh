#!/bin/bash
apt update
apt-get install ansible -y
apt-get install git -y
git clone https://github.com/eitanbenjam/docker_aws.git
cd docker_aws
ansible-playbook playbook.yaml

