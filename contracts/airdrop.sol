pragma solidity 0.8.4;

contract airDrop{

    constructor()public{}

    uint stakingWallet = 0;

    function plusAirDrop() public payable{
        stakingWallet = stakingWallet + 1;
    }

    function balance()public view returns(uint){
        return(stakingWallet);
    }

}