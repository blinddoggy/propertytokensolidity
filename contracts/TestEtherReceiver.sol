// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ReceiveAndSendEther {
    
    event Received(address, uint);
    event Transferred(address to, uint amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    function transferETH(address payable _to, uint _amount) public {
        require(address(this).balance >= _amount, "Insufficient balance in contract");
        _to.transfer(_amount);
        emit Transferred(_to, _amount);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
