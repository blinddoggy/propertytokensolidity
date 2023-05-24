// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./PropertyToken.sol";

contract PropertyMaster is Ownable {
    mapping(string => PropertyToken) private propertyMap;
    string[] private propertyKeys;

    struct Proyecto {
        string name;
        string symbol;
        string img;
        uint256 balanceERC20;
        uint256 balanceERC721;
        address nftAddress;
    }

    event NewProperty(address nftAddress, string ipfsHash);
    event TransferedErc721(address from, address to, string ipfsHash);
    event DistributeBalaceErc20(
        bool succes,
        uint256 balance,
        uint256 totalSupply
    );

    function getProject(
        string memory ipfsHash
    ) public view returns (Proyecto memory) {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        return
            Proyecto(
                propertyToken.name(),
                propertyToken.symbol(),
                propertyToken.tokenURI(0),
                address(propertyToken).balance,
                propertyToken.balanceOf(owner()),
                address(propertyToken)
            );
    }

    function createNewProperty(
        string memory name,
        string memory symbol,
        string memory ipfsHash,
        uint256 numTokens,
        string memory baseUri
    ) public returns (address, string memory) {
        PropertyToken ppt = new PropertyToken(name, symbol, ipfsHash);
        propertyMap[ipfsHash] = ppt;
        batchMintToProject(ipfsHash, numTokens, baseUri);
        //approveErc721(ipfsHash, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 1);//La puta q te remil  
        emit NewProperty(address(ppt), ipfsHash);
        return (address(ppt), ipfsHash);
    }

    function batchMintToProject(
        string memory ipfsHash,
        uint256 numTokens,
        string memory baseUri
    ) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.safeBatchMint(owner(), numTokens, baseUri);
    }

    function transferErc721(
        string memory ipfsHash,
        address from,
        address to
    ) public {
        require(
            msg.sender == from,
            "Solo el propietario puede transferir el token"
        );
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        uint256 tokenId = propertyToken.getTokenIdWithoutOwner();
        propertyToken.approve(to, tokenId);
        propertyToken.safeTransferFrom(from, to, tokenId);
        emit TransferedErc721(from, to, ipfsHash);
    }

    function setApprovalForAllOnPropertyToken(
        string memory ipfsHash,
        bool approved
    ) public {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.setApprovalForAll(address(this), approved);
    }


    function approveErc721(string memory ipfsHash, address to, uint256 tokenId) public {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.approve(to, tokenId);
    }

    function distributeBalaceErc20() public returns (bool success) {
        uint256 totalSupply = 0;
        for (uint256 i = 0; i < propertyKeys.length; i++) {
            totalSupply += propertyMap[propertyKeys[i]].totalSupply();
        }

        if (
            totalSupply == 0 ||
            address(this).balance == 0 ||
            address(this).balance < totalSupply
        ) {
            emit DistributeBalaceErc20(
                false,
                address(this).balance,
                totalSupply
            );
            return false;
        }

        for (uint256 j = 0; j < propertyKeys.length; j++) {
            PropertyToken propertyToken = propertyMap[propertyKeys[j]];
            uint256 propertyTotalSupply = propertyToken.totalSupply();
            for (uint256 i = 0; i < propertyTotalSupply; i++) {
                address owner = propertyToken.ownerOf(i);
                uint256 ownerTokenCount = propertyToken.balanceOf(owner);
                uint256 amountPerOwner = (address(this).balance *
                    ownerTokenCount) / totalSupply;
                payable(owner).transfer(amountPerOwner);
            }
        }
        emit DistributeBalaceErc20(true, address(this).balance, totalSupply);
        return true;
    }

    function getPropertyByHash(
        string memory ipfsHash
    ) private view returns (PropertyToken) {
        PropertyToken propertyToken = propertyMap[ipfsHash];
        require(address(propertyToken) != address(0), "Not exist");
        return propertyToken;
    }
}