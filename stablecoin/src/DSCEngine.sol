// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DecentralizedStableCoin } from "./DecentralizedStableCoin.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// This contract handles all the logic for mining and redeeming DSC, as well as depositing and
// withdrawing collateral (ETH and BTC).
//
// Our DSC system should always be over-collateralized. At no point total collateral <= value of all
// DSCs (in USD).
//
// NOTE- This contract is very loosely based on MakerDAO DSS (DAI) system.
/*
    Let's say Adam deposits 100 USD worth of ETH (collateral) and mints 50 USD worth of DSC.

    Now let's say after some time, ETH price goes down and Adam's collateral deposit evaluates to
    74 USD.

    The collateral threshold of the DSC system is 150% (If Adam mints 50 USD worth of DSC, he must
    have atleast 75 USD worth of collateral deposited in the system). So the system is currently
    undercollateralized and Adam will be kicked out by some other user (let's say Archi)! Archi will
    pay 50 USD on behalf of Adam (so now Adam has 0 debt) and in turn will take all of Adam's
    deposited collateral (worth 74 USD).

    So, Archi made a profit of 24 USD. And Adam got his punishment for making the system
    uncollateralized.
*/
contract DSCEngine is ReentrancyGuard {

    // -- STATE VARIABLES --
    mapping(address collateralToken => address valueInUSDs) private priceFeeds;
    mapping(address user => mapping(address collateralToken => uint256 collateralAmount)) private collateralDeposits;
    mapping(address user => uint256 dscMinted) private mints;
    address[] collateralTokens;
    DecentralizedStableCoin dsc;
    uint256 private constant LIQUIDATION_THRESHOLD= 50;

    constructor(address[] memory collateralTokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if(collateralTokenAddresses.length != priceFeedAddresses.length)
            revert DSCEngine__CollateralTokenAddressesAndPriceFeedAddressesMustHaveSameLength( );

        for(uint256 i= 0; i< collateralTokenAddresses.length; i++) {
            address collateralToken= collateralTokenAddresses[i];

            priceFeeds[collateralToken]= priceFeedAddresses[i];
            collateralTokens.push(collateralToken);
        }

        dsc= DecentralizedStableCoin(dscAddress);
    }

    // -- EXTERNAL FUNCTIONS --

    /**
     * @notice Follows CEI pattern - First, checks are done (using modifiers), then effects take
     * place (updating state variables) and finally external interactions happen.
     *
     * @param collateralTokenAddress - Address of the DSC token which will be deposited as
     * collateral.
     *
     * @param collateralAmount - Amount of collateral that'll be deposited.
    */
    function depositCollateral(address collateralTokenAddress, uint256 collateralAmount) external
        moreThanZero(collateralAmount)
        isCollateralToken(collateralTokenAddress)
        nonReentrant // It will result to a bit more gas consumption but will make the contract
                     // safer.
    {
        collateralDeposits[msg.sender][collateralTokenAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, collateralTokenAddress, collateralAmount);

        bool isCollateralAmountTransferSuccessfull=
            IERC20(collateralTokenAddress).transferFrom(msg.sender, address(this), collateralAmount);

        if(!isCollateralAmountTransferSuccessfull)
            revert DSCEngine__CollateralAmountTransferFailed( );
    }

    /**
     * @param amount - The amount of DSC token to mint (remember 1 DSC = 1 USD always).
     *
     * @notice - The minter must have more collateral deposited than the threshold (which is 150%).
    */
    function mintDSC(uint256 amount) external
        moreThanZero(amount)
        nonReentrant
    {
        mints[msg.sender] += amount;
    }

    function depositCollateralAndMintDSC( ) external { }

    function redeemCollateral( ) external { }

    function redeemCollateralForDSC( ) external { }

    function burnDSC( ) external { }

    function liquidate( ) external { }

    function getHealthFactor( ) external view { }

    function getDepositedCollateralValueInUSD(address user) public view returns(uint256 depositedCollateralValueInUSD) {
        for(uint256 i= 0; i < collateralTokens.length; i++) {
            address collateralToken= collateralTokens[i];

            uint256 collateralAmount= collateralDeposits[user][collateralToken];
            depositedCollateralValueInUSD += getCollateralValueInUSD(collateralToken, collateralAmount);
        }
    }

    // -- INTERNAL FUNCTIONS --

    function getUserInformation(address user) private view returns(uint256 totalDSCMinted, uint256 depositedCollateralValueInUSD) {
        totalDSCMinted= mints[user];
        depositedCollateralValueInUSD= getDepositedCollateralValueInUSD(user);
    }

    // Returns how close to liquidation a user is.
    // If the health factor of a user is less than 1, he / she gets liquified.
    function _healthFactor(address user) private view returns(uint256) {
        (uint256 totalDSCMinted, uint256 depositedCollateralValueInUSD)= getUserInformation(user);

        depositedCollateralValueInUSD / totalDSCMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) private view { }

    function getCollateralValueInUSD(address collateralToken, uint256 amount) private view returns(uint256) {
        AggregatorV3Interface priceFeed= AggregatorV3Interface(priceFeeds[collateralToken]);
        (, int256 currentCollateralTokenPrice,,,)= priceFeed.latestRoundData( );

        return ((uint256(currentCollateralTokenPrice) * 1e10) * amount) / 1e18;
    }

    // -- MODIFIERS --

    modifier moreThanZero(uint256 amount) {
        if(amount == 0)
            revert DSCEngine__AmountMustBeMoreThanZero( );

        _;
    }

    modifier isCollateralToken(address token) {
        if(priceFeeds[token] == address(0))
            revert DSCEngine__CollateralTokenNotAllowed( );

        _;
    }

    // --ERRORS --
    error DSCEngine__AmountMustBeMoreThanZero( );
    error DSCEngine__CollateralTokenNotAllowed( );
    error DSCEngine__CollateralAmountTransferFailed( );
    error DSCEngine__CollateralTokenAddressesAndPriceFeedAddressesMustHaveSameLength( );

    // -- EVENTS --
    event CollateralDeposited(address indexed user, address indexed collateralToken, uint256 indexed collateralAmount);
}
