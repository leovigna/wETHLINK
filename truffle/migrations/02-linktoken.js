let LinkToken = artifacts.require('LinkToken');

module.exports = async (deployer) => {
  await deployer.deploy(LinkToken);
  const accounts = await web3.eth.getAccounts();

  const token = await LinkToken.deployed();

  // Standard Token Mints 1 billion tokens, assigned to owner
  // Pegged Token starts at 0
  // Sending ETH mints tokens, Burning Tokens returns same ETH, thus maintaining the two-way peg
  // For convenience, we use a fixed rate of 1 ETH = 1000000 LINK
  // All other routines should behave normally
  console.log(`Minting 100 LINK with 1 ETH from ${accounts[0]} to ${LinkToken.address}.`);
  const result = await token.mintEthToLink({from: accounts[0], value: '1000000000000000000'});
  console.log(`Minting succeeded! Transaction ID: ${result.tx}.`);
};