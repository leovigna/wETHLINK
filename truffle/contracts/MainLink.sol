pragma solidity 0.4.24;

import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";

import "./Bytes32Helper.sol";

import "./adapters/TimestampAdapterClient.sol";
import "./adapters/DeliveryAdapterClient.sol";
import "./adapters/PlaidAdapterClient.sol";

contract MainLink is
    Ownable, ChainlinkClient,
    TimestampAdapterClient, DeliveryAdapterClient, PlaidAdapterClient, Bytes32Helper {

  uint256 constant public ORACLE_PAYMENT = 1 * LINK;

  constructor(address _link, address _oracle) public Ownable() {
    setChainlinkToken(_link);
    setChainlinkOracle(_oracle);
  }

  function getChainlinkOracle() public view returns (address) {
    return chainlinkOracleAddress();
  }

  function updateChainlinkOracle(address _oracle) public onlyOwner {
    setChainlinkOracle(_oracle);
  }

  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function updateChainlinkToken(address _link) public onlyOwner {
    setChainlinkToken(_link);
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function ethBalance()
    public view returns (uint) {
        return this.balance;
    }

  function linkBalance()
    public view returns (uint) {
        LinkToken token = LinkToken(getChainlinkToken());
        return token.balanceOf(this);
    }

  function () public payable {}

}