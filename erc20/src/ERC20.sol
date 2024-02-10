// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// An ERC20 is a smart contract that represents a token collection. It follows the ERC20 standard
// explained here - https://eips.ethereum.org/EIPS/eip-20.
contract ERC20 {
  mapping(address user => uint256 tokenAmountOwned) private s_balances;

  // Returns the name of the token.
  function name( ) public view returns (string) {
    return "Archi's Token"
  }

  // Returns the number of decimals the token uses.
  function decimals( ) public view returns (uint8) {
    return 18;
  }

  // Returns the total token supply.
  function totalSupply( ) public pure returns (uint256) {
    return 100 ether; // 100 * (10^18)
  }

  // Returns the account balance of another account with address _owner.
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return s_balances[_owner];
  }

  // Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. The function
  // SHOULD throw if the message caller’s account balance does not have enough tokens to spend.
  // Note - Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
  function transfer(address _to, uint256 _value) public returns (bool success) {
    uint256 previousBalancesSummed= balanceOf(msg.sender) + balanceOf(_to);

    s_balances[_from] -= _amount;
    s_balances[_to] += _amount;

    require(balanceOf(_from) + balanceOf(_to) == previousBalancesSummed);
  }
}