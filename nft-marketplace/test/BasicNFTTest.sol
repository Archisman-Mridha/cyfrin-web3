// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { DeployBasicNFT } from "../script/DeployBasicNFT.sol";
import { BasicNFT } from "../src/BasicNFT.sol";

contract BasicNFTTest is Test {
  DeployBasicNFT public deployer;
  BasicNFT public basicNFT;

  address public USER= makeAddr("user");

  string public constant PUG_IMAGE_URI=
    "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

  function setUp( ) public {
    deployer= new DeployBasicNFT( );
    basicNFT= deployer.run( );
  }

  function test_NameIsCorrect( ) public view {
    string memory expectedName= "Dogie";
    string memory actualName= basicNFT.name( );

    // A string is an array of byte32s. We can't use '==' with 2 strings and. Instead, we will
    // compare the hashes of the strings.
    assert(
      keccak256(bytes(expectedName)) == keccak256(bytes(actualName))
    );
  }

  function test_CanMint( ) public {
    vm.prank(USER);

    basicNFT.mintNFT(PUG_IMAGE_URI);

    assert(basicNFT.balanceOf(USER) == 1);
    assert(keccak256(bytes(PUG_IMAGE_URI)) == keccak256(bytes(basicNFT.tokenURI(0))));
  }
}