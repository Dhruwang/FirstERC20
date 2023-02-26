// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ERC20{
    uint256 public totalSupply;
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
    }
    //results into less gas
    function decimals() external pure returns (uint8) {
        return 18;
    }
}

