# Recommended configurations for running Solana nodes on AWS

| Usage pattern  | Ideal configuration  | Primary option on AWS  | Data Transfer Estimates | Run on AWS |
|---|---|---|---|---|
| 1/ Just validator | 32 vCPU, 256 GB RAM, Accounts volume: 1TB, 5K IOPS, 700 MB/s throughput, Data volume: 3TB, 10K IOPS, 700 MB/s throughput   | r6a.8xlarge, Accounts volume: EBS gp3 1TB, 5K IOPS, 700 MB/s throughput, Data volume: EBS gp3 10K IOPS, 700 MB/s throughput | Proportional to the amount at stake. Between 200TB to 400TB/month  | 1/ [Manually create a new secret in AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create_secret.html)  to store a key pair for pre-funded account to pay for validator registration transaction. 2/ [Click to deploy in us-east-2 (Ohio)](https://us-east-2.console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/create/review&templateURL=https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/cloudformation/ec2-solana-node-template.yaml&stackName=solana-validator-node&InstanceType=r6a.8xlarge&Ec2AmiId=ami-0568936c8d2b91c4e&DataDiscType=gp3&AccountsDiscType=gp3&SolanaVersion=1.14.17&SolanaNodeIdentitySecretARN=none&SolanaNodeType=validator) |
| 2/ Light RPC node (no secondary indexes) | 32 vCPU, 256 GB RAM, Accounts volume: 1TB, 5K IOPS, 700 MB/s throughput, Data volume: 3TB, 12K IOPS, 700 MB/s throughput   | r6a.8xlarge, Accounts volume: EBS gp3 1TB, 5K IOPS, 700 MB/s throughput Data volume: EBS gp3 12K IOPS, 700 MB/s throughput | 150-200TB/month (no staking) | [Click to deploy in us-east-2 (Ohio)](https://us-east-2.console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/create/review&templateURL=https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/cloudformation/ec2-solana-node-template.yaml&stackName=solana-light-rpc-node&InstanceType=r6a.8xlarge&Ec2AmiId=ami-0568936c8d2b91c4e&DataDiscType=gp3&AccountsDiscType=gp3&SolanaVersion=1.14.17&SolanaNodeIdentitySecretARN=none&SolanaNodeType=lightrpc) |
| 3/ Full RPC node (with all secondary indexes) | 128 vCPU, 1 TB RAM, Accounts volume: 1TB, 7K IOPS, 700 MB/s throughput, Data volume: 3TB, 16K IOPS, 700 MB/s throughput    | Under testing: i4i.16xlarge, 2x instance storage (ethemeral NVMe voumes) 3.8 TB each | 150-200TB/month (no staking) | [Click to deploy in us-east-2 (Ohio)](https://us-east-2.console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/create/review&templateURL=https://raw.githubusercontent.com/frbrkoala/solana-configs-for-aws/main/cloudformation/ec2-solana-node-template.yaml&stackName=solana-heavy-rpc-node&InstanceType=i4i.16xlarge&Ec2AmiId=ami-0568936c8d2b91c4e&DataDiscType=none&AccountsDiscType=none&SolanaVersion=1.14.17&SolanaNodeIdentitySecretARN=none&SolanaNodeType=heavyrpc) |
| 4/ Full RPC node with Gayser plugin | Node: same as 2/ Light RPC node, Database: 32 vCPU, 256 GB RAM, Data volume: 4TB, 16K IOPS, 1000 MB/s throughput | Node: same as 2/ Light RPC node, Database: RDS for PostgreSQL db.r6g.8xlarge + 3.8TB EBS gp3 16K IOPS and 1000 MB/s throughput | 150-200TB/month (no staking) | TBA  |
