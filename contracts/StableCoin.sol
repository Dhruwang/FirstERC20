// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";

contract StableCoin is ERC20{

    DepositorCoin public depositorCoin;
    uint256 public feeRatePercentage;
    Oracle public oracle;

    uint256 public constant INITIAL_COLLATERAL_RATIO_PERCENTAGE = 10;

    constructor(uint256 _feeRatePercentage, Oracle _oracle)ERC20("stableCoin","STC"){
        feeRatePercentage=_feeRatePercentage;
        oracle = _oracle;
    }

    function mint() external payable{
        uint256 fee = _getFee(msg.value);  
        uint256 remainingEth = msg.value - fee;
        uint256 mintStableCoinAmount = remainingEth * oracle.getPrice();


        _mint(msg.sender, mintStableCoinAmount);
    }
    function burn(uint256 burnStableCoinAmount) external{
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        require(deficitOrSurplusInUsd >= 0,"STC:Cannot burn while in deficit");

        _burn(msg.sender, burnStableCoinAmount);

        uint256 ethRefundAmount = burnStableCoinAmount / oracle.getPrice();
        uint256 fee = _getFee(ethRefundAmount);
        uint256 remainingEth = ethRefundAmount-fee;

        (bool success,) = msg.sender.call{value:remainingEth}("");
        require(success,"STC:Burn refund transaction failed");

    }
    function withdrawCollateralBuffer(uint256 burnDepositorCoinAmount) external{
        require(depositorCoin.balanceOf(msg.sender)>burnDepositorCoinAmount,"STC:Sender has insufficient DPC funds");

        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        require(deficitOrSurplusInUsd > 0, "STC: No funds to withdraw");

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        uint256 dpcInUsdPrice = _getDpcInUsdPrice(surplusInUsd);
        uint256 refundingUsd = burnDepositorCoinAmount / dpcInUsdPrice;
        uint256 refundingEth = refundingUsd / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success , "STC:Withdraw refund transaction failed");


    }
    function _getFee(uint256 ethAmount) private view returns (uint256){
        bool hasDepositors = address(depositorCoin) != address(0) && depositorCoin.totalSupply() >0;
        if(!hasDepositors){
            return 0;
        }

        return (feeRatePercentage * ethAmount)/100;
    }
    function depositColletralBuffer() external payable{
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();

        if(deficitOrSurplusInUsd <= 0){
            uint256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1);
            uint256 usdInEthPrice = oracle.getPrice();
            uint256 deficitInEth = deficitInUsd /usdInEthPrice;

            uint256 requriedInitialSurplusInUsd = (INITIAL_COLLATERAL_RATIO_PERCENTAGE*totalSupply)/100;
            uint256 requriedInitialSurplusInEth = requriedInitialSurplusInUsd/usdInEthPrice;

            require(msg.value >= deficitInEth + requriedInitialSurplusInEth, "STC:Initial collateral ratio not met");

            uint256 newInitialSurplusInEth = msg.value - deficitInEth; 
            uint256 newInitialSurplusInUsd = newInitialSurplusInEth * usdInEthPrice; 

            depositorCoin = new DepositorCoin();
            uint256 mintDepositorCoinAmount2 = newInitialSurplusInUsd;
            depositorCoin.mint(msg.sender, mintDepositorCoinAmount2);
            return;
        }
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        uint256 dpcInUsdPrice = _getDpcInUsdPrice(surplusInUsd);
        uint256 mintDepositorCoinAmount = (msg.value * dpcInUsdPrice )/oracle.getPrice();
        
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);


    }
    function _getDeficitOrSurplusInContractInUsd() private view returns(int256){

        // to get the balance of contract before minting 
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) * oracle.getPrice();
        uint256 totalStableCoinBalanceInUsd = totalSupply;
        int256 deficitOrSurplus = int256(ethContractBalanceInUsd) - int256(totalStableCoinBalanceInUsd);

        return deficitOrSurplus;
    }
    function _getDpcInUsdPrice(uint256 surplusInUsd) private view returns(uint256){
        return depositorCoin.totalSupply()/surplusInUsd;
    }

}