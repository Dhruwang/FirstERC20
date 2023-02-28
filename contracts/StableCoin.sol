// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";

contract StableCoin is ERC20{

    DepositorCoin public depositorCoin;
    uint256 private constant ETH_IN_USD_PRICE = 2000;
    uint256 public feeRatePercentage;

    constructor(uint256 _feeRatePercentage)ERC20("stableCoin","STC"){
        feeRatePercentage=_feeRatePercentage;
    }

    function mint() external payable{
        uint256 fee = _getFee(msg.value);  
        uint256 remainingEth = msg.value - fee;
        uint256 mintStableCoinAmount = remainingEth * ETH_IN_USD_PRICE;


        _mint(msg.sender, mintStableCoinAmount);
    }
    function burn(uint256 burnStableCoinAmount) external{
        _burn(msg.sender, burnStableCoinAmount);

        uint256 ethRefundAmount = burnStableCoinAmount / ETH_IN_USD_PRICE;
        uint256 fee = _getFee(ethRefundAmount);
        uint256 remainingEth = ethRefundAmount-fee;

        (bool success,) = msg.sender.call{value:remainingEth}("");
        require(success,"STC:Burn refund transaction failed");

    }
    function _getFee(uint256 ethAmount) private view returns (uint256){
        bool hasDepositors = address(depositorCoin) != address(0) && depositorCoin.totalSupply() >0;
        if(!hasDepositors){
            return 0;
        }

        return (feeRatePercentage * ethAmount)/100;
    }

}