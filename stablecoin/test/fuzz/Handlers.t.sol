// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { ERC20Mock } from "../../script/NetworkConfigGetter.s.sol";

contract Handler is Test {

    DecentralizedStableCoin decentralizedStableCoin;
    DSCEngine dscEngine;

    address weth;
    address wbtc;

    uint256 MAX_COLLATERAL_DEPOSIT_AMOUNT= type(uint96).max;

    constructor(DecentralizedStableCoin _decentralizedStableCoin, DSCEngine _dscEngine) {
        decentralizedStableCoin= _decentralizedStableCoin;
        dscEngine= _dscEngine;

        address[ ] memory collateralTokenAddresses= dscEngine.getCollateralTokenAddresses( );
        weth= collateralTokenAddresses[0];
        wbtc= collateralTokenAddresses[1];
    }

    function depositCollateral(uint256 randomCollateralTokenAddressSeed, uint256 randomCollateralAmount) public {
        address randomCollateralTokenAddress= _getRandomCollateralTokenAddressFromSeed(randomCollateralTokenAddressSeed);
        uint256 boundedRandomCollateralAmount= bound(randomCollateralAmount, 1, MAX_COLLATERAL_DEPOSIT_AMOUNT);

        vm.startPrank(msg.sender);
        ERC20Mock randomCollateralToken= ERC20Mock(randomCollateralTokenAddress);
        randomCollateralToken.mint(msg.sender, randomCollateralAmount);
        randomCollateralToken.approve(address(dscEngine), randomCollateralAmount);

        dscEngine.depositCollateral(
            randomCollateralTokenAddress,
            boundedRandomCollateralAmount
        );
    }

    function redeemCollateral(uint256 randomCollateralTokenAddressSeed, uint256 randomCollateralAmount) public {
        address randomCollateralTokenAddress= _getRandomCollateralTokenAddressFromSeed(randomCollateralTokenAddressSeed);
        uint256 boundedRandomCollateralAmount= bound(randomCollateralAmount,
                                                     0,
                                                     dscEngine.getDepositedCollateralAmountOfUser(msg.sender, randomCollateralTokenAddress));
        if(boundedRandomCollateralAmount == 0)
            return;

        dscEngine.redeemCollateral(randomCollateralTokenAddress, boundedRandomCollateralAmount);
    }

    function _getRandomCollateralTokenAddressFromSeed(uint256 randomCollateralTokenAddressSeed) private view returns(address) {
        if(randomCollateralTokenAddressSeed % 2 == 0)
            return weth;

        else return wbtc;
    }
}
