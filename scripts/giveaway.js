/**
 * Wallet lists nft airdrop to
 * @param address address of the wallet
 * @param num   nft count to be airdrop to this address
 * @param type  nft category 1:normal, 2:rare, 3: super, 4: extra
 */

const friends = [{
        address: "0x0CA051175A0DEba6635Df8D6E2Cd8cEb8014Bda4",
        num: 1,
        type: 1
    },{
        address: "0x2482c0A3196fafA2C88769087bfb7b9C2e80b1dd",
        num: 1,
        type: 2
    },{
        address: "0x20ADB97C2b2C67FCc2B8BcA8c54825379597681f",
        num: 1,
        type: 3
    },
];
// Contract address
const contractAddress = "0x2e474737900ab9522a742ac18BFf80808D6811dc";

async function main() {
  const Y0 = await hre.ethers.getContractAt('Y0', contractAddress);

  console.log('Activate the contract');
  const tx = await Y0.setIsActive(true);
  await tx.wait();
  console.log('Contract Activated');

  console.log("Minting start!")
  for(let i = 0; i < friends.length; i++) {
    await Y0.mintByOwner(friends[i].address, friends[i].num, friends[i].type);
    console.log("Airdrop " + friends[i].num + " nft of " + friends[i].type + " type to " + friends[i].address)
  }

  console.log("Minting is complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
