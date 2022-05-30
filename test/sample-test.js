const { parse } = require("@ethersproject/transactions");
const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("GoldToken Crowd Sale", function () {

  it("Deployment", async function () {
    const ERC20 = await ethers.getContractFactory("GoldToken");
    const token = await ERC20.deploy();
    await token.deployed();

    expect(await token.name()).to.equal("Gold Token");

    expect(await token.symbol()).to.equal("GOLD");

  });
  it("Checking Total Supply", async function () {
    const ERC20 = await ethers.getContractFactory("GoldToken");
    const token = await ERC20.deploy();
    await token.deployed();
    expect(await token.totalSupply()).to.equal('10000000000000000000000000000000');
    expect(await token.balanceOf(token.address)).to.equal(await token.totalSupply())
  });

  it("Checking CrowdSale", async function () {
    const accounts = await hre.ethers.getSigners();
    const ERC20 = await ethers.getContractFactory("GoldToken");
    const token = await ERC20.deploy();
    await token.deployed();
/* 
globals BigInt */
    const tx = await token.connect(accounts[0]).crowdSale({value: 1000000});
    expect(await token.balanceOf(accounts[0].address)).to.equal(1000000*1000);    
  });
  it("Checking 0.5 ETH Limit CrowdSale", async function () {
    const accounts = await hre.ethers.getSigners();
    const ERC20 = await ethers.getContractFactory("GoldToken");
    const token = await ERC20.deploy();
    await token.deployed();
/* 
globals BigInt */
await expect( token.connect(accounts[0]).crowdSale({value: parseEther('0.51')})).to.reverted;
  });
})
