# Recommended configurations for running Solana nodes on AWS

| Usage pattern  | Ideal configuration  | Primary option on AWS  | Experimental option on AWS  |  Data Transfer Estimates | Setup instructions | Comments |
|---|---|---|---|---|---|---|
| 1/ Just validator | 32 vCPU, 256 GB RAM, Accounts volume: 1TB, 5K IOPS, 700 MB/s throughput, Data volume: 3TB, 10K IOPS, 700 MB/s throughput   | r6a.8xlarge, Accounts volume: EBS gp3 1TB, 5K IOPS, 700 MB/s throughput, Data volume: EBS gp3 10K IOPS, 700 MB/s throughput | r7g.8xlarge (ARM 64)  | Proportional to the amount at stake (source?). Between 200TB to 300TB/month  | TBA |   |
| 2/ Light RPC node (no secondary indexes) | 32 vCPU, 256 GB RAM, Accounts volume: 1TB, 5K IOPS, 700 MB/s throughput, Data volume: 3TB, 12K IOPS, 700 MB/s throughput   | r6a.8xlarge, Accounts volume: EBS gp3 1TB, 5K IOPS, 700 MB/s throughput Data volume: EBS gp3 12K IOPS, 700 MB/s throughput | r7g.8xlarge (ARM 64)  | 80TB/month (no staking) | TBA |   |
| 3/ Full RPC node (with all secondary indexes) | 128 vCPU, 1 TB RAM, Accounts volume: 1TB, 7K IOPS, 700 MB/s throughput, Data volume: 3TB, 16K IOPS, 700 MB/s throughput    | Under testing | i4i.32xlarge, 2x instance storage (ethemeral NVMe voumes) 3.8 TB each | 160TB/month (no staking) | TBA | Needs more testing  |
| 4/ Full RPC node with Gayser plugin | Node: same as 2/ Light RPC node, Database: 32 vCPU, 256 GB RAM, Data volume: 4TB, 16K IOPS, 1000 MB/s throughput | Node: same as 2/ Light RPC node, Database: RDS for PostgreSQL db.r6g.8xlarge + 3.8TB EBS gp3 16K IOPS and 1000 MB/s throughput  |  N/A | 160TB/month (no staking) | TBA  |   |
