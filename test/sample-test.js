const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTGAMEPLAY", function () {
  it("Deploy contract, ", async function () {
    const NFTGAMEPLAY = await ethers.getContractFactory("NFTGAMEPLAY");
    const nftgameplay = await NFTGAMEPLAY.deploy("NFT GAME PLAY","NGP");
    await nftgameplay.deployed();
  });
});
