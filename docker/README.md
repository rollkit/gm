# Introduction

This folder contains files for setting up and running a rollup on the Celestia network using the GM blockchain.

## Files

This folder contains the following files:

- `setup.sh`: A script that initializes the validator and sets the staking amounts in the genesis transaction.
- `entrypoint.sh`: A script that creates a random Namespace ID for your rollup and queries the DA Layer start height before starting the rollup.
- `Dockerfile`: A Dockerfile for building the rollup image.
- `docker-compose.yaml`: A docker-compose file for running the rollup and Celestia nodes.
- `testnet.docker-compose.yaml`: A docker-compose file for running the rollup and Celestia nodes on a testnet.

## Setup

Before using the files in this folder, you must install Docker and Docker Compose on your machine.

To set up the rollup, follow these steps:

1. Clone the repository to your local machine.
2. Navigate to the directory `docker` containing the files.

## Usage

To use the rollup, follow these steps:

1. Navigate to the directory containing the files.
2. Run `docker-compose up` to start the rollup and Celestia nodes.
3. The rollup should now be accessible at `localhost:26657`.

> If you have issues with the rollup, you can run `docker-compose down` to stop the rollup and Celestia nodes and then run `docker-compose up` again to restart the rollup.

## Testnet Usage

To use the rollup on the testnet, follow these steps:

1. Navigate to the directory containing the files.
2. Create the key folder and assign the correct permissions to have a stable address:
    - `mkdir -p ./data/celestia-keys`
    - `sudo chown 10001:1001 ./data/celestia-keys`
3. Run `docker-compose -f testnet.docker-compose.yaml up` to start the rollup and Celestia nodes on the testnet.
4. The rollup should now be accessible at `localhost:26657`.

> If you have issues with the rollup, you can run `docker-compose -f testnet.docker-compose.yaml down` to stop the rollup and Celestia nodes and then run `docker-compose -f testnet.docker-compose.yaml up` again to restart the rollup.

## Support

If you have any questions or issues with the files in this repository, please open an issue on GitHub.
