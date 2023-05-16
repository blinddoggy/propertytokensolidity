// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./PropertyToken.sol";

contract PropertyMaster is Ownable{

    PropertyToken[] public properties;


    event NewPropertyToken(address indexed _address, uint indexed _tokenId);

    function createNewProperty(string memory name, string memory symbol, string memory ipfsHash) public payable returns( PropertyToken ) {
        PropertyToken ppt = new PropertyToken(name, symbol, ipfsHash);
        properties.push(ppt);
        emit NewPropertyToken(address(this), properties.length);
        return ppt;
    }

    function getPropertyHash(uint index) public view returns(address){
        return properties[index].getAddress();
    }

    function mintProjectSelfOwner(uint index) public {
        address owner = properties[index].owner();
        properties[index].safeMint(owner, "");
    }

    function mintProjectMasterOwner(uint index) public {
        address owner = owner();
        properties[index].safeMint(owner, "");
    }
    
}

