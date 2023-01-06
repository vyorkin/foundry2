// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {GasGolf} from "../../src/gas/GasGolf.sol";

contract GasGolfTest is Test {
    GasGolf private gasGolf;
    uint256[] private xs;

    function setUp() public {
        gasGolf = new GasGolf();
        xs = [1, 2, 3, 4, 5, 5, 100];
    }

    function testGasGolf() public {
        gasGolf.sumIfEvenAndLessThan99(xs);
    }
}
