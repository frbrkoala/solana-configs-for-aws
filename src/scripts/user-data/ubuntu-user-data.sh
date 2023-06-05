#!/bin/bash
set +e

export SOLANA_VERSION="1.14.17"
export DISC_TYPE= #"io2","gp3","none"

sudo apt-get -yqq update

wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E amazon-cloudwatch-agent.deb

wget -q https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/src/configs/cloudwatch-agent-config.json
cp ./cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/custom-amazon-cloudwatch-agent.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom-amazon-cloudwatch-agent.json -m ec2 -s
sudo systemctl status amazon-cloudwatch-agent

wget -q https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/src/scripts/user-data/node-user-data-ebs.sh
sudo aws s3 cp s3://$ASSETS_S3_BUCKET/solana/solana-user-data.sh /opt/user-data.sh

sudo chmod +x /opt/user-data.sh
sudo /opt/user-data.sh