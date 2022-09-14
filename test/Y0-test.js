const { expect, assert } = require('chai');
const { ethers } = require('hardhat');

describe('Y0', async function () {
	// const name = "Y0 NFT";
	// const symbol = "Y0 NFT";

	// const tokenInitUri = 'https://cool-ipfs/';
	const tokenInitUri = 'https://gateway.pinata.cloud/ipfs/QmVbB6mqQz7E81qaJHnXrPZHQmkShFw7zLoTufdFgUF57/';

	beforeEach(async function () {
		const Y0 = await ethers.getContractFactory('Y0');

		[owner, account1, account2] = await ethers.getSigners();

		// Populate contract object: deploy with a dummy url.
		contract = await Y0.deploy(tokenInitUri);
		await contract.deployed();
	});

	describe('Basic deployment', async function () {
		it('Should be deployed, and be callable', async function () {
			expect(await contract.isPaused()).to.equal(false);
		});
	});

	describe('setIsActive', async function () {
		it('Should not be callable by anyone other than the owner', async () => {
			try {
				await contract.connect(account1).setIsActive(true);
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include('Ownable: caller is not the owner');
			}
		});
		it('Should be callable by contract owner and change value of _isActive accordingly', async () => {
			assert.equal(await contract.isPaused(), false);
			await contract.connect(owner).setIsActive(true);
			assert.equal(await contract.isPaused(), true);
			await contract.connect(owner).setIsActive(false);
			assert.equal(await contract.isPaused(), false);
		});
	});

	describe('claimTo', async function () {
		it('Should return an error if contract is not active', async () => {
			// Disable mint
			await contract.connect(owner).setIsActive(false);
			try {
				await contract.connect(account1).claimTo(account1.address, 1, 1);
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include('Mint is not active');
			}
		});
		// it('Should return an error if _num >= MAX_MINT_PER_TX', async () => {
		// 	await contract.connect(owner).setIsActive(true);
		// 	const MAX_MINT_PER_TX = await contract.MAX_MINT_PER_TX();
		// 	const overflowMintNumber = MAX_MINT_PER_TX.add(
		// 		ethers.BigNumber.from('1')
		// 	);
		// 	try {
		// 		await contract
		// 			.connect(account1)
		// 			.claimTo(account1.address, overflowMintNumber, 1);
		// 		assert.fail(0, 1, 'Exception not thrown');
		// 	} catch (err) {
		// 		expect(err.toString()).to.include(
		// 			'Number of mint cannot be less than 1 and more than maximal number of mint per transaction'
		// 		);
		// 	}
		// });
		it('Should return an error if we mint more than supply for a certain type', async () => {
			// Enable mint
			await contract.connect(owner).setIsActive(true);
			// Get max Supply for type 4
			const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
			const mintPrice4 = await contract.EXTRA_CAR_PRICE();
			const overflowSupply = maxSupply4 + 1;
			try {
				let i = 0;
				while (i < overflowSupply) {
					await contract.connect(account1).claimTo(account1.address, 1, 4, {
						value: mintPrice4,
					});
					i++;
				}
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include(
					'Exceeded total supply of extra cars'
				);
			}
		});
		it('Should return an error if we mint with not enough ETH', async () => {
			// Enable mint
			await contract.connect(owner).setIsActive(true);
			const mintPrice4 = await contract.EXTRA_CAR_PRICE();
			try {
				await contract.connect(account1).claimTo(account1.address, 1, 4, {
					value: mintPrice4 - 1,
				});
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include(
					'Ether Value sent is not the right amount'
				);
			}
		});
		// it('Should return an error if we mint with 0 amount', async () => {
		// 	// Enable mint
		// 	await contract.connect(owner).setIsActive(true);
		// 	const mintPrice4 = await contract.EXTRA_CAR_PRICE();
		// 	try {
		// 		await contract.connect(account1).claimTo(account1.address, 0, 4);
		// 		assert.fail(0, 1, 'Exception not thrown');
		// 	} catch (err) {
		// 		expect(err.toString()).to.include(
		// 			'Number of mint cannot be less than 1 and more than maximal number of mint per transaction'
		// 		);
		// 	}
		// });
		// it('Should return an error if we mint more than max mint per transaction', async () => {
		// 	// Enable mint
		// 	await contract.connect(owner).setIsActive(true);
		// 	try {
		// 		await contract.connect(account1).claimTo(account1.address, 2, 4);
		// 		assert.fail(0, 1, 'Exception not thrown');
		// 	} catch (err) {
		// 		expect(err.toString()).to.include(
		// 			'Number of mint cannot be less than 1 and more than maximal number of mint per transaction'
		// 		);
		// 	}
		// });
		it('Should mint if every thing is ok', async () => {
			const _num = 1;
			// Enable mint
			await contract.connect(owner).setIsActive(true);

			const mintPrice1 = await contract.NORMAL_CAR_PRICE();
			await contract.connect(account1).claimTo(account1.address, _num, 1, {
				value: mintPrice1,
			});
			const balanceOfAccount1 = await contract.balanceOf(
				account1.address,
			);
			expect(balanceOfAccount1).to.equal(1);
		});
	});

	describe('mintByOwner', async function () {
		it('Should be rejected if not called by owner', async () => {
			try {
				await contract.connect(account1).mintByOwner(account1.address, 1, 4);
			} catch (err) {
				expect(err.toString()).to.include('Ownable: caller is not the owner');
			}
		});
		it('Should return an error if we mint more than supply for a certain type', async () => {
			// Enable mint
			await contract.connect(owner).setIsActive(true);
			// Get max Supply for type 4
			const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
			const overflowSupply = maxSupply4 + 1;

			try {
				await contract
					.connect(owner)
					.mintByOwner(account1.address, overflowSupply, 4);
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include(
					'Exceeded total supply of extra cars'
				);
			}
		});
		it('Should return an error if we mint -1 amount of token', async () => {
			// Enable mint
			await contract.connect(owner).setIsActive(true);
			const prevSupply = await contract.extraCarSupply();

			try {
				await contract.connect(owner).mintByOwner(account1.address, -1, 4);
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include('value out-of-bounds');
			}
			expect(await contract.extraCarSupply()).to.be.equal(prevSupply);
		});
		it('Should mint if every thing is ok', async () => {
			const _num = 1;
			// Enable mint
			await contract.connect(owner).setIsActive(true);
			await contract.connect(owner).mintByOwner(account1.address, _num, 1);
			const balanceOfAccount1 = await contract.balanceOf(
				account1.address,
			);
			expect(balanceOfAccount1).to.equal(1);
		});
	});

	describe('withdraw', async function () {
		it('Should return an error if contract is not called by a team member (shares)', async () => {
			try {
				await contract.connect(owner).withdraw();
				assert.fail(0, 1, 'Exception not thrown');
			} catch (err) {
				expect(err.toString()).to.include('Only Team can withdraw');
			}
		});
		it('Should withdraw properly', async () => {
			const tokenId = 1;

			// Enable mint
			await contract.connect(owner).setIsActive(true);

			// Mint
			const mintPrice1 = await contract.NORMAL_CAR_PRICE();
			await contract.connect(account1).claimTo(account1.address, tokenId, 1, {
				value: mintPrice1,
			});

			// Get all balances before
			const contractBalanceBefore = await contract.provider.getBalance(
				contract.address
			);
			const balanceWalletAccount1Before = await ethers.provider.getBalance(
				account1.address
			);
			const balanceWalletAccount2Before = await ethers.provider.getBalance(
				account2.address
			);

			// Execute withdraw
			await contract.connect(account1).withdraw({ gasLimit: 500000 });

			// Get all balances after
			const contractBalanceAfter = await contract.provider.getBalance(
				contract.address
			);
			const balanceWalletAccount1After = await ethers.provider.getBalance(
				account1.address
			);
			const balanceWalletAccount2After = await ethers.provider.getBalance(
				account2.address
			);

			// Console prices
			console.log('log-contractBalanceBefore', contractBalanceBefore);
			console.log('log-contractBalanceAfter', contractBalanceAfter);

			console.log(
				'log-balanceWalletAccount1Before',
				balanceWalletAccount1Before
			);
			console.log('log-balanceWalletAccount1After', balanceWalletAccount1After);

			console.log(
				'log-balanceWalletAccount2Before',
				balanceWalletAccount2Before
			);
			console.log('log-balanceWalletAccount2After', balanceWalletAccount2After);

			expect(contractBalanceBefore.eq(contractBalanceAfter)).to.equal(false);
			expect(
				balanceWalletAccount1After.gt(balanceWalletAccount1Before)
			).to.equal(true);
			// expect(
			// 	balanceWalletAccount2After.gt(balanceWalletAccount2Before)
			// ).to.equal(true);
			expect(balanceWalletAccount2After).to.equal(balanceWalletAccount2Before);
			expect(
				balanceWalletAccount2After.gt(balanceWalletAccount1After)
			).to.equal(true);

			// Ratio calculus wallet 1
			const proportionFromBalanceToWallet1 = contractBalanceBefore
				.mul(95)
				.div(100);
			const diffWallet1 = balanceWalletAccount1After.sub(
				balanceWalletAccount1Before
			);
			console.log(
				'log-proportionFromBalanceToWallet1',
				proportionFromBalanceToWallet1
			);
			console.log('log-diffWallet1', diffWallet1);

			expect(proportionFromBalanceToWallet1.gt(diffWallet1)).to.equal(true);

			// Ratio calculus wallet 2
			const proportionFromBalanceToWallet2 = contractBalanceBefore
				.mul(5)
				.div(100);
			const diffWallet2 = balanceWalletAccount2After.sub(
				balanceWalletAccount2Before
			);
			console.log(
				'log-proportionFromBalanceToWallet2',
				proportionFromBalanceToWallet2
			);
			console.log('log-diffWallet2', diffWallet2);

			// expect(proportionFromBalanceToWallet2.eq(diffWallet2)).to.equal(true);

			expect(contractBalanceAfter.eq(0)).to.equal(true);
		});
	});
});
