// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./PropertyToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PropertyMaster is Ownable {
    event Received(address, uint);
    event Transferred(address to, uint amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    mapping(string => PropertyToken) private propertyMap;
    mapping(address => bool) public hasReceivedTransfer;
    uint256 lastDistributedBalanceDate;
    string[] private propertyKeys;

    struct Proyecto {
        string name;
        string symbol;
        string img;
        uint256 balanceERC20;
        uint256 balanceERC721;
        address nftAddress;
    }

    event NewPropertyCreated(
        string indexed ipfsHash,
        address nftAddress,
        string name,
        uint256 timestamp,
        string srcImage
    );
    event TransferredErc721(
        string indexed ipfsHash,
        string name,
        address from,
        address to
    );

    event DistributedBalance(
        string indexed ipfsHash,
        bool success,
        string name,
        uint256 balance,
        uint256 totalSupply,
        string srcImage
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
        PropertyToken propertyToken = new PropertyToken(name, symbol, ipfsHash);
        propertyMap[ipfsHash] = propertyToken;
        batchMintToProject(ipfsHash, numTokens, baseUri);
        emit NewPropertyCreated(
            ipfsHash,
            address(propertyToken),
            propertyToken.name(),
            block.timestamp,
            propertyToken.tokenURI(0)
        );
        return (address(propertyToken), ipfsHash);
    }

    function batchMintToProject(
        string memory ipfsHash,
        uint256 numTokens,
        string memory baseUri
    ) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.safeBatchMint(msg.sender, numTokens, baseUri);
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
        emit TransferredErc721(ipfsHash, propertyToken.name(), from, to);
    }

    function setApprovalForAllOnPropertyToken(
        string memory ipfsHash,
        bool approved
    ) public {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.setApprovalForAll(address(this), approved);
    }

    function approveErc721(
        string memory ipfsHash,
        address to,
        uint256 tokenId
    ) public {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.approve(to, tokenId);
    }

    function transferETHByHash(
        string memory ipfsHash,
        address payable _to,
        uint _amount
    ) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        propertyToken.transferETH(_to, _amount);
    }

    function transferETH(address payable _to, uint _amount) public {
        require(
            address(this).balance >= _amount,
            "Insufficient balance in contract"
        );
        _to.transfer(_amount);
        emit Transferred(_to, _amount);
    }

    function distributeBalance(string memory ipfsHash) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);

        uint256 totalSupply = propertyToken.totalSupply();
        require(totalSupply > 0, "No tokens to distribute");

        uint256 contractBalance = address(propertyToken).balance;
        require(contractBalance > 0, "No balance to distribute");

        uint256 amountPerOwner = contractBalance / totalSupply;
        require(amountPerOwner > 0, "Not enough balance to distribute");

        for (uint256 i = 0; i < totalSupply; i++) {
            address payable owner = payable(propertyToken.ownerOf(i));
            propertyToken.transferETH(owner, amountPerOwner);
        }

        emit DistributedBalance(
            ipfsHash,
            true,
            propertyToken.name(),
            contractBalance,
            totalSupply,
            propertyToken.tokenURI(0)
        );
    }

    function getPropertyByHash(
        string memory ipfsHash
    ) private view returns (PropertyToken) {
        PropertyToken propertyToken = propertyMap[ipfsHash];
        require(address(propertyToken) != address(0), "Not exist");
        return propertyToken;
    }
}