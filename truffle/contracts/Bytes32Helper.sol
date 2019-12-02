pragma solidity 0.4.24;

contract Bytes32Helper {
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

  function bytes32ToString(bytes32 source) private pure returns (string result) {
    bytes memory tempBytes = new bytes(32);
    for (uint256 byteNdx; byteNdx < 32; ++byteNdx) {
      tempBytes[byteNdx] = source[byteNdx];
    }

    return string(tempBytes);
  }

  function toBytes(address a) public pure returns (bytes result) {
    return abi.encodePacked(a);
  }

}