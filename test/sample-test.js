const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

describe('Y0', async function() {
  const name = "Y0 NFT";
  const symbol = "Y0 NFT";
  
  beforeEach(async function () {
    const Y0 = await ethers.getContractFactory("Y0");  
    [owner, account1, account2] = await ethers.getSigners();

    // Populate contract object
    contract = await Y0.deploy();
    await contract.deployed(); 
    
    // Retrieve basic informations
    maxSupply = await contract.maxSupply();
  });  

  describe('Base deployement', async function() {
    it("Should be deployed with correct data", async function () {
      expect(await contract.name()).to.equal(name);
      expect(await contract.symbol()).to.equal(symbol);
      expect(await contract.maxSupply()).to.equal(maxSupply);
    });
  });

  describe('setURIs', async function() {
    it('Should not be callable by not contract owner', async () => {
      try {
        await contract.connect(account1).setBaseURI('');
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');  
      }
    })
    it('Should be callable by contract owner and change value of _baseURI and  accordingly', async () => {
      const baseURI = 'http://base.com/';

      await contract.connect(owner).setBaseURI(baseURI);
      assert.equal(await contract.baseURI(), baseURI)
    })
  });

  describe('setIsActive', async function() {
    it('Should not be callable by not contract owner', async () => {
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

  describe('setRevealNFT', async function() {
    it('Should be rejected if not called by owner', async () => {
      try {
        await contract.connect(account1).setRevealNFT(true)
      } catch (err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');
      }
    });
    it('Should change value revealNFT', async () => {
      await contract.connect(owner).setRevealNFT(true);
      let revealNFT = await contract.revealNFT();
      if (!revealNFT) {
        assert.fail(0, 1, 'Modified supply should be the same as newMaxSupply setted by owner');
      }
      await contract.connect(owner).setRevealNFT(false);
      revealNFT = await contract.revealNFT();
      if (revealNFT) {
        assert.fail(0, 1, 'Modified supply should be the same as newMaxSupply setted by owner');
      }
    });   
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
      const maxSupply4 = await contract.MINT_CAP_EXTRA();
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
      const maxSupply4 = await contract.MINT_CAP_EXTRA();
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
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      // Get max Supply for type 4
      const mintPrice1 = await contract.normal_car_price();
      await contract.connect(account1).publicMint(account1.address, 1 , 1, {
        value: mintPrice1
      })
      const balanceOfAccount1 = await contract.balanceOf(account1.address);
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
      const maxSupply4 = await contract.MINT_CAP_EXTRA();
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
      const maxSupply4 = await contract.MINT_CAP_EXTRA();
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
      // Enable mint
      await contract.connect(owner).setIsActive(true)
      await contract.connect(owner).mintByOwner(account1.address, 1 , 1)
      const balanceOfAccount1 = await contract.balanceOf(account1.address);
      expect(balanceOfAccount1).to.equal(1);
    });  
  });

  describe('withdraw', async function() {
    it('Should return an error if contract is not called by an owner', async () => {
      try {
        await contract.connect(account1).withdraw(account2.address)
        assert.fail(0, 1, 'Exception not thrown');
      } catch(err) {
        expect(err.toString()).to.include('Ownable: caller is not the owner');  
      }
    });
  });  
});
