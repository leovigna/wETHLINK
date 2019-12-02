const clUtils = require('../../chainlink/cl-utils');

const MainLink = artifacts.require('MainLink');
const Oracle = artifacts.require('Oracle');

module.exports = async callback => {
  const oracle = await Oracle.deployed();

  // Timestamp
  const timestampJob = clUtils.createJob('runlog');
  timestampJob.initiators[0].params.address = oracle.address;
  timestampJob.tasks.push(clUtils.createTask('httpget'));
  timestampJob.tasks.push(clUtils.createTask('jsonparse'));
  timestampJob.tasks.push(clUtils.createTask('ethuint256'));
  timestampJob.tasks.push(clUtils.createTask('ethtx'));
  console.log('Creating timestamp job on Chainlink node...');
  const timestampJobRes = await clUtils.postJob(timestampJob);
  console.log(`Job created! Job ID: ${timestampJobRes.data.id}.`);

  console.log('Adding timestamp job ID to MainLink contract...');
  const mainLink = await MainLink.deployed();
  const timestampJobIdTx = await mainLink.setTimestampJobId(timestampJobRes.data.id);
  console.log(`Timestamp job ID added to contract! Transaction ID: ${timestampJobIdTx.tx}.`);

  // EasyPost
  console.log('Creating EasyPost bridge on Chainlink node...');
  const easyPostBridge = clUtils.createBridge('easypost', 'http://easypost:6221');
  const easyPostBridgeRes = await clUtils.postBridge(easyPostBridge);
  console.log(`Bridge created! Bridge ID: ${easyPostBridgeRes.data.id}.`);

  const easyPostJob = clUtils.createJob('runlog');
  easyPostJob.initiators[0].params.address = oracle.address;
  easyPostJob.tasks.push(clUtils.createTask('easypost'));
  easyPostJob.tasks.push(clUtils.createTask('copy'));
  easyPostJob.tasks.push(clUtils.createTask('ethbytes32'));
  easyPostJob.tasks.push(clUtils.createTask('ethtx'));
  console.log('Creating EasyPost job on Chainlink node...');
  const easyPostJobRes = await clUtils.postJob(easyPostJob);
  console.log(`Job created! Job ID: ${easyPostJobRes.data.id}.`);

  console.log('Adding delivery status job ID to MainLink contract...');
  const deliveryStatusJobIdTx = await mainLink.setDeliveryStatusJobId(easyPostJobRes.data.id);
  console.log(`Delivery status job ID added to contract! Transaction ID: ${deliveryStatusJobIdTx.tx}.`);

  // Plaid
  console.log('Creating Plaid bridge on Chainlink node...');
  const plaidBridge = clUtils.createBridge('plaid', 'http://plaid:6222');
  const plaidBridgeRes = await clUtils.postBridge(plaidBridge);
  console.log(`Bridge created! Bridge ID: ${plaidBridgeRes.data.id}.`);

  const plaidJob = clUtils.createJob('runlog');
  plaidJob.initiators[0].params.address = oracle.address;
  plaidJob.tasks.push(clUtils.createTask('plaid'));
  plaidJob.tasks.push(clUtils.createTask('copy'));
  plaidJob.tasks.push(clUtils.createTask('ethbytes32'));
  plaidJob.tasks.push(clUtils.createTask('ethtx'));
  console.log('Creating Plaid job on Chainlink node...');
  const plaidJobRes = await clUtils.postJob(plaidJob);
  console.log(`Job created! Job ID: ${plaidJobRes.data.id}.`);

  console.log('Adding delivery status job ID to MainLink contract...');
  const plaidJobResIdTx = await mainLink.setPlaidJobId(plaidJobRes.data.id);
  console.log(`Plaid job ID added to contract! Transaction ID: ${plaidJobResIdTx.tx}.`);


  callback();
}
