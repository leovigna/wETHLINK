const MainLink = artifacts.require('MainLink');
const LinkToken = artifacts.require('LinkToken');

module.exports = async callback => {
  const mainLink = await MainLink.deployed();
  const tokenAddress = await mainLink.getChainlinkToken();

  const token = await LinkToken.at(tokenAddress);
  console.log(`Transfering 100 LINK to ${mainLink.address}...`);
  const tx = await token.transfer(mainLink.address, `${100e18}`);
  console.log(`Transfer succeeded! Transaction ID: ${tx.tx}.`);

  const accounts = await web3.eth.getAccounts();
  console.log(`Sending 1 ETH from ${accounts[0]} to ${mainLink.address}.`);
  const result = await web3.eth.sendTransaction({from: accounts[0], to: mainLink.address, value: '1000000000000000000'});
  console.log(`Transfer succeeded! Transaction ID: ${result.transactionHash}.`);

  callback();
}
