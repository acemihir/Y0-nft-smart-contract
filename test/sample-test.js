const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe('Y0', async function() {
  // const name = "Y0 NFT";
  // const symbol = "Y0 NFT";

  const tokenInitUri = "https://cool-ipfs/{id}.json"
  
  beforeEach(async function () {
    const Y0 = await ethers.getContractFactory("Y0");

    [owner, account1, account2] = await ethers.getSigners();

    // Populate contract object: deploy with a dummy url.
    contract = await Y0.deploy(tokenInitUri);
    await contract.deployed(); 
  });  

  describe('Basic deployment', async function() {
    it("Should be deployed, and be callable", async function () {
      expect(await contract.isActive()).to.equal(false);
    });
  });

  describe('setTokenUri', async function() {
    it('Should not be callable by anyone other than the owner', async () => {
      try {
        await contract.connect(account1).setTokenUri(1, "test");
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        console.log('err');
        expect(err.toString()).to.include('Ownable: caller is not the owner');  
      }
    })
    it('Should be callable by contract owner and change value of _baseURI properly', async () => {
      const tokenId = 1
      const tokenUri = `http://base.com/${1}`;

      await contract.connect(owner).setTokenUri(tokenId, tokenUri);
      assert.equal(await contract.uri(tokenId), tokenUri)
    })
  });

  describe('setIsActive', async function() {
    it('Should not be callable by anyone other than the owner', async () => {
      try {
        await contract.connect(account1).setIsActive(true)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');  
      }
    })
    it('Should be callable by contract owner and change value of _isActive accordingly', async () => {
      assert.equal(await contract.isActive(), false)
      await contract.connect(owner).setIsActive(true)
      assert.equal(await contract.isActive(), true)
      await contract.connect(owner).setIsActive(false)
      assert.equal(await contract.isActive(), false)
    })
  });

  describe('setMaxMintPerWallet', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setMaxMintPerWallet(5)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value maxMintperWallet', async () => {
      const newMaxMintPerWalletValue = 10;
      await contract.connect(owner).setMaxMintPerWallet(newMaxMintPerWalletValue);
      const modifiedMaxMintPerWalletValue = await contract.maxMintPerWallet();
      if (!modifiedMaxMintPerWalletValue.eq(newMaxMintPerWalletValue)) {
        assert.fail(0, 1, 'Modified supply should be the same as newMaxSupply setted by owner');
      }
    });
  });

  describe('setMaxMintPerTransaction', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setMaxMintPerTransaction(2)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value maxMintPerTransaction', async () => {
      const newMaxMintPerTransactionValue = 5;
      await contract.connect(owner).setMaxMintPerTransaction(newMaxMintPerTransactionValue);
      const modifiedMaxMintPerTransactionValue = await contract.maxMintPerTransaction();
      if (!modifiedMaxMintPerTransactionValue.eq(newMaxMintPerTransactionValue)) {
        assert.fail(0, 1, 'Modified maxMintPerTransaction should be the same as newMaxMintPerTransactionValue setted by owner');
      }
    });
  });

  describe('setNormalPrice', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setNormalPrice(2)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value properly', async () => {
      const newValue = 5;
      await contract.connect(owner).setNormalPrice(newValue);
      const modifiedValue = await contract.normal_car_price();
      if (!modifiedValue.eq(newValue)) {
        assert.fail(0, 1, 'Modified value should be the same as newValue setted by owner');
      }
    });
  });

  describe('setRarePrice', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setRarePrice(2)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value properly', async () => {
      const newValue = 5;
      await contract.connect(owner).setRarePrice(newValue);
      const modifiedValue = await contract.rare_car_price();
      if (!modifiedValue.eq(newValue)) {
        assert.fail(0, 1, 'Modified value should be the same as newValue setted by owner');
      }
    });
  });

  describe('setSuperRarePrice', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setSuperRarePrice(2)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value properly', async () => {
      const newValue = 5;
      await contract.connect(owner).setSuperRarePrice(newValue);
      const modifiedValue = await contract.super_car_price();
      if (!modifiedValue.eq(newValue)) {
        assert.fail(0, 1, 'Modified value should be the same as newValue setted by owner');
      }
    });
  });

  describe('setExtraRarePrice', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setExtraRarePrice(2)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value properly', async () => {
      const newValue = 5;
      await contract.connect(owner).setExtraRarePrice(newValue);
      const modifiedValue = await contract.extra_car_price();
      if (!modifiedValue.eq(newValue)) {
        assert.fail(0, 1, 'Modified value should be the same as newValue setted by owner');
      }
    });
  });

  describe('publicMint', async function() {
    it('Should return an error if contract is not active', async () => {
      // Disable mint
      await contract.connect(owner).setIsActive(false)
      try {
        await contract.connect(account1).publicMint(account1.address,1 , 1)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Mint is not active');  
      }
    });
    it('Should return an error if _num >= maxMintPerTransaction', async () => {
      await contract.connect(owner).setIsActive(true)
      const maxMintPerTransaction = await contract.maxMintPerTransaction();
      const overflowMintNumber = maxMintPerTransaction + 1;
      try {
        await contract.connect(account1).publicMint(account1.address, overflowMintNumber, 1)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('_num should be < maxMintPerWallet');  
      }
    });
    it('Should return an error if _to wallet contains more nfts than authorized maxMintPerWallet', async () => {
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      await contract.connect(owner).setMaxMintPerWallet(0)
      try {
        await contract.connect(account2).publicMint(account1.address,1 , 1)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('maxMintPerWallet has been reached for this wallet');  
      }
    });
    it('Should return an error if we mint more than supply for a certain type', async () => {
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      // Get max Supply for type 4
      const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
      const overflowSupply = maxSupply4 + 1;
      // Set maxMintPerTransaction to maxSupply
      await contract.connect(owner).setMaxMintPerTransaction(overflowSupply);
      // Set max MintPerWallet 
      await contract.connect(owner).setMaxMintPerWallet(overflowSupply)
      try {
        await contract.connect(account1).publicMint(account1.address,overflowSupply , 4)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Exceeded total supply');  
      }
    });
    it('Should return an error if we mint more than supply for a certain type', async () => {
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      // Get max Supply for type 4
      const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
      const overflowSupply = maxSupply4 + 1;
      // Set maxMintPerTransaction to maxSupply
      await contract.connect(owner).setMaxMintPerTransaction(overflowSupply);
      // Set max MintPerWallet 
      await contract.connect(owner).setMaxMintPerWallet(overflowSupply)
      try {
        await contract.connect(account1).publicMint(account1.address,overflowSupply , 4)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Exceeded total supply');  
      }
    });
    it('Should mint if every thing is ok', async () => {
      const tokenId = 1;
      // Enable mint
      await contract.connect(owner).setIsActive(true);

      const mintPrice1 = await contract.normal_car_price();
      await contract.connect(account1).publicMint(account1.address, tokenId, 1, {
        value: mintPrice1
      });
      const balanceOfAccount1 = await contract.balanceOf(account1.address, tokenId);
      expect(balanceOfAccount1).to.equal(1);
    });  
  });

  describe('mintByOwner', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).mintByOwner(account1.address,1 , 4)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should return an error if we mint more than supply for a certain type', async () => {
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      // Get max Supply for type 4
      const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
      const overflowSupply = maxSupply4 + 1;
      // Set maxMintPerTransaction to maxSupply
      await contract.connect(owner).setMaxMintPerTransaction(overflowSupply);
      // Set max MintPerWallet 
      await contract.connect(owner).setMaxMintPerWallet(overflowSupply)
      try {
        await contract.connect(owner).mintByOwner(account1.address,overflowSupply , 4)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Exceeded total supply');  
      }
    });
    it('Should return an error if we mint more than supply for a certain type', async () => {
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      // Get max Supply for type 4
      const maxSupply4 = await contract.MAX_SUPPLY_EXTRA();
      const overflowSupply = maxSupply4 + 1;
      // Set maxMintPerTransaction to maxSupply
      await contract.connect(owner).setMaxMintPerTransaction(overflowSupply);
      // Set max MintPerWallet 
      await contract.connect(owner).setMaxMintPerWallet(overflowSupply)
      try {
        await contract.connect(owner).mintByOwner(account1.address,overflowSupply , 4)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Exceeded total supply');  
      }
    });
    it('Should mint if every thing is ok', async () => {
      const tokenId = 1;
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      await contract.connect(owner).mintByOwner(account1.address, tokenId, 1)
      const balanceOfAccount1 = await contract.balanceOf(account1.address, tokenId);
      expect(balanceOfAccount1).to.equal(1);
    });  
  });

  describe('withdraw', async function() {
    it('Should return an error if contract is not called by an owner', async () => {
      try {
        await contract.connect(account1).withdraw(account2.address, account1.address)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');  
      }
    });
    it('Should withdraw properly', async () => {
      const tokenId = 1;

      // Enable mint
      await contract.connect(owner).setIsActive(true)

      // Mint
      const mintPrice1 = await contract.normal_car_price();
      await contract.connect(account1).publicMint(account1.address, tokenId, 1, {
        value: mintPrice1
      });

      // Get all balances before
      const contractBalanceBefore = await contract.provider.getBalance(contract.address);
      const balanceWalletAccount1Before = await ethers.provider.getBalance(account1.address);
      const balanceWalletAccount2Before = await ethers.provider.getBalance(account2.address);

      // Execute withdraw
      await contract.connect(owner).withdraw(account1.address, account2.address, {gasLimit: 500000})

      // Get all balances after
      const contractBalanceAfter = await contract.provider.getBalance(contract.address);
      const balanceWalletAccount1After = await ethers.provider.getBalance(account1.address);
      const balanceWalletAccount2After = await ethers.provider.getBalance(account2.address);
      
      
      // Console prices
      console.log("log-contractBalanceBefore", contractBalanceBefore)
      console.log("log-contractBalanceAfter", contractBalanceAfter)

      console.log("log-balanceWalletAccount1Before", balanceWalletAccount1Before)
      console.log("log-balanceWalletAccount1After", balanceWalletAccount1After)

      console.log("log-balanceWalletAccount2Before", balanceWalletAccount2Before)
      console.log("log-balanceWalletAccount2After", balanceWalletAccount2After)

      expect(contractBalanceBefore.eq(contractBalanceAfter)).to.equal(false);
      expect(balanceWalletAccount1After.gt(balanceWalletAccount1Before)).to.equal(true);
      expect(balanceWalletAccount2After.gt(balanceWalletAccount2Before)).to.equal(true);
      expect(balanceWalletAccount2After.gt(balanceWalletAccount1After)).to.equal(true);

      // Ratio calculus wallet 1
      const proportionFromBalanceToWallet1 = contractBalanceBefore.mul(95).div(100);
      const diffWallet1 = balanceWalletAccount1After.sub(balanceWalletAccount1Before);
      console.log("log-proportionFromBalanceToWallet1", proportionFromBalanceToWallet1)
      console.log("log-diffWallet1", diffWallet1)

      expect(proportionFromBalanceToWallet1.eq(diffWallet1)).to.equal(true);

      // Ratio calculus wallet 2
      const proportionFromBalanceToWallet2 = contractBalanceBefore.mul(5).div(100);
      const diffWallet2 = balanceWalletAccount2After.sub(balanceWalletAccount2Before);
      console.log("log-proportionFromBalanceToWallet2", proportionFromBalanceToWallet2)
      console.log("log-diffWallet2", diffWallet2)
      
      expect(proportionFromBalanceToWallet2.eq(diffWallet2)).to.equal(true);

      expect(contractBalanceAfter.eq(0)).to.equal(true);
    });
  });  
});
