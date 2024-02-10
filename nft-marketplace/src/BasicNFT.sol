// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// This contract represents an entire collection of Dogie tokens. Each Dogie token will get its own
// unique token id. A unqiue Dogie NFT is a combination of the contract address and the id of the
// corresponding Dogie token.
contract BasicNFT is ERC721 {
  uint256 private s_tokenCounter;
  mapping(uint256 tokenId => string tokenUri) private s_tokenIdToTokenUri;

  constructor( )
    ERC721("Dogie", "DOG")
  {
    s_tokenCounter= 0;
  }

  function mintNFT(string memory tokenUri) public {
    s_tokenIdToTokenUri[s_tokenCounter]= tokenUri;

    // Mints a new Dogie token and transfers its ownership to msg.sender.
    _safeMint(msg.sender, s_tokenCounter);

    s_tokenCounter++;
  }

  // Here URI stands for Universal Resource Identifier.
  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    return s_tokenIdToTokenUri[tokenId];
  }
}