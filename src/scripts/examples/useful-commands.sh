#!/bin/bash
set +e

# Check setup varibales
# /etc/environment

# Check status
# sudo systemctl status sol

# Get logs
# sudo journalctl -o cat -fu sol

#Check solana is cought up
# sudo ./solana catchup --log /var/solana/data/config/validator-keypair.json http://127.0.0.1:8899
# solana catchup ~/validator-identity.json http://127.0.0.1:8899/

# Check open ports
# sudo lsof -i -P -n | grep LISTEN

# Get logs from initialization scrips (user-data)
# sudo cat /var/log/cloud-init-output.log

# Clean up data

# sudo rm -f /var/solana/data/init-completed
# sudo rm -rf /var/solana/data/ledger/*
# sudo rm -rf /var/solana/accounts/