#!/bin/bash
set +e

sudo bash -c 'echo "CF_STACK_NAME=${CF_STACK_NAME}" >> /etc/environment'
sudo bash -c 'echo "DISC_TYPE=${DISC_TYPE}" >> /etc/environment'
sudo bash -c 'echo "SOLANA_VERSION=${SOLANA_VERSION}" >> /etc/environment'
sudo bash -c 'echo "SOLANA_NODE_TYPE=${SOLANA_NODE_TYPE}" >> /etc/environment'
sudo bash -c 'echo "NODE_IDENTITY_SECRET_ARN=${NODE_IDENTITY_SECRET_ARN}" >> /etc/environment'
sudo bash -c 'echo "VOTE_ACCOUNT_SECRET_ARN=${VOTE_ACCOUNT_SECRET_ARN}" >> /etc/environment'
sudo bash -c 'echo "AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN=${AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN}" >> /etc/environment'
sudo bash -c 'echo "REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN=${REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN}" >> /etc/environment'
sudo source /etc/environment

sudo apt-get -yqq update
sudo apt-get -yqq install awscli jq

cd ~
wget -q https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/src/scripts/user-data/node-user-data.sh
sudo cp ./node-user-data.sh /opt/user-data.sh

sudo chmod +x /opt/user-data.sh
sudo /opt/user-data.sh