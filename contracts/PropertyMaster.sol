// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./PropertyToken.sol";

contract PropertyMaster is Ownable {

    PropertyToken[] public properties;

    struct Proyecto {
        string name;
        string symbol;
        string img;
        uint256 balanceERC20;
        uint256 balanceERC721;
        address nftAddress;
    }

    

    function getTokenIndex(string memory ipfsHash) public view returns (uint256) {
        for (uint256 i = 0; i < properties.length; i++) {
            if (keccak256(bytes(properties[i].getHash())) == keccak256(bytes(ipfsHash))) {
                return i;
            }
        }
        revert();
    }

    

    function getProject(string memory ipfsHash) public view returns (Proyecto memory) {
        uint256 index = getTokenIndex(ipfsHash);
        return Proyecto(
            properties[index].name(),
            properties[index].symbol(),
            properties[index].tokenURI(0),
            address(properties[index]).balance,
            properties[index].balanceOf(properties[index].getAddress()),
            properties[index].getAddress()
        );
    }

    function createNewProperty(string memory name, string memory symbol, string memory ipfsHash) public payable returns( PropertyToken ) {
        PropertyToken ppt = new PropertyToken(name, symbol, ipfsHash);
        properties.push(ppt);
        return ppt;
    }

    function mintProjectMasterOwner(uint256 index) public {
        properties[index].safeMint(owner(), "");
    }
}