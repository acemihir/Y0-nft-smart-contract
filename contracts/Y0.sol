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
    
    uint256 public constant ZERO_CAR_PRICE = 0.00001 ether;
    uint256 public constant NORMAL_CAR_PRICE = 0.0011 ether;
    uint256 public constant RARE_CAR_PRICE = 0.0022 ether;
    uint256 public constant SUPER_CAR_PRICE = 0.0033 ether;
    uint256 public constant EXTRA_CAR_PRICE = 0.0044 ether; 

    // ==============================================
    // Properties PRICE IN PRODUCTION
    // ==============================================

    // uint256 public constant ZERO_CAR_PRICE = 0.07 ether;
    // uint256 public constant NORMAL_CAR_PRICE = 11 ether;
    // uint256 public constant RARE_CAR_PRICE = 22 ether;
    // uint256 public constant SUPER_CAR_PRICE = 33 ether;
    // uint256 public constant EXTRA_CAR_PRICE = 44 ether;

    uint256 public constant MAX_SUPPLY_ZERO = 5000;
    uint256 public constant MAX_SUPPLY_NORMAL = 4400;
    uint256 public constant MAX_SUPPLY_RARE = 3300;
    uint256 public constant MAX_SUPPLY_SUPER = 2200;
    uint256 public constant MAX_SUPPLY_EXTRA = 1100;
    
    uint256 public constant MAX_MINT_PER_TX = 10;

    address public constant T1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // TODO: change to real address
    address public constant T2 = 0x0CA051175A0DEba6635Df8D6E2Cd8cEb8014Bda4; // TODO: change to real address

    uint256 public zeroCarSupply = 0;
    uint256 public normalCarSupply = 0;
    uint256 public rareCarSupply = 0;
    uint256 public superCarSupply = 0;
    uint256 public extraCarSupply = 0;

    bool public isPaused = false;
    bool public isMetadataLocked = false;

    Counters.Counter private _totalSupply;

    string private _baseTokenURI;

    constructor (string memory baseURI) ERC721("Y0", "Y0") {
        updateBaseURI(baseURI);
    }

    /**
      * @notice Set the isPaused flag to activate/desactivate the mint capability 
      * @param _isActive {bool} A flag to activate contract 
     */
    function setIsActive(bool _isActive) external onlyOwner {
        isPaused = _isActive;
    }

    /**
      * @notice Set the isPaused flag to deactivate the mint capability 
     */
    function pause() external onlyOwner {
        isPaused = true;
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
    }

    /**
      * @notice Lock update metadata functionality
     */
    function lockMetadata() external onlyOwner {
        isMetadataLocked = true;
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
            // Zero type NFT
            require(zeroCarSupply + _num <= MAX_SUPPLY_ZERO, 'Exceeded total supply of zero NFTs');
            require(msg.value >= ZERO_CAR_PRICE * _num, 'Ether Value sent is not the right amount');

            for(uint256 i = 0; i < _num; i++) {
                _safeMint(_to, normalCarSupply + MAX_SUPPLY_NORMAL + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                zeroCarSupply++;
                _totalSupply.increment();
            }

        }   
        else if (_mintType == 1) {
            // Normal type NFT
            require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
            require(msg.value >= NORMAL_CAR_PRICE * _num, 'Ether Value sent is not the right amount');

            for(uint256 i = 0; i < _num; i++) {
                _safeMint(_to, normalCarSupply + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                normalCarSupply++;
                _totalSupply.increment();
            }

        } else if (_mintType == 2) {
            // Rare type NFT
            require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
            require(msg.value >= RARE_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i++) {
                _safeMint(_to, rareCarSupply + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                rareCarSupply++;
                _totalSupply.increment();
            }

        } else if (_mintType == 3) {
            // Super type NFT
            require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
            require(msg.value >= SUPER_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i++) {
                _safeMint(_to, superCarSupply + MAX_SUPPLY_EXTRA + 1);
                superCarSupply++;
                _totalSupply.increment();
            }
        } else if (_mintType == 4) {
            // Extra type NFT
            require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
            require(msg.value >= EXTRA_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i++) {
                _safeMint(_to, extraCarSupply + 1);
                extraCarSupply++;
                _totalSupply.increment();
            }
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
            // Zero type NFT
            return ZERO_CAR_PRICE;

        } else if (_mintType == 1) {
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
      * @notice Checks the total amount of NFTs left to be claimed(This function must need paper card way.)
      * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
      * @return uint256 The number of NFTs left to be claimed
     */
    function unclaimedSupply(uint256 _mintType) public view returns (uint256) {
        if (_mintType == 0) {
            // Zero type NFT
            return MAX_SUPPLY_ZERO - zeroCarSupply;

        } else if (_mintType == 1) {
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
        require(isPaused, 'Mint is not active');
        require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');

        if (_mintType == 0) {
            // Zero type NFT
            require(zeroCarSupply + _num <= MAX_SUPPLY_ZERO, 'Exceeded total supply of zero NFTs');
            for(uint256 i = 0; i < _num; i++) {
                _mint(_to, normalCarSupply + MAX_SUPPLY_NORMAL + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                zeroCarSupply++;
                _totalSupply.increment();
            }

        }   
        else if (_mintType == 1) {
            // Normal type NFT
            require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');

            for(uint256 i = 0; i < _num; i++) {
                _mint(_to, normalCarSupply + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                normalCarSupply++;
                _totalSupply.increment();
            }

        } else if (_mintType == 2) {
            // Rare type NFT
            require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
            
            for(uint256 i = 0; i < _num; i++) {
                _mint(_to, rareCarSupply + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                rareCarSupply++;
                _totalSupply.increment();
            }

        } else if (_mintType == 3) {
            // Super type NFT
            require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
            
            for(uint256 i = 0; i < _num; i++) {
                _mint(_to, superCarSupply + MAX_SUPPLY_EXTRA + 1);
                superCarSupply++;
                _totalSupply.increment();
            }
        } else if (_mintType == 4) {
            // Extra type NFT
            require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
            
            for(uint256 i = 0; i < _num; i++) {
                _mint(_to, extraCarSupply + 1);
                extraCarSupply++;
                _totalSupply.increment();
            }
        } else {
            require(false, 'This category doesnt exist');
        }
    }

    /**
      * @notice Function to withdraw collected amount during minting by the team
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