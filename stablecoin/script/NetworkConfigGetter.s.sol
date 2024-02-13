// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NetworkConfigGetter is Script {
    struct NetworkConfig {
        // weth is the address to the contract representing ERC20 version of Ethereum (in wei unit).
        address weth;
        address wethToUSDPriceFeed;

        // wbtc is the address to the contract representing ERC20 version of Bitcoin (in wei unit).
        address wbtc;
        address wbtcToUSDPriceFeed;

        uint256 deployerKey;
    }

    NetworkConfig public networkConfig;

    constructor( ) {
        if(block.chainid == 11155111)
            networkConfig= getSepoliaNetworkConfig( );

        else networkConfig= getAnvilNetworkConfig( );
    }

    function getSepoliaNetworkConfig( ) public view returns(NetworkConfig memory) {
        return NetworkConfig({
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wethToUSDPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,

            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            wbtcToUSDPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,

            deployerKey: vm.envUint("SEPOLIA_NETWORK_PRIVATE_KEY")
        });
    }

    uint8 public constant DECIMALS= 8;
    int256 public constant MOCK_ETH_PRICE_IN_USD= 2000e8;
    int256 public constant MOCK_BTC_PRICE_IN_USD= 2000e8;

    uint256 public constant DEFAULT_ANVIL_DEPLOYMENT_KEY=
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function getAnvilNetworkConfig( ) public returns(NetworkConfig memory) {
        if(networkConfig.wethToUSDPriceFeed != address(0))
            return networkConfig;

        vm.startBroadcast( );

        ERC20Mock mockWeth= new ERC20Mock("WETH", "WETH");
        MockV3Aggregator mockETHToUSDPriceFeed= new MockV3Aggregator(DECIMALS, MOCK_ETH_PRICE_IN_USD);

        ERC20Mock mockWbtc= new ERC20Mock("WBTC", "WBTC");
        MockV3Aggregator mockBTCToUSDPriceFeed= new MockV3Aggregator(DECIMALS, MOCK_BTC_PRICE_IN_USD);

        vm.stopBroadcast( );

        return NetworkConfig({
            weth: address(mockWeth),
            wethToUSDPriceFeed: address(mockETHToUSDPriceFeed),

            wbtc: address(mockWbtc),
            wbtcToUSDPriceFeed: address(mockBTCToUSDPriceFeed),

            deployerKey: DEFAULT_ANVIL_DEPLOYMENT_KEY
        });
    }
}

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
    { }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
