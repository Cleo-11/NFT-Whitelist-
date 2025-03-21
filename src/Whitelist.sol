// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Whitelist {
    mapping(address => bool) public whitelistedAddresses;
    address public owner;

    event AddressWhitelisted(address indexed _address);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addToWhitelist(address _address) public onlyOwner {
        whitelistedAddresses[_address] = true;
        emit AddressWhitelisted(_address);
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelistedAddresses[_address];
    }
}

