// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Property.sol";

contract PropertyMaster{

    Property[] public properties;


    event NewPropertyToken(address indexed _address, uint indexed _tokenId);

    function createNewProperty(string memory name, string memory symbol,string memory _ipfsHash) public returns( Property ) {
        Property ppt = new Property(name, symbol,_ipfsHash);
        properties.push(ppt);
        emit NewPropertyToken(address(this), properties.length);
        return ppt;
    }
}