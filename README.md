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
- Fill the properties inside this file.

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