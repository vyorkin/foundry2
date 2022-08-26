// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";

import {NFT} from "../src/NFT.sol";

contract DeployNFT is Script {
  function run() external {
    vm.startBroadcast();
    NFT nft = new NFT("NFT Example", "NFTE", "nevermind");
    vm.stopBroadcast();
  }
}