// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Script } from "forge-std/Script.sol";
import { DecentralizedStableCoin } from "../src/DecentralizedStableCoin.sol";
import { DSCEngine } from "../src/DSCEngine.sol";
import { NetworkConfigGetter } from "./NetworkConfigGetter.s.sol";

contract DSCDeployer is Script {
    address[ ] public collateralTokenAddresses;
    address[ ] public priceFeedAddresses;

    function run( ) external returns(DecentralizedStableCoin, DSCEngine, NetworkConfigGetter) {
        NetworkConfigGetter networkConfigGetter= new NetworkConfigGetter( );

        (
            address weth,
            address wethToUSDPriceFeed,
            address wbtc,
            address wbtcToUSDPriceFeed,
            uint256 deployerKey
        ) = networkConfigGetter.networkConfig( );

        collateralTokenAddresses= [weth, wbtc];
        priceFeedAddresses= [wethToUSDPriceFeed, wbtcToUSDPriceFeed];

        vm.startBroadcast(deployerKey);

        // Deploying the contracts.
        DecentralizedStableCoin decentralizedStableCoin= new DecentralizedStableCoin( );
        DSCEngine dscEngine= new DSCEngine(collateralTokenAddresses, priceFeedAddresses, address(decentralizedStableCoin));

        // Transferring ownership of the DecentralizedStableCoin contract to DSCEngine.
        decentralizedStableCoin.transferOwnership(address(dscEngine));

        vm.stopBroadcast( );

        return (decentralizedStableCoin, dscEngine, networkConfigGetter);
    }
}
