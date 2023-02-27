import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20 } from "../typechain-types";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers"

describe("MyERC20ContractFactory", function(){
    let myERC20Contract : ERC20;
    let someAddress : SignerWithAddress;
    let someOtherAddress : SignerWithAddress;

    beforeEach(async function () {
        const MyERC20ContractFactory = await ethers.getContractFactory("ERC20");
        myERC20Contract = await MyERC20ContractFactory.deploy("Dhruwang","JD");
        await myERC20Contract.deployed()

        someAddress = (await ethers.getSigners())[1]
        someOtherAddress = (await ethers.getSigners())[2]
    });
    describe("When i have 10 tokens",function(){
        beforeEach(async function(){
            //mint 10 tokens
            await myERC20Contract.transfer(someAddress.address,10)
        });
        describe("When i transfer 10 tokens",function(){
            it("should transfer tokens correctly", async function(){
                await myERC20Contract
                .connect(someAddress)
                .transfer(someOtherAddress.address,10)
            expect(await myERC20Contract.balanceOf(someOtherAddress.address))
            .to.equal(10);
            })
        })
        describe("When i transfer 15 tokens",function(){
            it("should transfer tokens correctly", async function(){
                await expect(myERC20Contract
                .connect(someAddress)
                .transfer(someOtherAddress.address,15)
            ).to.be.revertedWith("ERC20: transfer amount exceeds balance")
            })
        })
        
    })
    
})