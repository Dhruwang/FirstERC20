// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {ERC20} from "./ERC20.sol";

contract DepositorCoin is ERC20{

    address public owner;

    constructor ()ERC20("depositorCoin","DPC"){
        owner = msg.sender;
        
    }

    function mint(address to,uint256 amount) external{
        require(msg.sender==owner,"ERC20: only owner can mint");
        _mint(to, amount);
    }
    function burn(address from,uint256 amount) external{
        require(msg.sender==owner,"ERC20: only owner can burn");
        _burn(from, amount);
    }

}