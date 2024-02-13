// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

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
    Example working of this DSCEngine contract -

    Let's say Adam deposits 100 USD worth of ETH (collateral) and mints 50 USD worth of DSC.

    Now let's say after some time, ETH price goes down and Adam's collateral deposit evaluates to
    74 USD.

    Let the collateral threshold of the DSC system be 150% (If Adam mints 50 USD worth of DSC, he
    must have atleast 75 USD worth of collateral deposited in the system). So the system is
    currently undercollateralized and Adam will be kicked out by some other user (let's say Archi)!

    1. Archi will pay Adam's debt (50 USD worth of DSC) (so, now Adam has 0 debt).

    2. Archi needs to be paid back with 55 USD worth of collateral (compensation of 50 USD + 10%
       bonus (5 USD)). This 55 USD will be paid from Adam's collateral.

    So, Archi made a profit of 5 USD. And Adam got his punishment (lost 5 USD) for making the system
    uncollateralized. This process is called liquidation.
*/
//
// NOTE - collateral token amount will always be in wei unit.
//
// NOTE - ChainLink returns the current price of 1e8 wei unit of tokens.
//
// NOTE - 1 USD = 1 ether unit (or 1e18 wei unit) of DSC.
contract DSCEngine is ReentrancyGuard {

    // -- STATE VARIABLES --

    /*
        The collateral threshold for our DSC system is 200%. That means a user, if a user has
        minted 50 USD worth of dsc, he / she must have 50 * 2= 100 USD worth of collateral
        submitted.
    */
    uint256 private constant LIQUIDATION_THRESHOLD= 50;
    uint256 private constant LIQUIDATION_PRECISION= 100;

    uint256 private constant MIN_HEALTH_FACTOR= 1e18;

    address[] collateralTokens;
    DecentralizedStableCoin dsc;

    mapping(address collateralToken => address valueInUSDs) private priceFeeds;
    mapping(address user => mapping(address collateralToken => uint256 collateralAmount)) private collateralDeposits;
    mapping(address user => uint256 dscMinted) private mints;

    // -- ERRORS --
    error DSCEngine__AmountMustBeMoreThanZero( );
    error DSCEngine__CollateralTokenNotAllowed( );
    error DSCEngine__CollateralTransferFailed( );
    error DSCEngine__CollateralTokenAddressesAndPriceFeedAddressesMustHaveSameLength( );
    error DSCEngine__LessThanMinHealthFactor(uint256 healthFactor);
    error DSCEngine__DSCTransferFailed( );
    error DSCEngine__HealthFactorOfUserIsMoreThanMinHealthFactor( );
    error DSCEngine__HealthFactorOfInsolventUserNotImproved( );

    // -- EVENTS --
    event CollateralDeposited(address indexed user, address indexed collateralToken, uint256 indexed collateralAmount);
    event CollateralRedeemed(address indexed redeemedFrom, address indexed redeemedTo, address indexed collateralToken, uint256 collateralAmount);

    constructor(
        address[] memory collateralTokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
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

    function depositCollateralAndMintDSC(
        uint256 mintingAmount,
        address collateralTokenAddress, uint256 collateralAmount
    ) external {
        depositCollateral(collateralTokenAddress, collateralAmount);
        mintDSC(mintingAmount);
    }

    // Submit some of your DSC tokens and take back some of your collateral. The submitted DSC
    // tokens will then be burned (removed from circulation).
    function redeemCollateralByBurningYourDSC(
        address collateralTokenAddress, uint256 collateralAmount,
        uint256 dscTokenAmount
    ) external {
        burnDSC(dscTokenAmount);
        redeemCollateral(collateralTokenAddress, collateralAmount); // health factor check is done
                                                                    // inside this function.
    }

    /**
     * @param collateralTokenAddress: The address of the collateral token you're using to make
     * the protocol solvent again. This is collateral that you're going to take from the user who is
     * insolvent. In return, you have to burn your DSC to pay off their debt, but you don't pay off
     * your own.
     *
     * @notice - You can partially liquidate a user. The only condition is - the user's health
     * factor should be greater than MIN_HEALTH_FACTOR after the liquidation process.
     *
     * @notice - This function assumes that the protocol will always be overcollateralized.
     * BUG - If the protocol becomes 100% collateralized or undercollateralized, the liquidators
     * won't get any liquidation bonus.
     *
     * @notice - Follows CEI pattern.
    */
    function liquidate(
        address collateralTokenAddress, address insolventUser,
        uint256 debtOfInsolventUser // in DSC / USD (since 1 DSC = 1 USD)
    ) external
        moreThanZero(debtOfInsolventUser)
        nonReentrant
    {
        uint256 initialHealthFactorOfInsolventUser= _healthFactor(insolventUser);
        if(initialHealthFactorOfInsolventUser >= MIN_HEALTH_FACTOR)
            revert DSCEngine__HealthFactorOfUserIsMoreThanMinHealthFactor( );

        // Archi pays off Adam's debt.
        _burnDSC(insolventUser, msg.sender, debtOfInsolventUser);

        // Calculating how much collateral Archi (liquidation initiator) will get as compensation.
        uint256 compensation= getCollateralTokenAmountWorthUSD(collateralTokenAddress, debtOfInsolventUser);
        //
        // Calculating how much collateral Archi (liquidation initiator) will get as bonus.
        uint256 bonus= (compensation * 10) / 100;

        // Portion of Adam's collateral (Archi's compensation + 10% bonus) is redeemed by Archi.
        _redeemCollateral(collateralTokenAddress, compensation + bonus, insolventUser, msg.sender);

        // -- Health Factor checks --

        // The health factor of the insolvent user may not be >= MIN_HEALTH_FACTOR (in case of
        // partial liquidation - which means Archi paid some of Adam's debt), but it must have been
        // improved by now.
        if(_healthFactor(insolventUser) <= initialHealthFactorOfInsolventUser)
            revert DSCEngine__HealthFactorOfInsolventUserNotImproved( );

        // The liquidation initiator's health factor >= MIN_HEALTH_FACTOR.
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function getHealthFactor(address user) external view returns(uint256) {
        return _healthFactor(user);
    }

    // -- PUBLIC FUNCTIONS --

    /**
     * @notice Follows CEI pattern - First, checks are done (using modifiers), then effects take
     * place (updating state variables) and finally external interactions happen.
     *
     * @param collateralTokenAddress - Address of the token (can be BTC /ETH) which will be
     * deposited as collateral.
     *
     * @param collateralAmount - Amount of collateral that'll be deposited.
    */
    function depositCollateral(address collateralTokenAddress, uint256 collateralAmount) public
        moreThanZero(collateralAmount)
        isCollateralToken(collateralTokenAddress)
        nonReentrant // It will result to a bit more gas consumption but will make the contract
                     // safer.
    {
        collateralDeposits[msg.sender][collateralTokenAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, collateralTokenAddress, collateralAmount);

        bool isCollateralTransferSuccessfull=
            IERC20(collateralTokenAddress).transferFrom(msg.sender, address(this), collateralAmount);

        if(!isCollateralTransferSuccessfull)
            revert DSCEngine__CollateralTransferFailed( );
    }

    /**
     * @notice Follows CEI pattern
     *
     * @notice - The minter must have more collateral deposited than the threshold (which is 150%).
     *
     * @param amount - The amount of DSC token to mint (remember 1 DSC = 1 USD always).
    */
    function mintDSC(uint256 amount) public
        moreThanZero(amount)
        nonReentrant
    {
        mints[msg.sender] += amount;
        _revertIfHealthFactorIsBroken(msg.sender);

        bool isMinted= dsc.mint(msg.sender, amount);
        if(!isMinted)
            revert DSCEngine__DSCTransferFailed( );
    }

    function burnDSC(uint256 amount) public
        moreThanZero(amount)
    {
        _burnDSC(msg.sender, msg.sender, amount);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function redeemCollateral(address collateralTokenAddress, uint256 collateralAmount) public
        moreThanZero(collateralAmount)
        nonReentrant
    {
        _redeemCollateral(collateralTokenAddress, collateralAmount, msg.sender, msg.sender);

        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function getDepositedCollateralValueInUSDForUser(address user) public view returns(uint256 depositedCollateralValueInUSD) {
        for(uint256 i= 0; i < collateralTokens.length; i++) {
            address collateralToken= collateralTokens[i];

            uint256 collateralAmount= collateralDeposits[user][collateralToken];
            depositedCollateralValueInUSD += getCollateralValueInUSD(collateralToken, collateralAmount);
        }
    }

    function getCollateralValueInUSD(address collateralToken, uint256 amount) public view returns(uint256) {
        AggregatorV3Interface priceFeed= AggregatorV3Interface(priceFeeds[collateralToken]);
        (, int256 currentCollateralTokenPrice,,,)= priceFeed.latestRoundData( );

        return ((uint256(currentCollateralTokenPrice) * 1e10) * amount) / 1e18;
    }

    // Get the amount of a collateral token worth given amount of USD.
    function getCollateralTokenAmountWorthUSD(address collateralToken, uint256 usdAmount) public view returns(uint256) {
        AggregatorV3Interface priceFeed= AggregatorV3Interface(priceFeeds[collateralToken]);
        (, int256 currentCollateralTokenPrice,,,)= priceFeed.latestRoundData( );

        return (usdAmount * 1e18) / (uint256(currentCollateralTokenPrice) * 1e10);
    }

    // -- INTERNAL FUNCTIONS --

    function _revertIfHealthFactorIsBroken(address user) private view {
        uint256 healthFactor= _healthFactor(user);
        if(healthFactor < MIN_HEALTH_FACTOR)
            revert DSCEngine__LessThanMinHealthFactor(healthFactor);
    }

    // Returns how close to liquidation a user is.
    // If the health factor of a user is less than 1, he / she gets liquified.
    function _healthFactor(address user) private view returns(uint256) {
        (uint256 totalDSCMinted, uint256 depositedCollateralValueInUSD)= _getUserInformation(user);

        /*
            If 100 USD worth of DSC is minted, 100 * 2 = 200 USD worth of collateral must be present.
            Otherwise the user is under-collateralized.

            Let the user has 150 USD (less than 200 USD) worth collateral submitted.

            (150 * 50) / 100 = 75 --- (1)
            Then 75 / 100 = 0.75. --- (2)

            The health factor is < 1, so the user is definitely under collateralized.
        */
       // TODO: Understand why doing this is necessary.
        uint256 collateralAdjustedForThreshold= (depositedCollateralValueInUSD * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION; // --- (1)

        return collateralAdjustedForThreshold / totalDSCMinted; // --- (2)
    }

    function _getUserInformation(address user) private view returns(uint256 dscMinted, uint256 depositedCollateralValueInUSD) {
        dscMinted= mints[user];
        depositedCollateralValueInUSD= getDepositedCollateralValueInUSDForUser(user);
    }

    function _redeemCollateral(
        address collateralTokenAddress, uint256 collateralAmount,
        address from, address to
    ) private {
        // According to the recent Solidity compiler versions, if collateralAmount is more than the
        // balance of 'from', then automatic revert occurs.
        collateralDeposits[from][collateralTokenAddress] -= collateralAmount;
        emit CollateralRedeemed(from, to, collateralTokenAddress, collateralAmount);

        bool isCollateralTransferSuccessfull= IERC20(collateralTokenAddress).transfer(to, collateralAmount);
        if(!isCollateralTransferSuccessfull)
            revert DSCEngine__CollateralTransferFailed( );
    }

    /**
     * @dev - Whenever _burnDSC is invoked, a health factor check must be done for both the users.
    */
    function _burnDSC(address onBehalfOfUser, address dscFrom, uint256 amount) private {
        mints[onBehalfOfUser] -= amount;

        bool isDSCTransferSuccessfull= dsc.transferFrom(dscFrom, address(this), amount);
        if(!isDSCTransferSuccessfull)
            revert DSCEngine__DSCTransferFailed( );

        dsc.burn(amount);
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

    // -- These are used only while testing --

    function getUserInformation(address user) public view returns(uint256 dscMinted, uint256 depositedCollateralValueInUSD) {
        return _getUserInformation(user);
    }
}
