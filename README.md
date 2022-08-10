## Requirements
- Install node.js [node js website](https://nodejs.org/en/)
- Create An INFURA account [infura website](https://infura.io)
- Create an etherscan account [etherscan website](https://etherscan.io/register)

## Install project
- Open a terminal at project root
- Execute this command:

```bash
npm install
```

## Env settings

- copy .env.default to .env file

########### GENERAL SETTINGS #################

ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY"

TOKENS_URI="https://gateway.pinata.cloud/ipfs/HASH"

########### TEST NET SETTINGS #################

INFURA_TESTNET_URI="https://rinkeby.infura.io/v3/HASH"

TESTNET_PRIVATE_KEY="YOUR_METAMASK_PRIVATE_KEY"

########### MAIN NET SETTINGS #################

INFURA_MAINNET_URI="https://mainnet.infura.io/v3/HASH"

MAINNET_PRIVATE_KEY="YOUR_METAMASK_PRIVATE_KEY"%

## Execute tests
```bash
npx hardhat test   

```

## Deploy
On testnet:
```bash
npx hardhat run --network testnet scripts/deploy.js

```

on mainnet:
```bash
npx hardhat run --network mainnet scripts/deploy.js

```
