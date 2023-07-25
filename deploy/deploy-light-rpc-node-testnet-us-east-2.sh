#!/bin/bash

BC_REGION="us-east-2"
BC_STACK_NAME="solana-light-rpc-node"
BC_INSTANCE_TYPE="r6a.8xlarge"
#BC_EC2_AMI_ID="ami-0568936c8d2b91c4e" # Ubuntu, 20.04 LTS, amd64 focal image build on 2023-02-07 in us-east-2
#BC_EC2_AMI_ID="ami-0cefaebb6da6ffd7f" # Ubuntu, 20.04 LTS, arm64 focal image build on 2023-02-07 in us-east-2
BC_EC2_AMI_ID="/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id" # amd64 version of Ubuntu, 20.04 LTS image 
#BC_EC2_AMI_ID="/aws/service/canonical/ubuntu/server/20.04/stable/current/arm64/hvm/ebs-gp2/ami-id" # arm64 version of Ubuntu, 20.04 LTS image
BC_DATA_DISC_TYPE="gp3"
BC_CIDR_ALLOWED_ACCESS_RPC="172.16.0.0/12"
BC_ACCOUNTS_DISC_TYPE="gp3"
BC_SOLANA_VERSION="1.16.2" # For mainnet use 1.14.20, for testnet: 1.16.2
BC_SOLANA_NODE_TYPE="lightrpc" # lightrpc, validator, heavyrpc
BC_SOLANA_NODE_IDENTITY_SECRET_ARN="none"
BC_VOTE_ACCOUNT_SECRET_ARN="none"
BC_AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN="none"
BC_REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN="none"
BC_SOLANA_CLUSTER="testnet" # devnet, testnet, mainnet-beta

echo "BC_REGION="$BC_REGION
echo "BC_STACK_NAME="$BC_STACK_NAME
echo "BC_INSTANCE_TYPE="$BC_INSTANCE_TYPE
echo "BC_EC2_AMI_ID="$BC_EC2_AMI_ID
echo "BC_DATA_DISC_TYPE="$BC_DATA_DISC_TYPE
echo "BC_CIDR_ALLOWED_ACCESS_RPC="$BC_CIDR_ALLOWED_ACCESS_RPC
echo "BC_ACCOUNTS_DISC_TYPE="$BC_ACCOUNTS_DISC_TYPE
echo "BC_SOLANA_VERSION="$BC_SOLANA_VERSION
echo "BC_SOLANA_NODE_TYPE="$BC_SOLANA_NODE_TYPE
echo "BC_SOLANA_NODE_IDENTITY_SECRET_ARN="$BC_SOLANA_NODE_IDENTITY_SECRET_ARN
echo "BC_VOTE_ACCOUNT_SECRET_ARN="$BC_VOTE_ACCOUNT_SECRET_ARN
echo "BC_AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN="$BC_AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN
echo "BC_REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN="$BC_REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN
echo "BC_SOLANA_CLUSTER="$BC_SOLANA_CLUSTER
echo
read -p "Do you want to continue [y/N]? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then

aws cloudformation deploy --region $BC_REGION --stack-name $BC_STACK_NAME \
--template-file ../cloudformation/ec2-solana-node-template.yaml \
--parameter-overrides \
InstanceType=$BC_INSTANCE_TYPE \
Ec2AmiId=$BC_EC2_AMI_ID \
DataDiscType=$BC_DATA_DISC_TYPE \
CIDRAllowedAccessRPC=$BC_CIDR_ALLOWED_ACCESS_RPC \
AccountsDiscType=$BC_ACCOUNTS_DISC_TYPE \
SolanaVersion=$BC_SOLANA_VERSION \
SolanaNodeType=$BC_SOLANA_NODE_TYPE \
SolanaNodeIdentitySecretARN=$BC_SOLANA_NODE_IDENTITY_SECRET_ARN \
VoteAccountSecretARN=$BC_VOTE_ACCOUNT_SECRET_ARN \
AuthorizedWithdrawerAccountSecretARN=$BC_AUTHORIZED_WITHDRAWER_ACCOUNT_SECRET_ARN \
RegistrationTransactionFundingAccountSecretARN=$BC_REGISTRATION_TRANSACTION_FUNDING_ACCOUNT_SECRET_ARN \
SolanaCluster=$BC_SOLANA_CLUSTER \
--capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset

fi