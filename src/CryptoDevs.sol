// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/Whitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    // TOKEN_PRICE is the price of one Crypto Dev NFT
    uint256 public constant TOKEN_PRICE = 0.01 ether;

    // Maximum number of CryptoDevs that can ever exist
    uint256 public constant MAX_SUPPLY = 20;

    // Whitelist contract instance
    Whitelist public whitelist;

    // Number of tokens reserved for whitelisted members
    uint256 public reservedTokens;
    uint256 public reservedTokensClaimed = 0;

    constructor(address whitelistContract) ERC721("Crypto Devs", "CD") Ownable(msg.sender) {
        whitelist = Whitelist(whitelistContract);
        reservedTokens = whitelist.owner() == address(0) ? 0 : MAX_SUPPLY / 2; // Adjust as needed
    }

    function mint() public payable {
        require(totalSupply() + reservedTokens - reservedTokensClaimed < MAX_SUPPLY, "EXCEEDED_MAX_SUPPLY");

        if (whitelist.isWhitelisted(msg.sender) && msg.value < TOKEN_PRICE) {
            require(balanceOf(msg.sender) == 0, "ALREADY_OWNED");
            reservedTokensClaimed += 1;
        } else {
            require(msg.value >= TOKEN_PRICE, "NOT_ENOUGH_ETHER");
        }
        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public onlyOwner {
        address contractOwner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = contractOwner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

