// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {A, B, C, D} from "../../src/basic/Inheritance.sol";

contract InheritanceTest is Test {
    function setUp() public {}

    function testC() public {
        uint256 x = new C().x();
        assertEq(x, 2);
    }

    function testD() public {
        uint256 x = new D().x();
        assertEq(x, 1);
    }
}
