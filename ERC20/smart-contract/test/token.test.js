const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("MusicalToken Contract", function(){
  let tokenContract , owner, user1, user2
  beforeEach(async function(){
    [owner,user1,user2] = await ethers.getSigners();
    const TokenContract = await ethers.getContractFactory("RPGtoken20");
    tokenContract = await upgrades.deployProxy(TokenContract,["Tushar","TBA",1,5,1],{initializer:"initialize",});
    await tokenContract.waitForDeployment();
    console.log(`Contract Address ${tokenContract.target}`)
  })
  it("Should mint",async function(){
    expect(await tokenContract.connect(owner).mint(1))
    expect(await tokenContract.balanceOf(tokenContract.target)).to.equal(ethers.parseEther("2"))
  })
  it("Should send a first time sender 5 tokens", async function(){
    expect(await tokenContract.connect(user1).ClaimFreeTokens()).to.emit(tokenContract,"claimedFeeToken").withArgs(user1.address);
    //await tokenContract.connect(user1).ClaimFreeTokens()
    console.log(await tokenContract.getDetails());
  })
  it("Should transfer token to the sender after correct payment",async function(){
    expect (await tokenContract.connect(user1).payAndClaimToken({value:1}));
    console.log(await tokenContract.getDetails());
  })
})