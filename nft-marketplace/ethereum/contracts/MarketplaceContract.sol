// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MarketplaceContract is ReentrancyGuard {

    struct NFTDetails {

        uint256 price;
        address seller;
    }

    event NewNFTListed(
        address indexed seller, address indexed nftContract, uint256 indexed nftId, uint256 price);

    event NFTSold(
        address indexed buyer, address indexed nftContract, uint256 indexed nftId, uint256 price);

    event NFTUnlisted(
        address indexed seller, address indexed nftContract, uint256 indexed nftId);

    modifier onlyAllowNonListedNFTs(address nftContract, uint256 nftId) {
        NFTDetails memory nftDetails= nfts[nftContract][nftId];

        if(nftDetails.price > 0) {
            revert NFTAlreadyListed(nftContract, nftId); }

        _;
    }

    modifier onlyAllowListedNFTs(address nftContract, uint256 nftId) {
        NFTDetails memory nftDetails= nfts[nftContract][nftId];

        if(nftDetails.price <= 0) {
            revert NFTNotListed(nftContract, nftId); }

        _;
    }

    modifier onlyAllowNFTOwner(address nftContract, uint256 nftId, address seller) {

        IERC721 NFTContract= IERC721(nftContract);
        address nftContractOwner= NFTContract.ownerOf(nftId);

        if(seller != nftContractOwner) {
            revert NFTCanOnlyBeListedByOwner( ); }

        _;
    }

    // NFT contract address -> NFT id -> {price, address of buyer}
        mapping(address => mapping(uint256 => NFTDetails)) private nfts;
    // seller address -> amount earned
        mapping(address => uint256) private earnings;

    // getter functions

    function getNFTDetails(address nftContract, uint256 nftId) external view returns(NFTDetails memory) {
        return nfts[nftContract][nftId];
    }

    function getTotalEarning(address seller) external view returns(uint256) {
        return earnings[seller];
    }

    // main functions

    // add a new NFT to the marketplace
    function listNFT(address nftContract, uint256 nftId, uint256 price) external
        onlyAllowNonListedNFTs(nftContract, nftId) onlyAllowNFTOwner(nftContract, nftId, msg.sender) {

        if(price <= 0) {
            revert NFTPriceMustBeMoreThanZero( ); }

        IERC721 NFTContract= IERC721(nftContract);

        // the NFT contract must approve this marketplace to swap NFTs to the buyer
        if(NFTContract.getApproved(nftId) != address(this)) {
            revert NFTContractDidntGiveApprovalToMarketplace( ); }

        nfts[nftContract][nftId]= NFTDetails(price, msg.sender);
        emit NewNFTListed(msg.sender, nftContract, nftId, price);

    }

    function buyNFT(address nftContract, uint256 nftId) external payable
        onlyAllowListedNFTs(nftContract, nftId) nonReentrant {

        NFTDetails memory nftDetails= nfts[nftContract][nftId];

        if(msg.value < nftDetails.price) {
            revert NotEnoughBuyingAmountSent(nftContract, nftId, nftDetails.price); }

        earnings[nftDetails.seller] += msg.value;

        delete(nfts[nftContract][nftId]);

        IERC721(nftContract).safeTransferFrom(nftDetails.seller, msg.sender, nftId);
        emit NFTSold(msg.sender, nftContract, nftId, msg.value);

    }

    function unlistNFT(address nftContract, uint256 nftId) external
        onlyAllowNFTOwner(nftContract, nftId, msg.sender) onlyAllowListedNFTs(nftContract, nftId) {

        delete(nfts[nftContract][nftId]);
        emit NFTUnlisted(msg.sender, nftContract, nftId);
    }

    function updateNFTPrice(address nftContract, uint256 nftId, uint256 updatedPrice) external
        onlyAllowNFTOwner(nftContract, nftId, msg.sender) onlyAllowListedNFTs(nftContract, nftId) {

        nfts[nftContract][nftId]= NFTDetails(updatedPrice, msg.sender);
        emit NewNFTListed(msg.sender, nftContract, nftId, updatedPrice);
    }

    function withdrawEarning( ) external {
        uint256 totalEarning= earnings[msg.sender];

        if(totalEarning <= 0) {
            revert NoEarning( ); }

        earnings[msg.sender]= 0;

        (bool isSuccessfull, )= payable(msg.sender).call{ value: totalEarning }("");
        if(!isSuccessfull) {
            revert WithdrawEarningFailed( ); }
    }

}

error NFTPriceMustBeMoreThanZero( );
error NFTContractDidntGiveApprovalToMarketplace( );
error NFTAlreadyListed(address nftContract, uint256 nftId);
error NFTCanOnlyBeListedByOwner( );
error NFTNotListed(address nftContract, uint256 nftId);
error NotEnoughBuyingAmountSent(address nftContract, uint256 nftId, uint256 price);
error NoEarning( );
error WithdrawEarningFailed( );

