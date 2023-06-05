#!/bin/bash
set +e

ASSETS_S3_BUCKET=project-bolt-assets-us-east-2

arch=$(uname -m)
echo "Architecture detected: $arch"

if [ "$arch" == "x86_64" ]; then
  #CW_AGENT_BINARY_URI=https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  SOLANA_BINARY_S3_URI=s3://$ASSETS_S3_BUCKET/solana/bin-x86/v1.13.7/
  # YQ_BINARY_URI=https://github.com/mikefarah/yq/releases/download/v4.30.5/yq_linux_amd64
  #SSM_AGENT_BINARY_URI=https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
else
  #CW_AGENT_BINARY_URI=https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
  SOLANA_BINARY_S3_URI=s3://$ASSETS_S3_BUCKET/solana/bin-arm64/v1.13.7/
  # YQ_BINARY_URI=https://github.com/mikefarah/yq/releases/download/v4.30.5/yq_linux_arm
  #SSM_AGENT_BINARY_URI=https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
fi

#echo "Updating and installing required system packages"
# sudo apt-get -yqq update
# sudo apt-get -yqq install ca-certificates curl gnupg lsb-release aria2 tree awscli jq
#curl https://rclone.org/install.sh | sudo bash
sudo pip3 install --upgrade awscli

#echo 'Installing, configuring and starting CloudWatch Agent'
# wget -q $CW_AGENT_BINARY_URI
# sudo dpkg -i -E amazon-cloudwatch-agent.deb

# sudo aws s3 cp s3://$ASSETS_S3_BUCKET/cw-agent-initial-sync.json /opt/aws/amazon-cloudwatch-agent/etc/custom-amazon-cloudwatch-agent.json

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
# -a fetch-config -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom-amazon-cloudwatch-agent.json -m ec2 -s
#sudo systemctl status amazon-cloudwatch-agent

echo "Fine tune sysctl to prepare the system for Solana"

sudo bash -c "cat >/etc/sysctl.d/20-solana-additionals.conf <<EOF
kernel.hung_task_timeout_secs=600
vm.stat_interval=10
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.dirty_expire_centisecs=36000
vm.dirty_writeback_centisecs=3000
vm.dirtytime_expire_seconds=43200
kernel.timer_migration=0
kernel.pid_max=65536
net.ipv4.tcp_fastopen=3
fs.nr_open = 1000000
EOF"

sudo bash -c "cat >/etc/sysctl.d/20-solana-mmaps.conf <<EOF
# Increase memory mapped files limit
vm.max_map_count = 1000000
EOF"

sudo bash -c "cat >/etc/sysctl.d/20-solana-udp-buffers.conf <<EOF
# Increase UDP buffer size
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728
EOF"

sudo bash -c "echo 'DefaultLimitNOFILE=1000000' >> /etc/systemd/system.conf"

sudo sysctl -p /etc/sysctl.d/20-solana-mmaps.conf
sudo sysctl -p /etc/sysctl.d/20-solana-udp-buffers.conf
sudo sysctl -p /etc/sysctl.d/20-solana-additionals.conf

sudo systemctl daemon-reload

sudo bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"

echo 'Adding solana user and group'
sudo groupadd -g 1002 solana
sudo useradd -u 1002 -g 1002 -m -s /bin/bash solana
sudo usermod -aG sudo solana

echo 'Downloading and installing Solana binaries'
sudo mkdir /home/solana/bin/
sudo aws s3 sync $SOLANA_BINARY_S3_URI /home/solana/bin/

echo 'Preparing directories anf ile system for Solana installation'
sudo mkdir /var/solana
sudo mkdir /var/solana/data
sudo mkdir /var/solana/accounts

cd /home/solana/bin

echo "Removing the last two lines from fstab if needed"
if [ ! -z $(grep "solana" /etc/fstab)]; then 
  head -n -2 /etc/fstab > ./fstab.temp mv ./fstab.temp /etc/fstab
fi

DATA_DISC_ID=/dev/nvme1n1
sudo mkfs -t xfs $DATA_DISC_ID
sleep 10
DATA_DISC_UUID=$(lsblk -fn -o UUID  $DATA_DISC_ID)
DATA_DISC_FSTAB_CONF="UUID=$DATA_DISC_UUID /var/solana/data xfs defaults 0 2"
echo "DATA_DISC_ID="$DATA_DISC_ID
echo "DATA_DISC_UUID="$DATA_DISC_UUID
echo "DATA_DISC_FSTAB_CONF="$DATA_DISC_FSTAB_CONF
echo $DATA_DISC_FSTAB_CONF | sudo tee -a /etc/fstab

ACCOUNTS_DISC_ID=/dev/nvme2n1
sudo mkfs -t xfs $ACCOUNTS_DISC_ID
sleep 10
ACCOUNTS_DISC_UUID=$(lsblk -fn -o UUID $ACCOUNTS_DISC_ID)
ACCOUNTS_DISC_FSTAB_CONF="UUID=$ACCOUNTS_DISC_UUID /var/solana/accounts xfs defaults 0 2"
echo "ACCOUNTS_DISC_ID="$ACCOUNTS_DISC_ID
echo "ACCOUNTS_DISC_UUID="$ACCOUNTS_DISC_UUID
echo "ACCOUNTS_DISC_FSTAB_CONF="$ACCOUNTS_DISC_FSTAB_CONF
echo $ACCOUNTS_DISC_FSTAB_CONF | sudo tee -a /etc/fstab

sudo mount -a
sudo mkdir /var/solana/data/ledger
sudo chown -R solana:solana /var/solana

echo "Preparing Solana start script"

cd /home/solana/bin
sudo bash -c 'cat > validator.sh <<EOF
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
# Remove empty snapshots
find "/var/solana/data/ledger" -name "snapshot-*" -size 0 -print -exec rm {} \; || true
export RUST_LOG=warning
export RUST_BACKTRACE=full
/home/solana/bin/solana-validator \
--ledger /var/solana/data/ledger \
--identity /home/solana/config/validator-keypair.json \
--known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
--known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
--known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
--known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
--expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
--entrypoint entrypoint.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
--entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
--no-voting \
--snapshot-interval-slots 500 \
--maximum-local-snapshot-age 500 \
--full-rpc-api \
--rpc-port 8899 \
--gossip-port 8801 \
--dynamic-port-range 8800-8813 \
--no-port-check \
--wal-recovery-mode skip_any_corrupted_record \
--enable-rpc-transaction-history \
--enable-cpi-and-log-storage \
--init-complete-file /var/solana/data/init-completed \
--snapshot-compression none \
--require-tower \
--no-wait-for-vote-to-start-leader \
--limit-ledger-size 50000000 \
--account-index program-id spl-token-owner \
--accounts-index-memory-limit-mb 10000 \
--account-index-exclude-key kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6 \
--account-index-exclude-key TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA \
--accounts /var/solana/accounts \
--no-os-cpu-stats-reporting \
--no-os-memory-stats-reporting \
--no-os-network-stats-reporting \
--log -
EOF'
sudo chmod +x validator.sh
sudo chmod +x solana
sudo chmod +x solana-validator
sudo chmod +x solana-keygen

echo "Create the node identity"
sudo ./solana-keygen new --no-passphrase -o /home/solana/config/validator-keypair.json

echo "Making sure the solana user has access to everything needed"
sudo chown -R solana:solana /home/solana/

echo "Starting solana as a service"
sudo bash -c 'cat > /etc/systemd/system/sol.service <<EOF
[Unit]
Description=Solana Validator
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=solana
LimitNOFILE=1000000
LogRateLimitIntervalSec=0
Environment="PATH=/bin:/usr/bin:/home/solana/bin"
ExecStart=/home/solana/bin/validator.sh
[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now sol

echo 'Configuring logrotate to rotate Solana logs'

sudo bash -c 'sudo cat > logrotate.sol <<EOF
/home/sol/solana-validator.log {
  rotate 7
  daily
  missingok
  postrotate
    systemctl kill -s USR1 sol.service
  endscript
}
EOF'

sudo cp logrotate.sol /etc/logrotate.d/sol
sudo systemctl restart logrotate.service

echo "Configuring syncchecker script"
sudo aws s3 cp s3://$ASSETS_S3_BUCKET/sync-checker/syncchecker-solana.sh /opt/syncchecker.sh
sudo chmod +x /opt/syncchecker.sh

echo "*/1 * * * * /opt/syncchecker.sh" | crontab
crontab -l

echo "All Done!!"