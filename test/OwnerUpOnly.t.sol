// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

contract OwnerUpOnlyTest is DSTest {
    OwnerUpOnly upOnly;

    function setUp() public {
        upOnly = new OwnerUpOnly();
    }

    function testIncrementAsOwner() public {
        assertEq(upOnly.count(), 0);
        upOnly.increment();
        assertEq(upOnly.count(), 1);
    }
}