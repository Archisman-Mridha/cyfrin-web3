// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { DSCDeployer } from "../../script/DSCDeployer.s.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { NetworkConfigGetter, ERC20Mock } from "../../script/NetworkConfigGetter.s.sol";

contract DSCEngineTest is Test {

    DSCDeployer dscDeployer;
    DecentralizedStableCoin decentralizedStableCoin;
    DSCEngine dscEngine;
    NetworkConfigGetter networkConfigGetter;

    address weth;
    address wethToUSDPriceFeed;
    address wbtc;

    address USER= makeAddr("user");
    uint256 public constant INITIAL_WETH_BALANCE= 10 ether;
    uint256 public constant INITIAL_WBTC_BALANCE= 10 ether;

    modifier depositCollateral(address collateralToken, uint256 amount) {
        vm.startPrank(USER);

        ERC20Mock(collateralToken).approve(address(dscEngine), amount);
        dscEngine.depositCollateral(collateralToken, amount);

        vm.stopPrank( );
        _;
    }

    function setUp( ) public {
        dscDeployer= new DSCDeployer( );
        (decentralizedStableCoin, dscEngine, networkConfigGetter)= dscDeployer.run( );

        (weth, wethToUSDPriceFeed, wbtc,,)= networkConfigGetter.networkConfig( );

        ERC20Mock(weth).mint(USER, INITIAL_WETH_BALANCE);
        ERC20Mock(wbtc).mint(USER, INITIAL_WBTC_BALANCE);
    }

    // -- Tests for depositCollateral --

    address[ ] collateralTokenAddresses;
    address[ ] priceFeedAddresses;
    // When initializing, the DSCEngine contract, if the length of collateralTokenAddresses and
    // priceFeedAddresses aren't equal, then, a revert with error
    // DSCEngine__CollateralTokenAddressesAndPriceFeedAddressesMustHaveSameLength
    // should occur.
    function test__revertIfLengthsOfTokenAddressesAndPriceFeedAddressesDoesntMatch( ) public {
        collateralTokenAddresses.push(weth);
        collateralTokenAddresses.push(wbtc);
        priceFeedAddresses.push(wethToUSDPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__CollateralTokenAddressesAndPriceFeedAddressesMustHaveSameLength.selector);

        new DSCEngine(collateralTokenAddresses, priceFeedAddresses, address(decentralizedStableCoin));
    }

    function test__revertIfCollateralDepositAmountIsZero( ) public {
        vm.startPrank(USER); // msg.sender (which is DSCEngineTest) pretends to be USER.

        ERC20Mock(weth).approve(address(dscEngine), 0 ether);

        vm.expectRevert(DSCEngine.DSCEngine__AmountMustBeMoreThanZero.selector);
        dscEngine.depositCollateral(weth, 0);

        vm.stopPrank( );
    }

    function test__revertIfDepositingUnknownTypeOfCollateral( ) public {
        ERC20Mock unknownToken= new ERC20Mock("Unknown", "UNK");
        unknownToken.mint(USER, 1 ether);

        vm.startPrank(USER);

        vm.expectRevert(DSCEngine.DSCEngine__CollateralTokenNotAllowed.selector);
        dscEngine.depositCollateral(address(unknownToken), INITIAL_WETH_BALANCE);

        vm.stopPrank( );
    }

    function test_depositCollateral( ) public
        depositCollateral(weth, INITIAL_WETH_BALANCE)
    {
        uint256 expectedDSCMinted= 0;
        uint256 expectedDepositedCollateralValueInUSD= dscEngine.getCollateralValueInUSD(weth, INITIAL_WETH_BALANCE);

        (uint256 actualDSCMinted, uint256 actualDepositedCollateralValueInUSD)= dscEngine.getUserInformation(USER);
        assertEq(actualDSCMinted, expectedDSCMinted);
        assertEq(actualDepositedCollateralValueInUSD, expectedDepositedCollateralValueInUSD);
    }

    // -- Tests for getCollateralValueInUSD --

    function test__getCollateralValueInUSD( ) public {
        uint256 currentEthRateInUSD= 2000;
        uint256 ethAmount= 15e18;
        uint256 expectedValueInUSD= ethAmount * currentEthRateInUSD;

        uint256 actualValueInUSD= dscEngine.getCollateralValueInUSD(weth, ethAmount);
        assertEq(actualValueInUSD, expectedValueInUSD);
    }

    // -- Tests for getDepositedCollateralValueInUSD --

    function test__getDepositedCollateralValueInUSD( ) public {
        // Since 1 USD = 1 ether unit (or 1e18 wei unit) of DSC, 100 USD = 100 ether.
        uint256 usdAmount= 100 ether;
        // If rate of ETH is 2000 USD,
        // then 100 USD will be the price of 0.05 ether.
        uint256 expectedWethAmount= 0.05 ether;

        uint256 actualWethAmount= dscEngine.getCollateralTokenAmountWorthUSD(weth, usdAmount);
        assertEq(actualWethAmount, expectedWethAmount);
    }
}
