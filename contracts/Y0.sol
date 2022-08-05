//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

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

  uint256 immutable private MAX_MINT_PER_TX = 1;
  uint256 immutable private MAX_TOKEN_PER_WALLET = 3;
  
  bool public isActive = false;

  uint256 public maxSupply;
  uint256 public maxMintPerWallet = 3;
  uint256 public maxMintPerTransaction = 1;

  mapping (uint256 => string) private _uris;

  string private constant _name = "Y0";
  string private constant _symbol = "Y0";

  constructor(string memory _tokenUri) ERC1155(_tokenUri) {
    maxSupply = MAX_SUPPLY_NORMAL + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA;
  }

  // ==============================================
  // Functions
  // ==============================================

  /**
    * @dev Gets the token name.
    * @return string representing the token name
    */
  function name() external pure returns (string memory) {
      return _name;
  }

  /**
    * @dev Gets the token symbol.
    * @return string representing the token symbol
    */
  function symbol() external pure returns (string memory) {
      return _symbol;
  }

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
  function setTokenUri(uint256 _tokenId, string memory _uri) external onlyOwner {
      _uris[_tokenId] = _uri; 
  }

  /**
    * Set the isActive flag to activate/desactivate the mint capability 
    * @param _isActive {bool} A flag to activate contract 
  */
  function setIsActive(bool _isActive) external onlyOwner {
    isActive = _isActive;
  }

  /**
    * Set max mint quantity per wallet
    * @param _maxMintPerWallet {uint256} max mint per wallet
  */
  function setMaxMintPerWallet(uint256 _maxMintPerWallet) external onlyOwner {
    maxMintPerWallet = _maxMintPerWallet;
  }

  /**
    * Set max mint per transaction
    * @param _maxMintPerTransaction {uint256} max mint per transaction
   */
  function setMaxMintPerTransaction(uint256 _maxMintPerTransaction) external onlyOwner {
    maxMintPerTransaction = _maxMintPerTransaction;
  }

  /**
    * Set normal car price
    * @param _newPrice {uint256} new price
   */
  function setNormalPrice(uint256 _newPrice) external onlyOwner {
    normal_car_price = _newPrice;
  }

  /**
    * Set rare car price
    * @param _newPrice {uint256} new price
   */
  function setRarePrice(uint256 _newPrice) external onlyOwner {
    rare_car_price= _newPrice;
  }

  /**
    * Set super car price
    * @param _newPrice {uint256} new price
   */
  function setSuperRarePrice(uint256 _newPrice) external onlyOwner {
    super_car_price = _newPrice;
  }

  /**
    * Set super car price
    * @param _newPrice {uint256} new price
   */
  function setExtraRarePrice(uint256 _newPrice) external onlyOwner {
    extra_car_price = _newPrice;
  }

  /**
    * Public Mint function(This mint function can call in Ethereum and credit card payment ways both. In paper.xyz card way, mint function name must be `claimTo`.)
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
   */
  function claimTo(address _to, uint256 _num, uint256 _mintType) external payable {
    require(isActive, 'Mint is not active');
    require(_num <= maxMintPerTransaction, 'Number of mint cannot be more than maximal number of mint per wallet');
    require(
      balanceOf(_to, 1) + balanceOf(_to, 2) + balanceOf(_to, 3) + balanceOf(_to, 4) < maxMintPerWallet,
      'Maximal amount of mint has been reached for this wallet'
    );
    
    if (_mintType == 1) {
      // Normal type NFT
      require(normal_car_count + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
      require(msg.value >= normal_car_price * _num, 'Ether Value sent is not sufficient');
      normal_car_count += _num;
      _mint(_to, 1, _num, "");

    } else if (_mintType == 2) {
      // Rare type NFT
      require(rare_car_count + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
      require(msg.value >= rare_car_price * _num, 'Ether value sent is not sufficient');
      rare_car_count += _num;
      _mint(_to, 2, _num, "");

    } else if (_mintType == 3) {
      // Super type NFT
      require(super_car_count + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
      require(msg.value >= super_car_price * _num, 'Ether value sent is not sufficient');
      super_car_count += _num;
      _mint(_to, 3, _num, "");

    } else if (_mintType == 4) {
      // Extra type NFT
      require(extra_car_count + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
      require(msg.value >= extra_car_price * _num, 'Ether value sent is not sufficient');
      extra_car_count += _num;
      _mint(_to, 4, _num, "");
    } else {
      require(false, 'This tokenId doesnt exist');
    }
  }

 /**
    * Public Price function(this function must need paper card way.)
    * @notice Checks the price of the NFT
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    * @return {unit256} The price of a single NFT in Wei.
   */
  function price(uint256  _mintType) public view returns (uint256) {
    uint256 mintPrice;

    if (_mintType == 1) {
      // Normal type NFT
      mintPrice = _mintType * normal_car_price;

    } else if (_mintType == 2) {
      // Rare type NFT
      mintPrice = _mintType * rare_car_price;

    } else if (_mintType == 3) {
      // Super type NFT
      mintPrice = _mintType * super_car_price;

    } else if (_mintType == 4) {
      // Extra type NFT
      mintPrice = _mintType * extra_car_price;

    }
    return mintPrice;
  }

  /**
    * Public getClaimIneligibilityReason function(This function must need paper card way.)
    * @notice Gets any potential reason that the _userWallet is not able to claim _quantity of NFT
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    * @return {unit256} price  of collection as mintType.
   */
  function getClaimIneligibilityReason(address _to, uint256 _num, uint256 _mintType) public view returns (string memory) {
    string memory errorMessage = "";

    if (!isActive) {errorMessage = "Mint is not active";}
    if (_num > maxMintPerTransaction) {errorMessage = "Number of mint cannot be more than maximal number of mint per wallet";}
    if (balanceOf(_to, 1) + balanceOf(_to, 2) + balanceOf(_to, 3) + balanceOf(_to, 4) > maxMintPerWallet) {errorMessage = "Maximal amount of mint has been reached for this wallet";}

    if (_mintType == 1) {
      // Normal type NFT
      if (normal_car_count + _num >= MAX_SUPPLY_NORMAL) errorMessage = "Exceeded total supply of normal cars";
    } else if (_mintType == 2) {
      // Rare type NFT
      if (rare_car_count + _num >= MAX_SUPPLY_RARE) errorMessage = "Exceeded total supply of rare cars";

    } else if (_mintType == 3) {
      // Super type NFT
      if (super_car_count + _num >= MAX_SUPPLY_SUPER) errorMessage = "Exceeded total supply of super cars";

    } else if (_mintType == 4) {
      // Extra type NFT
      if (extra_car_count + _num >= MAX_SUPPLY_EXTRA) errorMessage = "Exceeded total supply of extra cars";
    } else {
      errorMessage = "You can't find mint type";
    }
    return errorMessage;
  }

  /**
    * @notice Checks the total amount of NFTs left to be claimed(This function must need paper card way.)
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    * @return uint256 The number of NFTs left to be claimed
  */
  function unclaimedSupply(uint256 _mintType) public view returns (uint256) {
    uint256 leftSupply;
    if (_mintType == 1) {
      // Normal type NFT
      leftSupply = MAX_SUPPLY_NORMAL - normal_car_count;

    } else if (_mintType == 2) {
      // Rare type NFT
      leftSupply = MAX_SUPPLY_RARE -  rare_car_count;

    } else if (_mintType == 3) {
      // Super type NFT
      leftSupply = MAX_SUPPLY_SUPER - super_car_count;

    } else if (_mintType == 4) {
      // Extra type NFT
      leftSupply = MAX_SUPPLY_EXTRA - extra_car_count;
    }
    return leftSupply;
  }

  /**
   * Mint By Owner (for airdrops)
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
   */
  function mintByOwner(address _to, uint256 _num, uint256 _mintType) external onlyOwner {
    if (_mintType == 1) {
      // Normal type NFT
      require(normal_car_count + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
      normal_car_count += _num;
      _mint(_to, 1, _num, "");

    } else if (_mintType == 2) {
      // Rare type NFT
      require(rare_car_count + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
      rare_car_count += _num;
      _mint(_to, 2, _num, "");

    } else if (_mintType == 3) {
      // Super type NFT
      require(super_car_count + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
      super_car_count += _num;
      _mint(_to, 3, _num, "");

    } else if (_mintType == 4) {
      // Extra type NFT
      require(extra_car_count + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
      extra_car_count += _num;
      _mint(_to, 4, _num, "");

    } else  {
      require(false, 'This mint type does not exist');
    }
  }

  /**
    * Function to withdraw collected amount during minting by the owner
    * @param _wallet1 {address} address 1 get 95% of balance
    * @param _wallet2 {address2} address 2 get 9% of balance
  */

  // TODO: responsability to 1 wallet (problem) + wallet not fixed in contract
  function withdraw(address _wallet1, address _wallet2) external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "Balance should be more then zero");

    // Pay wallet 1 95% and wallet 2 5%
    uint256 balance1 = (balance * 95 / 100);
    uint256 balance2 = (balance * 5 / 100);
    payable(address(_wallet1)).transfer(balance1);
    payable(address(_wallet2)).transfer(balance2);
  }

}
