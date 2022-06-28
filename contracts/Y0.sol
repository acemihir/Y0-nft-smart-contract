//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Y0 is ERC1155, Ownable {
  using SafeMath for uint256;

  // ==============================================
  // Properties
  // ==============================================
  uint256 public normal_car_count = 0;
  uint256 public rare_car_count = 0;
  uint256 public super_car_count = 0;
  uint256 public extra_car_count = 0;

  uint256 public normal_car_price = 11 ether;
  uint256 public rare_car_price = 22 ether;
  uint256 public super_car_price = 33 ether;
  uint256 public extra_car_price = 44 ether; 

  uint256 public MAX_SUPPLY_NORMAL = 1600; 
  uint256 public MAX_SUPPLY_RARE = 400; 
  uint256 public MAX_SUPPLY_SUPER = 200; 
  uint256 public MAX_SUPPLY_EXTRA = 22; 
  
  bool public isActive = false;

  uint256 public maxSupply;
  uint256 public maxMintPerWallet = 3;
  uint256 public maxMintPerTransaction = 1;

  mapping (uint256 => string) private _uris;

  constructor(string memory _tokenUri) ERC1155(_tokenUri) {
    maxSupply = MAX_SUPPLY_NORMAL + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA;
  }

  // ==============================================
  // Functions
  // ==============================================
  /**
    * Get token uri (overrided to work properly with opensea)
    * @param _tokenId {uint256} tokenId
  */
  function uri(uint256 _tokenId) override public view returns (string memory) {
      return(_uris[_tokenId]);
  }
  
  /**
    * Set tokenUri for a certain token Id
    * @param _tokenId {uint256} tokenId
    * @param _uri {string} uri of token metadata
  */
  function setTokenUri(uint256 _tokenId, string memory _uri) public onlyOwner {
      _uris[_tokenId] = _uri; 
  }

  /**
    * Set the isActive flag to activate/desactivate the mint capability 
    * @param _isActive {bool} A flag to activate contract 
  */
  function setIsActive(bool _isActive) public onlyOwner {
    isActive = _isActive;
  }

  /**
    * Set max mint quantity per wallet
    * @param _maxMintPerWallet {uint256} max mint per wallet
  */
  function setMaxMintPerWallet(uint256 _maxMintPerWallet) public onlyOwner {
    maxMintPerWallet = _maxMintPerWallet;
  }

  /**
    * Set max mint per transaction
    * @param _maxMintPerTransaction {uint256} max mint per transaction
   */
  function setMaxMintPerTransaction(uint256 _maxMintPerTransaction) public onlyOwner {
    maxMintPerTransaction = _maxMintPerTransaction;
  }

  /**
    * Set normal car price
    * @param _newPrice {uint256} new price
   */
  function setNormalPrice(uint256 _newPrice) public onlyOwner {
    normal_car_price = _newPrice;
  }

  /**
    * Set rare car price
    * @param _newPrice {uint256} new price
   */
  function setRarePrice(uint256 _newPrice) public onlyOwner {
    rare_car_price= _newPrice;
  }

  /**
    * Set super car price
    * @param _newPrice {uint256} new price
   */
  function setSuperRarePrice(uint256 _newPrice) public onlyOwner {
    super_car_price = _newPrice;
  }

  /**
    * Set super car price
    * @param _newPrice {uint256} new price
   */
  function setExtraRarePrice(uint256 _newPrice) public onlyOwner {
    extra_car_price = _newPrice;
  }

  /**
    * Public Mint function
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
   */
  function publicMint(address _to, uint256 _num, uint256 _mintType) public payable {
    require(isActive, 'Mint is not active');
    require(_num <= maxMintPerTransaction, '_num should be < maxMintPerWallet');
    uint256 totalBalanceOf =  balanceOf(_to, 1) + balanceOf(_to, 2) + balanceOf(_to, 3) + balanceOf(_to, 4);
    require(totalBalanceOf < maxMintPerWallet, 'maxMintPerWallet has been reached for this wallet');
    
    if (_mintType == 1) {
      // Normal type nft
      uint256 currentSupply = normal_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply');
      require(msg.value >= normal_car_price * _num,'Ether Value sent is not sufficient');
      _mint(_to, 1, _num, "");
      normal_car_count += _num;

    } else if (_mintType == 2) {
      // Rare type nft
      uint256 currentSupply = rare_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply');
      require(msg.value >= rare_car_price * _num,'Ether value sent is not sufficient');
      _mint(_to, 2, _num, "");
      rare_car_count += _num;

    } else if (_mintType == 3) {
      // Super type nft
      uint256 currentSupply = super_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply');
      require(msg.value >= super_car_price * _num,'Ether value sent is not sufficient');
      _mint(_to, 3, _num, "");
      super_car_count += _num;

    } else if (_mintType == 4) {
      // Extra type nft
      uint256 currentSupply = extra_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply');
      require(msg.value >= extra_car_price * _num,'Ether value sent is not sufficient');
      _mint(_to, 4, _num, "");
      extra_car_count += _num;

    } else {
      require(false, 'This tokenId doesnt exist');
    }
  }

  /**
   * Mint By Owner (for airdrops)
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
   */
  function mintByOwner(address _to, uint256 _num, uint256 _mintType) public onlyOwner {
    if (_mintType == 1) {
      // Normal type nft
      uint256 currentSupply = normal_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply');
      _mint(_to, 1, _num, "");
      normal_car_count += _num;

    } else if (_mintType == 2) {
      // Rare type nft
      uint256 currentSupply = rare_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply');
      _mint(_to, 2, _num, "");
      rare_car_count += _num;

    } else if (_mintType == 3) {
      // Super type nft
      uint256 currentSupply = super_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply');
      _mint(_to, 3, _num, "");
      super_car_count += _num;

    } else if (_mintType == 4) {
      // Extra type nft
      uint256 currentSupply = extra_car_count;
      require(currentSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply');
      _mint(_to, 4, _num, "");
      extra_car_count += _num;

    } else  {
      require(false, 'This mint type does not exist');
    }
  }

  /**
    * Function to withdraw collected amount during minting by the owner
    * @param _wallet1 {address} address 1 get 95% of balance
    * @param _wallet2 {address2} address 2 get 9% of balance
  */
  function withdraw(address _wallet1, address _wallet2) public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "Balance should be more then zero");

    // Pay first wallet (95%) of the balance
    uint256 balance1 = (balance * 95 / 100);
    uint256 balance2 = (balance * 5 / 100);
    console.log("log-balance", balance);
    console.log(balance1);
    console.log(balance2);
    payable(address(_wallet1)).transfer(balance1);
    payable(address(_wallet2)).transfer(balance2);
  }
}
