// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// TO DO: Explain the reason/advantadge to use ERC721URIStorage instead of ERC721 itself
/**
*  While mint the nft, ERC721 store token uri based the base token uri by adding the tokenId.
*  But to update the token metadata after minting, we use the ERC721URIStorage to set the token uri manually.
*/

contract Y0 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _totalCount;

    bool public isPaused = false;

    string private constant _NAME = "Y0";
    string private constant _SYMBOL = "Y0";
    string private baseTokenURI;

    // ==============================================
    // Properties PRICE IN DEV
    // ==============================================
    
    uint256 public constant NORMAL_CAR_PRICE = 0.0011 ether;
    uint256 public constant RARE_CAR_PRICE = 0.0022 ether;
    uint256 public constant SUPER_CAR_PRICE = 0.0033 ether;
    uint256 public constant EXTRA_CAR_PRICE = 0.0044 ether; 

    uint256 public constant MAX_SUPPLY_NORMAL = 4400;
    uint256 public constant MAX_SUPPLY_RARE = 3300;
    uint256 public constant MAX_SUPPLY_SUPER = 2200;
    uint256 public constant MAX_SUPPLY_EXTRA = 1100;

    uint256 public normalCarSupply = 0;
    uint256 public rareCarSupply = 0;
    uint256 public superCarSupply = 0;
    uint256 public extraCarSupply = 0;

    address public constant T1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // TODO: change to real address
    address public constant T2 = 0x0CA051175A0DEba6635Df8D6E2Cd8cEb8014Bda4; // TODO: change to real address

    constructor (string memory baseURI) ERC721("Y0 NFT", "Y0") {
        setBaseURI(baseURI);
    }

    /**
        * @dev Gets the token name.
        * @return string representing the token name
    */
    function name() public view virtual override returns (string memory) {
        return _NAME;
    }

    /**
        * @dev Gets the token symbol.
        * @return string representing the token symbol
    */
    function symbol() public view virtual override returns (string memory) {
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

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _totalSupply() internal view returns (uint256) {
        return _totalCount.current();
    }

    function updateTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        require(_exists(tokenId), "Token doesn't exists.");
        _setTokenURI(tokenId, uri);
    } 

    /**
    * Public Mint function(This mint function can call in Ethereum and credit card payment ways both. In paper.xyz card way, mint function name must be `claimTo`.)
    * @param _to {address} address
    * @param _num {uint256} number of mint for this transaction
    * @param _mintType {uint256} mintType (1: normal, 2: rare, 3: super, 4: extra )
    */
    function claimTo(address _to, uint256 _num, uint256 _mintType) external payable {
        require(isPaused, 'Mint is not active');
        // require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');
        require(_num > 0 && _num < 11, 'Number of mint cannot be less than 1 mint or greater than 10 mints per transaction');

        if (_mintType == 1) {
            // Normal type NFT
            require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');
            require(msg.value >= NORMAL_CAR_PRICE * _num, 'Ether Value sent is not the right amount');

            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, normalCarSupply + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER +  MAX_SUPPLY_EXTRA + 1);
                normalCarSupply ++;
                _totalCount.increment();
            }

        } else if (_mintType == 2) {
            // Rare type NFT
            require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
            require(msg.value >= RARE_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, rareCarSupply + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                rareCarSupply ++;
                _totalCount.increment();
            }

        } else if (_mintType == 3) {
            // Super type NFT
            require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
            require(msg.value >= SUPER_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, superCarSupply + MAX_SUPPLY_EXTRA + 1);
                superCarSupply ++;
                _totalCount.increment();
            }
        } else if (_mintType == 4) {
            // Extra type NFT
            require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
            require(msg.value >= EXTRA_CAR_PRICE * _num, 'Ether Value sent is not the right amount');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, extraCarSupply + 1);
                extraCarSupply ++;
                _totalCount.increment();
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
        require(isPaused, 'Mint is not active');
        // require(_num > 0 && _num <= MAX_MINT_PER_TX, 'Number of mint cannot be less than 1 and more than maximal number of mint per transaction');
        require(_num > 0 && _num < 11, 'Number of mint cannot be less than 1 mint or greater than 10 mints per transaction');

        if (_mintType == 1) {
            // Normal type NFT
            require(normalCarSupply + _num <= MAX_SUPPLY_NORMAL, 'Exceeded total supply of normal cars');

            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, normalCarSupply + MAX_SUPPLY_RARE + MAX_SUPPLY_SUPER +  MAX_SUPPLY_EXTRA + 1);
                normalCarSupply ++;
                _totalCount.increment();
            }

        } else if (_mintType == 2) {
            // Rare type NFT
            require(rareCarSupply + _num <= MAX_SUPPLY_RARE, 'Exceeded total supply of rare cars');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, rareCarSupply + MAX_SUPPLY_SUPER + MAX_SUPPLY_EXTRA + 1);
                rareCarSupply ++;
                _totalCount.increment();
            }

        } else if (_mintType == 3) {
            // Super type NFT
            require(superCarSupply + _num <= MAX_SUPPLY_SUPER, 'Exceeded total supply of super cars');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, superCarSupply + MAX_SUPPLY_EXTRA + 1);
                superCarSupply ++;
                _totalCount.increment();
            }
        } else if (_mintType == 4) {
            // Extra type NFT
            require(extraCarSupply + _num <= MAX_SUPPLY_EXTRA, 'Exceeded total supply of extra cars');
            
            for(uint256 i = 0; i < _num; i ++) {
                _safeMint(_to, extraCarSupply + 1);
                extraCarSupply ++;
                _totalCount.increment();
            }
        } else {
            require(false, 'This category doesnt exist');
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