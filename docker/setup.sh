#!/bin/sh

# set variables for the chain
VALIDATOR_NAME=validator1
CHAIN_ID=gm
KEY_NAME=gm-key
KEY_2_NAME=gm-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000stake"
STAKING_AMOUNT="1000000000stake"

# initialize the validator with the chain ID you set
gmd init $VALIDATOR_NAME --chain-id $CHAIN_ID

# add keys for key 1 and key 2 to keyring-backend test
gmd keys add $KEY_NAME --keyring-backend test
gmd keys add $KEY_2_NAME --keyring-backend test

# add these as genesis accounts
gmd add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
gmd add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test

# set the staking amounts in the genesis transaction
gmd gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test

# collect genesis transactions
gmd collect-gentxs
