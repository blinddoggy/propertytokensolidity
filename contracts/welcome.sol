pragma solidity >= 0.7.0 < 0.9.0;

contract ThisIsAContract{

    //empty construnctor
    constructor() public{}

    //create a function view
    function getResult() public view returns(uint){
        uint a = 1;
        uint b = 14;
        uint result = a + b;
        return result;
    }


}