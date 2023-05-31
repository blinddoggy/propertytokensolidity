// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./PropertyToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract PropertyMaster is Ownable {
    //Native Token implementation
    event Received(address, uint);
    event Transferred(address to, uint amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }   

    mapping(string => PropertyToken) private propertyMap;
    mapping(address => bool) public hasReceivedTransfer;
    uint256 distributeBalanceDate;
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
        address nftAddress,
        string indexed ipfsHash,
        string name,
        uint256 timestamp,
        string srcImage
    );
    event TransferredErc721(
        string name,
        address from,
        address to,
        string indexed ipfsHash
    );

    event DistributedBalance(
        bool success,
        string name,
        uint256 balance,
        uint256 totalSupply,
        string indexed ipfsHash,
        string srcImage
    );


    function getProject(
    string memory ipfsHash
    //address addressOfTheERC20Token

) public view returns (Proyecto memory) {
    PropertyToken propertyToken = getPropertyByHash(ipfsHash);
    //ERC20 erc20Token = ERC20(addressOfTheERC20Token);
    //uint256 balanceERC20 = erc20Token.balanceOf(address(propertyToken));
    
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
        emit NewPropertyCreated(
            address(ppt),
            ipfsHash,
            ppt.name(),
            block.timestamp,
            baseUri
        );
        return (address(ppt), ipfsHash);
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
        emit TransferredErc721(propertyToken.name(), from, to, ipfsHash);
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

  

    // This function sends ETH from the PropertyToken's balance
    function transferETHByHash(string memory ipfsHash, address payable _to, uint _amount) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
         propertyToken.transferETH(_to, _amount);
    }


    //Transfer Native Token
    function transferETH(address payable _to, uint _amount) public {
        require(address(this).balance >= _amount, "Insufficient balance in contract");
        _to.transfer(_amount);
        emit Transferred(_to, _amount);
    }

    //function distribute balance
    function distributeBalance( string memory ipfsHash) public  onlyOwner{

        PropertyToken propertyToken = getPropertyByHash(ipfsHash);

        uint256 totalSupply = propertyToken.totalSupply();
        require(totalSupply > 0, "No tokens to distribute");

        uint256 contractBalance = address(propertyToken).balance;
        require(contractBalance > 0, "No balance to distribute");

        uint256 amountPerOwner = contractBalance / totalSupply;
        require(amountPerOwner > 0, "Not enough balance to distribute");

        // Iterate through all tokenIds owned by the contract
        for (uint256 i = 0; i < totalSupply; i++) {
            address payable owner = payable(propertyToken.ownerOf(i));
            // transfer the fund to the owner
            propertyToken.transferETH(owner, amountPerOwner);
            
        }

        emit DistributedBalance(
            true,
            propertyToken.name(),
            contractBalance,
            totalSupply,
            ipfsHash,
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