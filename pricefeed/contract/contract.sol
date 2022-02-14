pragma solidity ^0.4.24;

contract pricefeed {
    uint256 public EPrice;
    uint256 public XPrice;
    address public owner;
    address public authority;

   constructor() public{
        owner = msg.sender;
        
    }
 function setEcoinPrice(uint256 price_) public returns(uint256){
     require(msg.sender==authority);
     require(authority!=0x0000000000000000000000000000000000000000);
     EPrice = price_;
    
 }
  function setXDCPrice(uint256 price_) public returns(uint256){
     require(msg.sender==authority);
     require(authority!=0x0000000000000000000000000000000000000000);
     XPrice = price_;
    
 }
 function setAuthority(address auth) public  returns(address){
     require(msg.sender==owner);
     authority = auth;
     return   auth;
 }
 function getEcoinPrice() public view returns(uint256) {
     return EPrice;
 }
 function getXDCPrice() public view returns(uint256) {
     return XPrice;
 }
}