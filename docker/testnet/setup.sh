#!/bin/sh

VALIDATOR_NAME=validator1
CHAIN_ID=gm
KEY_NAME=gm-key
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000stake"
STAKING_AMOUNT="1000000000stake"

ignite chain build
gmd tendermint unsafe-reset-all
gmd init $VALIDATOR_NAME --chain-id $CHAIN_ID

gmd keys add $KEY_NAME --keyring-backend test
gmd add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
gmd gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test
gmd collect-gentxs
