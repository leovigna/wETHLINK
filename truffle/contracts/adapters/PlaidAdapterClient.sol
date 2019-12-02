pragma solidity 0.4.24;


import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";

contract PlaidAdapterClient is Ownable, ChainlinkClient {
    uint256 constant public ORACLE_PAYMENT = 1 * LINK;
    string public plaidJobId;
    bytes32 public plaidResponse;

    event PlaidResponseReceived(
        bytes32 indexed requestId,
        bytes32 indexed response
    );

    function setPlaidJobId(string _plaidJobId) public onlyOwner {
    plaidJobId = _plaidJobId;
  }

    function requestPlaid(string _extPath, string _copyPath)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(plaidJobId), this, this.handlePlaidResponse.selector);
    req.addBytes("public_key", toBytes(msg.sender));
    req.add("extPath", _extPath);
    req.add("copyPath", _copyPath);

    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }

  function handlePlaidResponse(bytes32 _requestId, bytes32 _response)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit PlaidResponseReceived(_requestId, _response);
    plaidResponse = _response;
  }

  function bytes32ToString(bytes32 source) private pure returns (string result);
  function stringToBytes32(string memory source) private pure returns (bytes32 result);

  function toBytes(address a) public pure returns (bytes result);

}