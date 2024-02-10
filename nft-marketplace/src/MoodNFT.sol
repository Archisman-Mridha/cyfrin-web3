// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
  uint256 private s_tokenCounter;

  string private s_happySVGImageUri;
  string private s_sadSVGImageUri;

  enum Mood {
    Happy,
    Sad
  }

  mapping(uint256 tokenId => Mood mood) s_tokenIdToMood;

  constructor(string memory happySVGImageUri, string memory sadSVGImageUri)
    ERC721("Mood NFT", "MNFT")
  {
    s_tokenCounter= 0;

    s_happySVGImageUri= happySVGImageUri;
    s_sadSVGImageUri= sadSVGImageUri;
  }

  function mintNFT( ) public {
    _safeMint(msg.sender, s_tokenCounter);
    s_tokenIdToMood[s_tokenCounter]= Mood.Happy;

    s_tokenCounter++;
  }

  function flipMood (uint256 tokenId) public {
    if(!_isApprovedOrOwner(msg.sender, tokenId)) {
      revert MoodNFT_CantFlipMoodIfNotOwner( );
    }

    if(s_tokenIdToMood[tokenId] == Mood.Happy) {
      s_tokenIdToMood[tokenId]= Mood.Sad;
    }
    else { s_tokenIdToMood[tokenId]= Mood.Happy; }
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    string memory imageUri;

    if(s_tokenIdToMood[tokenId] == Mood.Happy) {
      imageUri= s_happySVGImageUri;
    }
    else { imageUri= s_sadSVGImageUri; }

    return string.concat(
      "data:application/json;base64,",
      Base64.encode(bytes(string.concat(
        '{',
          '"name": "', name( ), '",',
          '"description": "An NFT that reflects owners mood",',
          '"attributes": [{"trait_type": "moodiness", "value": 100}],',
          '"image": "', imageUri, '"',
        '}'
      )))
    );
  }

  error MoodNFT_CantFlipMoodIfNotOwner( );
}