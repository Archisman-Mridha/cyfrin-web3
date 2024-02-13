// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { DSCDeployer } from "../../script/DSCDeployer.s.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { NetworkConfigGetter, ERC20Mock } from "../../script/NetworkConfigGetter.s.sol";
import { Handler } from "./Handlers.t.sol";

contract InvariantsTest is StdInvariant, Test {

    DSCDeployer dscDeployer;
    DecentralizedStableCoin decentralizedStableCoin;
    DSCEngine dscEngine;
    Handler handler;
    NetworkConfigGetter networkConfigGetter;

    address weth;
    address wethToUSDPriceFeed;
    address wbtc;

    function setUp( ) external {
        dscDeployer= new DSCDeployer( );
        (decentralizedStableCoin, dscEngine, networkConfigGetter)= dscDeployer.run( );

        (weth,, wbtc,,)= networkConfigGetter.networkConfig( );

        handler= new Handler(decentralizedStableCoin, dscEngine);
        targetContract(address(handler));
    }

    function invariant__valueOfTotalCollateralDepositMustBeMoreThanTotalSupply( ) public view {
        uint256 totalSupply= decentralizedStableCoin.totalSupply( );

        uint256 totalWethCollateralDeposited= ERC20Mock(weth).balanceOf(address(dscEngine));
        uint256 totalWethCollateralValueInUSD= dscEngine.getCollateralValueInUSD(weth, totalWethCollateralDeposited);

        uint256 totalWbtcCollateralDeposited= ERC20Mock(wbtc).balanceOf(address(dscEngine));
        uint256 totalWbtcCollateralValueInUSD= dscEngine.getCollateralValueInUSD(wbtc, totalWbtcCollateralDeposited);

        uint256 totalCollateralValueInUSD= totalWethCollateralValueInUSD + totalWbtcCollateralValueInUSD;

        assert (totalCollateralValueInUSD >= totalSupply);
    }
}
