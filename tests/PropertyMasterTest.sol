// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/PropertyMaster.sol";
import "../contracts/PropertyToken.sol";

contract PropertyMasterTest {
    
    PropertyMaster propertyMaster;
    PropertyToken propertyToken;
    address owner;
    address recipient;
    string ipfsHash = "QmExampleHash";
    
    function beforeAll () public {
        propertyMaster = new PropertyMaster();
        propertyToken = new PropertyToken("PropertyToken", "PPT", ipfsHash);
        propertyMaster.createNewProperty("PropertyToken", "PPT", ipfsHash, 10, "baseUriExample");
        owner = TestsAccounts.getAccount(0);
        recipient = TestsAccounts.getAccount(1);
    }

    function checkCreateNewProperty() public {
        Proyecto memory project = propertyMaster.getProject(ipfsHash);
        Assert.equal(project.name, "PropertyToken", "Name should be PropertyToken");
        Assert.equal(project.symbol, "PPT", "Symbol should be PPT");
        Assert.equal(project.img, "baseUriExample0", "img should be baseUriExample0");
        Assert.equal(project.balanceERC721, 10, "balanceERC721 should be 10");
    }

    function checkTransferErc721() public {
        propertyMaster.transferErc721(ipfsHash, owner, recipient);
        uint256 balance = propertyToken.balanceOf(recipient);
        Assert.equal(balance, 1, "Balance should be 1 after transfer");
    }

    function checkDistributeBalanceErc20() public {
        propertyMaster.distributeBalanceErc20(ipfsHash);
        uint256 balance = address(propertyMaster).balance;
        Assert.equal(balance, 0, "Balance should be 0 after distribute");
    }
}
