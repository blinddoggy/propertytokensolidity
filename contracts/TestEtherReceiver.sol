// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestEtherReceiver {

    // Función de fallback para recibir Ether
    receive() external payable {}

    // Función para ver el balance de Ether en el contrato
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
