#!/bin/bash

echo "If volumes are mounted, dont do anything"
if [ $(df --output=target | grep -c "/var/solana/data") -lt 1 ]; then
  echo "Checking fstab"
  if [ $(grep -c "solana" /etc/fstab) -gt 1 ]; then
    echo "Preserving only the first two lines from fstab if needed"
    head -n -2 /etc/fstab > ./fstab.temp & mv ./fstab.temp /etc/fstab
  else
    echo "Editing fstab is not needed, proceeding"
  fi

DATA_DISC_ID=/dev/nvme1n1
  sudo mkfs.xfs -f $DATA_DISC_ID
  sleep 10
  DATA_DISC_UUID=$(lsblk -fn -o UUID  $DATA_DISC_ID)
  DATA_DISC_FSTAB_CONF="UUID=$DATA_DISC_UUID /var/solana/data xfs defaults 0 2"
  echo "DATA_DISC_ID="$DATA_DISC_ID
  echo "DATA_DISC_UUID="$DATA_DISC_UUID
  echo "DATA_DISC_FSTAB_CONF="$DATA_DISC_FSTAB_CONF
  echo $DATA_DISC_FSTAB_CONF | sudo tee -a /etc/fstab

ACCOUNTS_DISC_ID=/dev/nvme2n1
  sudo mkfs.xfs -f $ACCOUNTS_DISC_ID
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
else
  echo "Volumes are mounted, nothing changed"
fi