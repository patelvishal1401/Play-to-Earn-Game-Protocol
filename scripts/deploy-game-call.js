// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {



    const NFTGAMEPLAY = await hre.ethers.getContractFactory("NFTGAMEPLAY");

    const contract = await NFTGAMEPLAY.attach(
        "" // The deployed contract address
      );

       console.log("Mint Details",  await contract.mint(1));       // Pass Character id, 0,1
       console.log("Heal Details",  await contract.heal(0));     // Pass token id and heal character
       console.log("Fight Details",  await contract.fight(5,1));    // Fight between two character


       console.log("Token Details",  await contract.getTokenDetails(1));   // pass token id to get character details

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
