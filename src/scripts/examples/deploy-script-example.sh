#!/bin/bash

BC_REGION="us-east-2"
BC_STACK_NAME="sol-r6a8xlarge-ebs-gp3"
BC_INSTANCE_TYPE="r6a.8xlarge"
#BC_EC2_AMI_ID="ami-0568936c8d2b91c4e" # Ubuntu, 20.04 LTS, amd64 focal image build on 2023-02-07
BC_EC2_AMI_ID="ami-0cefaebb6da6ffd7f" # Ubuntu, 20.04 LTS, arm64 focal image build on 2023-02-07
BC_INSTACE_NAME=$BC_STACK_NAME
BC_USER_DATA=$(base64 -i ../../user-data/ubuntu-minimum.sh)
BC_ACCOUNTS_DISC_TYPE="gp3"
BC_DATA_DISC_TYPE="gp3"

echo "BC_REGION="$BC_REGION
echo "BC_STACK_NAME="$BC_STACK_NAME
echo "BC_EC2_AMI_ID="$BC_EC2_AMI_ID
echo "BC_INSTACE_NAME="$BC_INSTACE_NAME
echo "BC_USER_DATA="$BC_USER_DATA
echo "BC_DATA_DISC_TYPE="$BC_DATA_DISC_TYPE
echo "BC_ACCOUNTS_DISC_TYPE="$BC_ACCOUNTS_DISC_TYPE

aws cloudformation deploy --region $BC_REGION --stack-name $BC_STACK_NAME \
--template-file ../../cloudformation/ec2-solana-node-template.yaml \
--parameter-overrides InstanceType=$BC_INSTANCE_TYPE \
Ec2AmiId=$BC_EC2_AMI_ID \
InstanceName=$BC_INSTACE_NAME \
UserData="$BC_USER_DATA" \
DataDiscType=$BC_DATA_DISC_TYPE \
AccountsDiscType=$BC_ACCOUNTS_DISC_TYPE \
--capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset