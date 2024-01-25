// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20, ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/*
    RELATIVE STABILITY - pegged / anchored to USD.

    STABILITY MECHANISM (minting and burning authority) - Algorithm. This contract is just the ERC20
    implementation of our stablecoin system and is governed by the DSCEngine contract.

    COLLATERAL (exogenous) - ETH and BTC
*/
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    constructor( )
        ERC20("DecentralizedStableCoin", "DSC")
        Ownable(msg.sender)
    { }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance= balanceOf(msg.sender);

        if(_amount <= 0)
            revert DecentralizedStableCoin__AmountMustBeMoreThanZero( );

        else if(balance < _amount)
            revert DecentralizedStableCoin__BurnAmountExceedsBalance( );

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool) {
        if(_to == address(0))
            revert DecentralizedStableCoin__CantMintToZeroAddress( );

        else if(_amount <= 0)
            revert DecentralizedStableCoin__AmountMustBeMoreThanZero( );

        _mint(_to, _amount);
        return true;
    }

    // -- ERRORS --

    error DecentralizedStableCoin__AmountMustBeMoreThanZero( );
    error DecentralizedStableCoin__BurnAmountExceedsBalance( );
    error DecentralizedStableCoin__CantMintToZeroAddress( );
}
