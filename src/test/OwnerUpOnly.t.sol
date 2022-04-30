// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../OwnerUpOnly.sol";

interface CheatCodes {
    function prank(address) external;

    function expectRevert(bytes4) external;
}

contract OwnerUpOnlyTest is DSTest {
    OwnerUpOnly upOnly;
    // to enable a cheatcode you call designated functions on
    // the cheatcode address: 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D.
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        upOnly = new OwnerUpOnly();
    }

    function testIncrementAsOwner() public {
        assertEq(upOnly.count(), 0);
        upOnly.increment();
        assertEq(upOnly.count(), 1);
    }

    // using testFail considered an anti-pattern,
    // it does not tell us why a transaction reverts
    // use cheats.expectRevert instead
    function testFailIncrementAsNotOwner() public {
        // change our identity to the zero address for the next call
        cheats.prank(address(0));
        upOnly.increment();
    }

    function testIncrementAsNotOwner() public {
        cheats.expectRevert(Unauthorized.selector);
        cheats.prank(address(0));
        upOnly.increment();
    }

    function testLogging() public {
        emit log_string("foo");
        emit log_string("bar");
    }
}
