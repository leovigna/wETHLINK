const MainLink = artifacts.require("MainLink");
const LinkToken = artifacts.require('LinkToken');
const Oracle = artifacts.require('Oracle');

module.exports = async function(deployer) {
  await deployer.deploy(MainLink, LinkToken.address, Oracle.address);
};
