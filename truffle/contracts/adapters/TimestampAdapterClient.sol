pragma solidity 0.4.24;

import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";

import "../LinkToken.sol";

contract TimestampAdapterClient is Ownable, ChainlinkClient {
  uint256 constant public ORACLE_PAYMENT = 1 * LINK;
  string public timestampJobId;
  uint256 public timestamp;

  event TimestampResponseReceived(
    bytes32 indexed requestId,
    uint256 indexed timestamp
  );

  function setTimestampJobId(string _timestampJobId) public onlyOwner {
    timestampJobId = _timestampJobId;
  }

  function requestCurrentTimestamp()
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(timestampJobId), this, this.handleTimestampResponse.selector);
    req.add("get", "http://worldtimeapi.org/api/timezone/Europe/London");
    req.add("path", "unixtime");
    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }
  
  /**
  @dev Mint version, mints Pegged Link token immediately, using contract ETH Balance
  */
  function requestCurrentTimestampMint()
    public
    onlyOwner
  {
    LinkToken token = LinkToken(getChainlinkToken());
    uint rate = token.rate();
    uint eth_val = ORACLE_PAYMENT.div(rate);
    token.mintEthToLink.value(eth_val)(); // Converts enough ETH to LINKWETH
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(timestampJobId), this, this.handleTimestampResponse.selector);
    req.add("get", "http://worldtimeapi.org/api/timezone/Europe/London");
    req.add("path", "unixtime");
    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }

  function handleTimestampResponse(bytes32 _requestId, uint256 _timestamp)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit TimestampResponseReceived(_requestId, _timestamp);
    timestamp = _timestamp;
  }

  function bytes32ToString(bytes32 source) private pure returns (string result);
  function stringToBytes32(string memory source) private pure returns (bytes32 result);

  function getChainlinkToken() public view returns (address);

}