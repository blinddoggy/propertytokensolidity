// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./PropertyToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract PropertyMaster is Ownable {


    receive() external payable {}

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
        uint256 timestamp
    );
    event TransferredErc721(
        string name,
        address from,
        address to,
        string indexed ipfsHash
    );

    event DistributedBalanceErc20(
        bool succes,
        string name,
        uint256 balance,
        uint256 totalSupply,
        string indexed ipfsHash
    );


function approveTransfer(address tokenAddress, uint256 amount) public {
    IERC20 token = IERC20(tokenAddress);
    require(token.approve(address(this), amount), "Approval failed");
}


function transferTokensToContract(address tokenAddress, uint256 amount) public {
    IERC20 token = IERC20(tokenAddress);
    require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
}


    function receiveTokens(address tokenAddress, uint256 amount) public {
    IERC20 token = IERC20(tokenAddress);
    require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
}

function getERC20Balance(address tokenAddress) public view returns (uint256) {
    IERC20 token = IERC20(tokenAddress);
    return token.balanceOf(address(this));
}

function sendTokens(address tokenAddress, address recipient, uint256 amount) public {
    IERC20 token = IERC20(tokenAddress);
    require(token.transfer(recipient, amount), "Transfer failed");
}


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
            block.timestamp
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

    /*function distributeBalance(
        string memory ipfsHash
    ) public returns (bool success) {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        uint256 totalSupply = propertyToken.totalSupply();
        uint256 contractBalance = address(propertyToken).balance;

        if (totalSupply == 0 || contractBalance == 0) {
            revert("Cannot distribute: totalSupply or contract balance is zero");
        }

        uint256 amountPerOwner = contractBalance / totalSupply;
        if (amountPerOwner == 0) {
            revert("Cannot distribute: contract balance is less than totalSupply, each owner must receive at least 1 wei");
        }

        for (uint256 i = 0; i < totalSupply; i++) {
            address owner = propertyToken.ownerOf(i);
            if (!hasReceivedTransfer[owner]) {
                (bool sent, ) = payable(owner).call{value: amountPerOwner}("");
                require(sent, "Failed to send Ether");
                hasReceivedTransfer[owner] = true;
            }
        }

        distributeBalanceDate = block.timestamp;

        emit DistributedBalanceErc20(
            true,
            propertyToken.name(),
            contractBalance,
            totalSupply,
            ipfsHash
        );

    return true;
}
*/


    function distributeBalance(string memory ipfsHash) public onlyOwner {
        PropertyToken propertyToken = getPropertyByHash(ipfsHash);
        uint256 totalSupply = propertyToken.totalSupply();
        require(totalSupply > 0, "No tokens to distribute");

        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No balance to distribute");

        uint256 amountPerOwner = contractBalance / totalSupply;
        require(amountPerOwner > 0, "Not enough balance to distribute");

        // Iterate through all tokenIds owned by the contract
        for (uint256 i = 1; i <= totalSupply; i++) {
            address owner = propertyToken.ownerOf(i);
            if (!hasReceivedTransfer[owner]) {
                // transfer the fund to the owner
                (bool success, ) = payable(owner).call{value: amountPerOwner}("");
                if (success) {
                    hasReceivedTransfer[owner] = true;
                }
            }
        }
    }
   

    function getPropertyByHash(
        string memory ipfsHash
    ) private view returns (PropertyToken) {
        PropertyToken propertyToken = propertyMap[ipfsHash];
        require(address(propertyToken) != address(0), "Not exist");
        return propertyToken;
    }
}