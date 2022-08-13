#!/usr/bin/env sh

source .env

PRIVATE_KEY=$ANVIL1_PK

forge script script/DeployNFT.s.sol:DeployNFT -vvvv --broadcast \
    --private-key $PRIVATE_KEY \
    --fork-url http://localhost:8545 \
    # --verify --etherscan-api-key $ETHERSCAN_API_KEY

    # --rpc-url $ETHEREUM_URL 