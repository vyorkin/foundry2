// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Safe {
  receive() external payable {}

  function withdraw() external {
    payable(msg.sender).transfer(address(this).balance);
  }
}