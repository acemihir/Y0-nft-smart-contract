require('dotenv').config({ path: __dirname + '/.env' });
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat');

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	// await hre.run('compile');

	// We get the contract to deploy
	console.log("Ready to deploy contract");
	const Y0 = await hre.ethers.getContractFactory('Y0');
	console.log('Ready to deploy on : ', process.env.TOKENS_URI);
	const y0 = await Y0.deploy(process.env.TOKENS_URI);

	console.log('Deploying ....');
	await y0.deployed();

	console.log('Contract deployed to:', y0.address);

	// Verification process of smart contracts on Etherscan
	await y0.deployTransaction.wait(5);
	await run('verify:verify', {
		address: y0.address,
		constructorArguments: [process.env.TOKENS_URI],
	});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
