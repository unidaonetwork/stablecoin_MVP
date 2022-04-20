pragma solidity ^0.4.24;

contract converter {
    function convertInt(uint256 integer_) public pure  returns(bytes32){
       bytes32  binfo = bytes32(integer_);
       return binfo; 
    }
}