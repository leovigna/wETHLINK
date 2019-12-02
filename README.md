# wETHLINK: Proof of Concept Chainlink token abstraction
DISCLAIMER: This is just a Proof of Concept at the moment and not ready for mainnet launch.
This project accompanies my "Chainlink to infinity, LINK to zero: The risks of token abstraction" article. Is is meant to show the possibility of launching a Chainlink Oracle network relying on ETH instead of using LINK. Special thanks to the Chainlink team for developing this great product and to the DeliveryLink [workshop](https://github.com/danforbes/delivery-link) project, a project I forked to get started with Chainlink a couple days ago 11/28/2019.

The three main components of the Chainlink Oracle network that we modify are:
* The incentive token: Modify 50 lines of solidity to make the token pegged. See [LinkTokenPegged.sol](./truffle/contracts/LinkTokenPegged.sol). We call this new token, (or *interface wrapper* as I like to call it), wETHLINK (similarly to wETH which is a wrapped ERC-20 token contract used by Dai, Gnosis and other projects).
* The Chainlink node: Change two environment variables to point to the pegged token contract.
* The client contract: No code change is required. Just need to point to the right Oracle by calling `setChainlinkOracle()`.

# TO DO
More instructions on how to run a Chainlink node that uses wETHLINK will be provided. I'd suggest reading the existing [documentation](https://docs.chain.link/docs/running-a-chainlink-node) provided by Chainlink. If you fully understand how running a Chainlink node works, you probably can see how using wETHLINK would be no different than using LINK as the interfaces are the same. All you have to do is point to the right token contract address. This would be the `LINK_CONTRACT_ADDRESS` in the environment variables.