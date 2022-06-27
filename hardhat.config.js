require("@nomiclabs/hardhat-waffle");
require('dotenv').config({path:__dirname+'/.env'})
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "mumbai",
  networks: {
    goerli: {
      url: process.env.INFURA_GOERLI_URI,
      accounts: [`${process.env.GOERLI_PRIVATE_KEY}`]
    },
    mainnet: {
      url: process.env.INFURA_MAINNET_URI,
      accounts: [`${process.env.MAINNET_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  solidity: {
    version: '0.8.11',
    settings: {
      optimizer: {
        enabled: true,
        runs: 800
      },
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    showTimeSpent: true,
  },
  plugins: ['solidity-coverage']
};
