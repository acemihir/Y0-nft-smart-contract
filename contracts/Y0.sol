//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Y0 is ERC1155, Ownable {
  using SafeMath for uint256;

  // ==============================================
  // Properties PRICE IN DEV
  // ==============================================
  uint256 public constant NORMAL_CAR_PRICE = 0.0011 ether;
  uint256 public constant RARE_CAR_PRICE = 0.0022 ether;
  uint256 public constant SUPER_CAR_PRICE = 0.0033 ether;
  uint256 public constant EXTRA_CAR_PRICE = 0.0044 ether; 

  // ==============================================
  // Properties PRICE IN PRODUCTION
  // ==============================================
  // uint256 public constant NORMAL_CAR_PRICE = 11 ether;
  // uint256 public constant RARE_CAR_PRICE = 22 ether;
  // uint256 public constant SUPER_CAR_PRICE = 33 ether;
  // uint256 public constant EXTRA_CAR_PRICE = 44 ether; 

  uint256 public constant MAX_SUPPLY_NORMAL = 1600;
  uint256 public constant MAX_SUPPLY_RARE = 400;
  uint256 public constant MAX_SUPPLY_SUPER = 200;
  uint256 public constant MAX_SUPPLY_EXTRA = 22;
  uint256 public immutable MAX_SUPPLY;

  uint256 public constant MAX_MINT_PER_TX = 1;

  address public constant T1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // TODO: change to real address
  address public constant T2 = 0x0CA051175A0DEba6635Df8D6E2Cd8cEb8014Bda4; // TODO: change to real address

  uint256 public normalCarSupply = 0;
  uint256 public rareCarSupply = 0;
  uint256 public superCarSupply = 0;
  uint256 public extraCarSupply = 0;
  
  bool public isPaused = false;

  string private constant _NAME = "Y0";
  string private constant _SYMBOL = "Y0";
  
  constructor(string memory _tokenUri) ERC1155(_tokenUri) {
    MAX_SUPPLY = MAX_SUPPLY_NORMAL + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA;
  }

  // ==============================================
  // Functions
  // ==============================================

  /**
    * @dev Gets the token name.
    * @return string representing the token name
   */
  function name() external pure returns (string memory) {
      return _NAME;
  }

  /**
    * @dev Gets the token symbol.
    * @return string representing the token symbol
   */
  function symbol() external pure returns (string memory) {
      return _SYMBOL;
  }

  /**
    * Set the isPaused flag to activate/desactivate the mint capability 
    * @param _isActive {bool} A flag to activate contract 
   */
  function setIsActive(bool _isActive) external onlyOwner {
    isPaused = _isActive;
  }

  /**
    * Set the isPaused flag to desactivate the mint capability 
   */
  function pause() external onlyOwner {
    isPaused = true;
  }

  /**
    * Public Mint function(This mint function can call in Ethereum and credit card payment ways both. In paper.xyz card way, mint function name must be `claimTo`.)
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
   */
  function claimTo(address _to, uint256 _num, uint256 _mintType) external payable {
    require(isPaused, 'Mint is not active');
    require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');

    if (_mintType == 1) {
      // Normal type NFT
      require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
      require(msg.value == NORMAL_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
      _mint(_to, 1, _num, "");
      normalCarSupply += _num;

    } else if (_mintType == 2) {
      // Rare type NFT
      require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
      require(msg.value == RARE_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
      _mint(_to, 2, _num, "");
      rareCarSupply += _num;

    } else if (_mintType == 3) {
      // Super type NFT
      require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
      require(msg.value == SUPER_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
      _mint(_to, 3, _num, "");
      superCarSupply += _num;

    } else if (_mintType == 4) {
      // Extra type NFT
      require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
      require(msg.value == EXTRA_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
      _mint(_to, 4, _num, "");
      extraCarSupply += _num;

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
  function price(uint256  _mintType) public pure returns (uint256) {
    if (_mintType == 1) {
      // Normal type NFT
      return NORMAL_CAR_PRICE;

    } else if (_mintType == 2) {
      // Rare type NFT
      return RARE_CAR_PRICE;

    } else if (_mintType == 3) {
      // Super type NFT
      return SUPER_CAR_PRICE;

    } else if (_mintType == 4) {
      // Extra type NFT
      return EXTRA_CAR_PRICE;

    }
    return 0;
  }

  /**
    * Public getClaimIneligibilityReason function(This function must need paper card way.)
    * @notice Gets any potential reason that the _userWallet is not able to claim _quantity of NFT
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    * @return {unit256} price  of collection as mintType.
   */
  function getClaimIneligibilityReason(address _to, uint256 _num, uint256 _mintType) public view returns (string memory) {
    string memory errorMessage = "";

    if (!isPaused) {errorMessage = "Mint is not active";}
    if (_num > MAX_MINT_PER_TX) {errorMessage = "Number of mint cannot be more than maximal number of mint per wallet";}

    if (_mintType == 1) {
      // Normal type NFT
      if (normalCarSupply + _num >= MAX_SUPPLY_NORMAL) errorMessage = "Exceeded total supply of normal cars";
    } else if (_mintType == 2) {
      // Rare type NFT
      if (rareCarSupply + _num >= MAX_SUPPLY_RARE) errorMessage = "Exceeded total supply of rare cars";

    } else if (_mintType == 3) {
      // Super type NFT
      if (superCarSupply + _num >= MAX_SUPPLY_SUPER) errorMessage = "Exceeded total supply of super cars";

    } else if (_mintType == 4) {
      // Extra type NFT
      if (extraCarSupply + _num >= MAX_SUPPLY_EXTRA) errorMessage = "Exceeded total supply of extra cars";
    } else {
      errorMessage = "Wrong token type provided";
    }
    return errorMessage;
  }

  /**
    * @notice Checks the total amount of NFTs left to be claimed(This function must need paper card way.)
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    * @return uint256 The number of NFTs left to be claimed
   */
  function unclaimedSupply(uint256 _mintType) public view returns (uint256) {
    if (_mintType == 1) {
      // Normal type NFT
      return MAX_SUPPLY_NORMAL - normalCarSupply;

    } else if (_mintType == 2) {
      // Rare type NFT
      return MAX_SUPPLY_RARE -  rareCarSupply;

    } else if (_mintType == 3) {
      // Super type NFT
      return MAX_SUPPLY_SUPER - superCarSupply;

    } else if (_mintType == 4) {
      // Extra type NFT
      return MAX_SUPPLY_EXTRA - extraCarSupply;
    }
    return 0;
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
      require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
      _mint(_to, 1, _num, "");
      normalCarSupply += _num;

    } else if (_mintType == 2) {
      // Rare type NFT
      require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
      _mint(_to, 2, _num, "");
      rareCarSupply += _num;

    } else if (_mintType == 3) {
      // Super type NFT
      require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
      _mint(_to, 3, _num, "");
      superCarSupply += _num;

    } else if (_mintType == 4) {
      // Extra type NFT
      require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
      _mint(_to, 4, _num, "");
      extraCarSupply += _num;

    } else  {
      require(false, 'This mint type does not exist');
    }
  }

  /**
    * Function to withdraw collected amount during minting by the team
   */
  function withdraw() external {
    require(msg.sender == T1 || msg.sender == T2, "Only Team can withdraw");

    uint256 balance = address(this).balance;

    uint256 S1 = (balance * 95 / 100); // 95%
    uint256 S2 = (balance * 5 / 100);  // 5%
    (bool os1, ) = payable(T1).call{value: S1}("");
    require(os1);
    (bool os2, ) = payable(T2).call{value: S2}("");
    require(os2);
  }
}
