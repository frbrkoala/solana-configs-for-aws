#!/bin/bash

sudo source /etc/environment

if [[ "$DATA_DISC_TYPE" == "instancestore" ]]; then
  echo "Data disc type is instance store"
  export DATA_DISC_ID=/dev/nvme1n1
fi

if [[ "$ACCOUNTS_DISC_TYPE" == "instancestore" ]]; then
  echo "Accounts disc type is instance store"
  if [[ "$DATA_DISC_TYPE" == "instancestore" ]]; then
    export ACCOUNTS_DISC_ID=/dev/nvme2n1
  else
    export ACCOUNTS_DISC_ID=/dev/nvme1n1
  fi
fi

if [ -n "$DATA_DISC_ID" ]; then
  echo "If Data volume is mounted, dont do anything"
  if [ $(df --output=target | grep -c "/var/solana/data") -lt 1 ]; then
    echo "Checking fstab for Data volume"

    sudo mkfs.xfs -f $DATA_DISC_ID
    sleep 10
    DATA_DISC_UUID=$(lsblk -fn -o UUID  $DATA_DISC_ID)
    DATA_DISC_FSTAB_CONF="UUID=$DATA_DISC_UUID /var/solana/data xfs defaults 0 2"
    echo "DATA_DISC_ID="$DATA_DISC_ID
    echo "DATA_DISC_UUID="$DATA_DISC_UUID
    echo "DATA_DISC_FSTAB_CONF="$DATA_DISC_FSTAB_CONF

    # Check if data disc is already in fstab and replace the line if it is with the new disc UUID
    if [ $(grep -c "data" /etc/fstab) -gt 0 ]; then
      SED_REPLACEMENT_STRING="$(grep -n "/var/solana/data" /etc/fstab | cut -d: -f1)s#.*#$DATA_DISC_FSTAB_CONF#"
      sudo cp /etc/fstab /etc/fstab.bak
      sudo sed -i "$SED_REPLACEMENT_STRING" /etc/fstab
    else
      echo $DATA_DISC_FSTAB_CONF | sudo tee -a /etc/fstab
    fi

    sudo mount -a

    sudo mkdir /var/solana/data/ledger
    sudo chown -R solana:solana /var/solana
  else
    echo "Data volume is mounted, nothing changed"
  fi
fi

if [ -n "$ACCOUNTS_DISC_ID" ]; then
  echo "If Accounts volume is mounted, dont do anything"
  if [ $(df --output=target | grep -c "/var/solana/accounts") -lt 1 ]; then
    echo "Checking fstab for Accounts volume"

    sudo mkfs.xfs -f $ACCOUNTS_DISC_ID
    sleep 10
    ACCOUNTS_DISC_UUID=$(lsblk -fn -o UUID $ACCOUNTS_DISC_ID)
    ACCOUNTS_DISC_FSTAB_CONF="UUID=$ACCOUNTS_DISC_UUID /var/solana/accounts xfs defaults 0 2"
    echo "ACCOUNTS_DISC_ID="$ACCOUNTS_DISC_ID
    echo "ACCOUNTS_DISC_UUID="$ACCOUNTS_DISC_UUID
    echo "ACCOUNTS_DISC_FSTAB_CONF="$ACCOUNTS_DISC_FSTAB_CONF

    # Check if accounts disc is already in fstab and replace the line if it is with the new disc UUID
    if [ $(grep -c "/var/solana/accounts" /etc/fstab) -gt 0 ]; then
      SED_REPLACEMENT_STRING="$(grep -n "/var/solana/accounts" /etc/fstab | cut -d: -f1)s#.*#$ACCOUNTS_DISC_FSTAB_CONF#"
      sudo cp /etc/fstab /etc/fstab.bak
      sudo sed -i "$SED_REPLACEMENT_STRING" /etc/fstab
    else
      echo $ACCOUNTS_DISC_FSTAB_CONF | sudo tee -a /etc/fstab
    fi

    sudo mount -a

    sudo chown -R solana:solana /var/solana
  else
    echo "Accounts volume is mounted, nothing changed"
  fi
fi