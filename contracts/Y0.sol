//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "erc721a/contracts/ERC721A.sol";

contract Y0 is ERC721A, Ownable {
  using SafeMath for uint256;
  using Strings for uint256;

  // ==============================================
  // Properties
  // ==============================================
  uint256 public MINT_CAP_NORMAL = 1600;  
  uint256 public MINT_CAP_RARE = 400; 
  uint256 public MINT_CAP_SUPER = 200; 
  uint256 public MINT_CAP_EXTRA = 22; 

  uint256 public normal_car_count = 0;
  uint256 public rare_car_count = 0;
  uint256 public super_car_count = 0;
  uint256 public extra_car_count = 0;

  uint256 public normal_car_price = 11 ether;
  uint256 public rare_car_price = 22 ether;
  uint256 public super_car_price = 33 ether;
  uint256 public extra_car_price = 44 ether; 

  uint256 public MAX_SUPPLY1 = 1600; 
  uint256 public MAX_SUPPLY2 = 400; 
  uint256 public MAX_SUPPLY3 = 200; 
  uint256 public MAX_SUPPLY4 = 22; 
  
  bool public isActive = false;

  uint256 public maxSupply;
  uint256 public maxMintPerWallet = 3;
  uint256 public maxMintPerTransaction = 1;

  bool public revealNFT = false;

  string public baseURI;
  string public baseExtension = ".json";
  string public hiddenURI;

  constructor() ERC721A("Y0 NFT", "Y0 NFT") {
    maxSupply = MINT_CAP_NORMAL + MINT_CAP_RARE + MINT_CAP_SUPER + MINT_CAP_EXTRA;
  }

  // ==============================================
  // Functions
  // ==============================================
  /**
    * Set the uri used during the unreveal period
    * @param _hiddenURI {string} hidden URI
  */
  function setHiddenURI(string memory _hiddenURI) public onlyOwner {
    hiddenURI = _hiddenURI;
  }

  /**
    * Set the uris used to retrived nft metas
    * @param _baseURI {string} base URI
  */
  function setBaseURI(string memory _baseURI) public onlyOwner {
    baseURI = _baseURI;
  }

  /**
    * Set the isActive flag to activate/desactivate the mint capability 
    * @param _isActive {bool} A flag to activate contract 
  */
  function setIsActive(bool _isActive) public onlyOwner {
    isActive = _isActive;
  }

  /**
    * Set the revealNFT flag to reveal or hide NFTs
    * @param _revealNFT {bool} A flag to reveal NFTs
  */
  function setRevealNFT(bool _revealNFT) public onlyOwner {
    revealNFT = _revealNFT;
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
    require(balanceOf(_to) < maxMintPerWallet, 'maxMintPerWallet has been reached for this wallet');

    if (_mintType == 1) {
      // Normal type nft
      uint256 currentSupply = normal_car_count;
      require(currentSupply + _num <= MAX_SUPPLY1, 'Exceeded total supply');
      require(msg.value >= normal_car_price * _num,'Ether Value sent is not sufficient');
      _safeMint(_to, _num);
      normal_car_count += _num;

    } else if (_mintType == 2) {
      // Rare type nft
      uint256 currentSupply = rare_car_count;
      require(currentSupply + _num <= MAX_SUPPLY2, 'Exceeded total supply');
      require(msg.value >= rare_car_price * _num,'Ether value sent is not sufficient');
      _safeMint(_to, _num);
      rare_car_count += _num;

    } else if (_mintType == 3) {
      // Super type nft
      uint256 currentSupply = super_car_count;
      require(currentSupply + _num <= MAX_SUPPLY3, 'Exceeded total supply');
      require(msg.value >= super_car_price * _num,'Ether value sent is not sufficient');
      _safeMint(_to, _num);
      super_car_count += _num;

    } else if (_mintType == 4) {
      // Extra type nft
      uint256 currentSupply = extra_car_count;
      require(currentSupply + _num <= MAX_SUPPLY4, 'Exceeded total supply');
      require(msg.value >= extra_car_price * _num,'Ether value sent is not sufficient');
      _safeMint(_to, _num);
      extra_car_count += _num;

    } else  {
      require(false, 'This mint type does not exist');
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
      require(currentSupply + _num <= MAX_SUPPLY1, 'Exceeded total supply');
      _safeMint(_to, _num);
      normal_car_count += _num;

    } else if (_mintType == 2) {
      // Rare type nft
      uint256 currentSupply = rare_car_count;
      require(currentSupply + _num <= MAX_SUPPLY2, 'Exceeded total supply');
      _safeMint(_to, _num);
      rare_car_count += _num;

    } else if (_mintType == 3) {
      // Super type nft
      uint256 currentSupply = super_car_count;
      require(currentSupply + _num <= MAX_SUPPLY3, 'Exceeded total supply');
      _safeMint(_to, _num);
      super_car_count += _num;

    } else if (_mintType == 4) {
      // Extra type nft
      uint256 currentSupply = extra_car_count;
      require(currentSupply + _num <= MAX_SUPPLY4, 'Exceeded total supply');
      _safeMint(_to, _num);
      extra_car_count += _num;

    } else  {
      require(false, 'This mint type does not exist');
    }
  }

  // Returns a tokenURI
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

    if (revealNFT) {
      return string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension));
    } else {
      return string(abi.encodePacked(hiddenURI));      
    }
  }

  /**
    * Function to withdraw collected amount during minting by the owner
    * @param _wallet {address} address 
  */
  function withdraw(address _wallet) public onlyOwner {
    uint balance = address(this).balance;
    require(balance > 0, "Balance should be more then zero");

    payable(address(_wallet)).transfer(balance);
  }
}
