//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract Arcane is ERC721URIStorage,Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply; //current no. of mints
    uint256 public maxSupply; //total that can be minted
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet; //to withdraw the money that goes into this contract
    mapping (address => uint256) public walletMints; //to keep track of how many each wallet has minted

    constructor() payable ERC721('Arcane', 'ARC'){
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        withdrawWallet = payable(0xC81A20e3F8EBC43a317942a85a3968B79af20a30);//***set withdraw wallet address***
    }
    
    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner{
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner{
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {  // 
        require(_exists(tokenId_), 'token does not exist!');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId_),".json"));
    } //this function exists in the ERC721 contract. Overriding it with the baseTokenUri

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{ value: address(this).balance}('');
        require(success,'withdraw failed');
    }

    function mint(uint256 quantity_) public payable{
        require(isPublicMintEnabled, 'minting not enabled');
        require(msg.value == quantity_ * mintPrice, 'wrong mint value');
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed max wallet');

        for(uint256 i=0; i< quantity_ ;i++){
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;  // doing effects before the contract interaction to avoid re-entrancy attack
            _safeMint(msg.sender, newTokenId); //interaction

        }
    }   
}

