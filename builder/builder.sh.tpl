#!/bin/bash

sudo apt update -y \
&& sudo apt install -y docker.io awscli git \
&& git clone "http://gitlab.6ax.su/6ax/compose-App42PaaS-Java-MySQL-Sample.git" /tmp/${SOFT_NAME} \
&& cd /tmp/${SOFT_NAME} \
&& sudo docker build . -t ${REPO_URL} \
&& sudo aws ecr get-login-password --region  ${REGION} | sudo docker login --username AWS --password-stdin ${REPO_URL} \
&& sudo docker push ${REPO_URL}
