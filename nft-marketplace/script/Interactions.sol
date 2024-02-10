// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";
import { BasicNFT } from "../src/BasicNFT.sol";

contract MintBasicNFT is Script {
  string public constant PUG_IMAGE_URI=
    "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

  function run( ) external {
    address mostRecentDeployment= DevOpsTools.get_most_recent_deployment("BasicNFT", block.chainid);
    mintNFT(mostRecentDeployment);
  }

  function mintNFT(address contractAddress) public {
    vm.startBroadcast( );

    BasicNFT(contractAddress).mintNFT(PUG_IMAGE_URI);

    vm.stopBroadcast( );
  }
}