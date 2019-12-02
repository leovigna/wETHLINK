pragma solidity 0.4.24;

import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";

contract DeliveryAdapterClient is Ownable, ChainlinkClient {
  uint256 constant public ORACLE_PAYMENT = 1 * LINK;
  string public deliveryStatusJobId;
  string public deliveryStatus;

  event DeliveryStatusResponseReceived(
    bytes32 indexed requestId,
    string indexed deliveryStatus
  );

  function setDeliveryStatusJobId(string _deliveryStatusJobId) public onlyOwner {
    deliveryStatusJobId = _deliveryStatusJobId;
  }


  function requestDeliveryStatus(string _packageCarrier, string _packageCode)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(deliveryStatusJobId), this, this.handleDeliveryStatusResponse.selector);
    req.add("car", _packageCarrier);
    req.add("code", _packageCode);
    req.add("copyPath", "status");
    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }

  function handleDeliveryStatusResponse(bytes32 _requestId, bytes32 _deliveryStatus)
    public
    recordChainlinkFulfillment(_requestId)
  {
    deliveryStatus = bytes32ToString(_deliveryStatus);
    emit DeliveryStatusResponseReceived(_requestId, deliveryStatus);
  }
  
  function bytes32ToString(bytes32 source) private pure returns (string result);
  function stringToBytes32(string memory source) private pure returns (bytes32 result);

}