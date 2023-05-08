pragma solidity 0.8.4;

//creating calculator functions
contract calculator {


    function multiply(uint a, uint b) public view returns(uint){
        uint result = a * b;
        return result;
    }

    function sum(uint a, uint b) public view returns(uint){
        uint result = a + b;
        return result;
    }


    function res(uint a, uint b) public view returns(uint){
        uint result = a - b;
        return result;
    }


    function div(uint a, uint b) public view returns(uint){
        uint result = a / b;
        return result;
    }


}