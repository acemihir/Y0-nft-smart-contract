// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Y0 is ERC721, Ownable {
    using Counters for Counters.Counter;

    // ==============================================
    // Properties PRICE IN DEV
    // ==============================================
    
    uint256 public constant NORMAL_CAR_PRICE = 0.0011 ether;
    uint256 public constant RARE_CAR_PRICE = 0.0022 ether;
    uint256 public constant SUPER_CAR_PRICE = 0.0033 ether;
    uint256 public constant EXTRA_CAR_PRICE = 0.0044 ether; 

    address public constant LEDGER1 = 0x2482c0A3196fafA2C88769087bfb7b9C2e80b1dd; 
    address public constant LEDGER2 = 0x20ADB97C2b2C67FCc2B8BcA8c54825379597681f;
    address public constant DEV = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    // ==============================================
    // Properties PRICE IN PRODUCTION
    // ==============================================

    // uint256 public constant NORMAL_CAR_PRICE = 11 ether;
    // uint256 public constant RARE_CAR_PRICE = 22 ether;
    // uint256 public constant SUPER_CAR_PRICE = 33 ether;
    // uint256 public constant EXTRA_CAR_PRICE = 44 ether;

    // address public constant LEDGER1 = 0x2482c0A3196fafA2C88769087bfb7b9C2e80b1dd; 
    // address public constant LEDGER2 = 0x20ADB97C2b2C67FCc2B8BcA8c54825379597681f;
    // address public constant DEV = 0x0CA051175A0DEba6635Df8D6E2Cd8cEb8014Bda4;

    uint256 public constant MAX_SUPPLY_NORMAL = 4400;
    uint256 public constant MAX_SUPPLY_RARE = 3300;
    uint256 public constant MAX_SUPPLY_SUPER = 2200;
    uint256 public constant MAX_SUPPLY_EXTRA = 1100;
    
    uint256 public constant MAX_MINT_PER_TX = 10;

    uint256[5] public tierCarSupply = [0, 0, 0, 0];

    bool public isPaused = false;
    bool public isMetadataLocked = false;

    Counters.Counter private _totalSupply;

    string private _baseTokenURI;

    // -------- Events --------
    event IsActived(bool _isActive);
    event Paused();
    event MetadataUpdated(string indexed _newBaseURI);
    event MetadataLocked();

    constructor (string memory baseURI) ERC721("Y0", "Y0") {
        updateBaseURI(baseURI);
    }

    /**
      * @notice Set the isPaused flag to activate/desactivate the mint capability 
      * @param _isActive {bool} A flag to activate contract 
     */
    function setIsActive(bool _isActive) external onlyOwner {
        isPaused = _isActive;
        emit IsActived(_isActive);
    }

    /**
      * @notice Set the isPaused flag to deactivate the mint capability 
     */
    function pause() external onlyOwner {
        isPaused = true;
        emit Paused();
    }

    /**
      * @notice Return the total supply of tokens
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply.current();
    }

    /**
      * @notice Return the base URI of the token
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
      * @notice Update metadata base URI
     */
    function updateBaseURI(string memory _newBaseURI) public onlyOwner {
        require(!isMetadataLocked, "Metadata ownership renounced!");
        _baseTokenURI = _newBaseURI;
        emit MetadataUpdated(_baseTokenURI);
    }

    /**
      * @notice Lock update metadata functionality
     */
    function lockMetadata() external onlyOwner {
        isMetadataLocked = true;
        emit MetadataLocked();
    }

    /**
      * @notice Mint `_num` tokens for public
     */
    function _mintLoopPublic(address _to, uint256 _num, uint256 _mintType, uint256 _maxSupplyTier, uint256 _tierCarPrice, uint256 _maxSupplyTierPad) internal {
        require(msg.value >= _tierCarPrice * _num, 'Ether Value sent is not the right amount');
        _mintLoop(_to, _num, _mintType, _maxSupplyTier, _maxSupplyTierPad);
    }

    /**
      * @notice Mint `_num` tokens
     */
    function _mintLoop(address _to, uint256 _num, uint256 _mintType, uint256 _maxSupplyTier, uint256 _maxSupplyTierPad) internal {
        require(tierCarSupply[_mintType] + _num <= _maxSupplyTier, 'Exceeded total supply of NFTs of this tier');

        for (uint256 i = 0; i < _num; i++) {
            _safeMint(_to, tierCarSupply[_mintType] + _maxSupplyTierPad + 1);
            tierCarSupply[_mintType]++;
            _totalSupply.increment();
        }
    }

    /**
      * @notice Public Mint function(This mint function can call in Ethereum and credit card payment ways both. In paper.xyz card way, mint function name must be `claimTo`.)
      * @param _to {address} address
      * @param _num {uint256} number of mint for this transaction
      * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
     */
    function claimTo(address _to, uint256 _num, uint256 _mintType) external payable {
        require(isPaused, 'Mint is not active');
        require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');

        if (_mintType == 0) {
            // Normal type NFT
            _mintLoopPublic(_to, _num, _mintType, MAX_SUPPLY_NORMAL, NORMAL_CAR_PRICE, MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA);

        } else if (_mintType == 1) {
            // Rare type NFT
            _mintLoopPublic(_to, _num, _mintType, MAX_SUPPLY_RARE, RARE_CAR_PRICE, MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA);

        } else if (_mintType == 2) {
            // Super type NFT
            _mintLoopPublic(_to, _num, _mintType, MAX_SUPPLY_SUPER, SUPER_CAR_PRICE, MAX_SUPPLY_EXTRA);

        } else if (_mintType == 3) {
            // Extra type NFT
            _mintLoopPublic(_to, _num, _mintType, MAX_SUPPLY_EXTRA, EXTRA_CAR_PRICE, 0);
            
        } else {
            require(false, 'This category doesnt exist');
        }
    }

    /**
      * Public Price function(this function must need paper card way.)
      * @notice Checks the price of the NFT
      * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
      * @return {unit256} The price of a single NFT in Wei.
     */
    function price(uint256  _mintType) public pure returns (uint256) {
        if (_mintType == 0) {
            // Normal type NFT
            return NORMAL_CAR_PRICE;

        } else if (_mintType == 1) {
            // Rare type NFT
            return RARE_CAR_PRICE;

        } else if (_mintType == 2) {
            // Super type NFT
            return SUPER_CAR_PRICE;

        } else if (_mintType == 3) {
            // Extra type NFT
            return EXTRA_CAR_PRICE;

        }
        return 0;
    }

    /**
      * @notice Checks the total amount of NFTs left to be claimed(This function must need paper card way.)
      * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
      * @return uint256 The number of NFTs left to be claimed
     */
    function unclaimedSupply(uint256 _mintType) public view returns (uint256) {
        if (_mintType == 0) {
            // Normal type NFT
            return MAX_SUPPLY_NORMAL - tierCarSupply[1];

        } else if (_mintType == 1) {
            // Rare type NFT
            return MAX_SUPPLY_RARE -  tierCarSupply[2];

        } else if (_mintType == 2) {
            // Super type NFT
            return MAX_SUPPLY_SUPER - tierCarSupply[3];

        } else if (_mintType == 3) {
            // Extra type NFT
            return MAX_SUPPLY_EXTRA - tierCarSupply[4];
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
        require(isPaused, 'Mint is not active');
        require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');

        if (_mintType == 0) {
            // Normal type NFT
            _mintLoop(_to, _num, _mintType, MAX_SUPPLY_NORMAL, MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA);

        } else if (_mintType == 1) {
            // Rare type NFT
            _mintLoop(_to, _num, _mintType, MAX_SUPPLY_RARE, MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA);

        } else if (_mintType == 2) {
            // Super type NFT
            _mintLoop(_to, _num, _mintType, MAX_SUPPLY_SUPER, MAX_SUPPLY_EXTRA);

        } else if (_mintType == 3) {
            // Extra type NFT
            _mintLoop(_to, _num, _mintType, MAX_SUPPLY_EXTRA, 0);
            
        } else {
            require(false, 'This category doesnt exist');
        }
    }

    /**
      * @notice Function to withdraw collected amount during minting by the team
     */
    function withdraw() external {
        require(msg.sender == LEDGER1 || msg.sender == LEDGER2 || msg.sender == DEV, "Only Team can withdraw");

        uint256 balance = address(this).balance;

        uint256 SLEDGER1 = (balance * 47 / 100); // 47%
        uint256 SLEDGER2 = (balance * 48 / 100); // 48%
        uint256 SDEV = (balance * 5 / 100);  // 5%
        (bool os1, ) = payable(LEDGER1).call{value: SLEDGER1}("");
        require(os1);
        (bool os2, ) = payable(LEDGER2).call{value: SLEDGER2}("");
        require(os2);
        (bool os3, ) = payable(DEV).call{value: SDEV}("");
        require(os3);
    }
}
