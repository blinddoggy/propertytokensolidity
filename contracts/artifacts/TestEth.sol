// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TestEth {
    
    event Received(address, uint);
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    // Esta función devuelve el balance del contrato.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
