pragma solidity >=0.4.21 <0.6.0;

import 'link_token/contracts/ERC677Token.sol';
import 'link_token/contracts/token/linkStandardToken.sol';

contract LinkTokenPegged is linkStandardToken, ERC677Token {

  string public constant name = 'ChainLink Token Pegged';
  uint8 public constant decimals = 18;
  string public constant symbol = 'LINKWETH';
  uint public constant rate = 100;

  event MintBurn(address indexed addr, uint value, bool mint);

  constructor () {
      totalSupply = 0;
  }

  /**
  * @dev transfer token to a specified address with additional data if the recipient is a contract.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  * @param _data The extra data to be passed to the receiving contract.
  */
  function transferAndCall(address _to, uint _value, bytes _data)
    public
    validRecipient(_to)
    returns (bool success)
  {
    return super.transferAndCall(_to, _value, _data);
  }

  /**
  * @dev transfer token to a specified address.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value)
    public
    validRecipient(_to)
    returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value)
    public
    validRecipient(_spender)
    returns (bool)
  {
    return super.approve(_spender,  _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value)
    public
    validRecipient(_to)
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  // 1-ETH Peg
  /**
    * @dev mint tokens using eth.
    */
    function mintEthToLink()
    public payable returns (bool) {
        uint link_value = msg.value.mul(rate);
        balances[msg.sender] = balances[msg.sender].add(link_value);
        totalSupply = totalSupply.add(link_value);
        emit MintBurn(msg.sender, link_value, true);
        return true;
    }

    /**
    * @dev burn tokens using link.
    * @param _value The amount to be burnt.
    */
    function burnLinkToEth(uint _value)
    public returns (bool) {
        require(_value <= balances[msg.sender], "Invalid balance");
        uint eth_value = _value.div(rate);
        msg.sender.transfer(eth_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit MintBurn(msg.sender, _value, false);
        return true;
    }

    function ethBalance()
    public view returns (uint) {
        return this.balance;
    }

  // MODIFIERS

  modifier validRecipient(address _recipient) {
    require(_recipient != address(0) && _recipient != address(this));
    _;
  }

}