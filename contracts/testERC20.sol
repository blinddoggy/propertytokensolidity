// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract testERC20 {
    function receiveTokens(IERC20 token, uint256 amount) public {
        // Solicita al remitente que envíe `amount` tokens a este contrato
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function getBalance(IERC20 token) public view returns (uint256) {
        // Devuelve el saldo de tokens de este contrato
        return token.balanceOf(address(this));
    }

    function sendTokens(IERC20 token, address recipient, uint256 amount) public {
        // Envia `amount` tokens desde este contrato al destinatario especificado
        require(token.transfer(recipient, amount), "Transfer failed");
    }
}
