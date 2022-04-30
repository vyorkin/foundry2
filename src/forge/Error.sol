// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Error {
    function assertionError() public pure {
        assert(false);
    }

    function arithmeticError(uint256 x) public pure {
        x -= 100;
    }
}
