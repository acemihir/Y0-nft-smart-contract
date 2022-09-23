/**
 * Wallet lists nft airdrop to
 * @param address address of the wallet
 * @param num   nft count to be airdrop to this address
 * @param type  nft category 1:normal, 2:rare, 3: super, 4: extra
 */

const friends = [{
        address: "0xED73B318fd09AD932E0630eacBB27648BD018113",
        num: 1,
        type: 1
    },{
        address: "0xb0c1e53c7aF763DE8bC669E5C63Ae8EB6b8F8b43",
        num: 1,
        type: 1
    },{
        address: "0x176B6eB693792Ad7081E25B537D8E14bea130Ff8",
        num: 1,
        type: 1
    },
];
// Contract address
const contractAddress = "0xdf3737a09E5D2bce4AaDbaB98c7cb2932f7c7dC2";

async function main() {
  const Y0 = await hre.ethers.getContractAt('Y0', contractAddress);

  console.log('Activate the contract');
  const tx = await Y0.setIsActive(true);
  await tx.wait();
  console.log('Contract Activated');

  console.log("Minting start!")
  for(let i = 0; i < friends.length; i++) {
    await Y0.mintByOwner(friends[i], 1, 1);
    console.log("Airdrop 1 nft of first type to " + friends[i])
  }

  console.log("Minting is complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
