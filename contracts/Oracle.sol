// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Oracle {
    address public owner;
    uint256 private price;

    constructor (){
        owner = msg.sender;
    }
    function getPrice() external view returns(uint256){
        return price;
    }
    function setPrice(uint newPrice) external{
        require(msg.sender == owner,"Oracle: Only owner can set price");
        price = newPrice ;

    }
}