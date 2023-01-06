// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";

contract GasGolf2 {
    uint256 x;

    function statePlusEq() public {
        x += 35;
    }

    function statePlus() public {
        x = x + 35;
    }

    function mul2() public pure returns (uint256) {
        return 150 * 2;
    }

    function mul2Shift() public pure returns (uint256) {
        return 150 << 1;
    }

    function div2() public pure returns (uint256) {
        return 150 / 2;
    }

    function div2Shift() public pure returns (uint256) {
        return 150 >> 1;
    }
}

contract GasGolf2Test is Test {
    GasGolf2 private c;

    function setUp() public {
        c = new GasGolf2();
    }

    function testStatePlus() public {
      c.statePlus();
      c.statePlusEq();
    }

    function testMul2Shift() public {
        uint256 x0 = c.mul2();
        uint256 x1 = c.mul2Shift();
        assertEq(x0, 300);
        assertEq(x0, x1);
    }

    function testDiv2Shift() public {
        uint256 x0 = c.div2();
        uint256 x1 = c.div2Shift();
        assertEq(x0, 75);
        assertEq(x0, x1);
    }
}
