// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/test.sol";
import {console2} from "forge-std/console2.sol";
import {TimeLock} from "../TimeLock.sol";

contract Action {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function run() external {
    }
}

contract TimeLockTest is Test {
    function setUp() public {
    }

    function testTimeLock() public {
    }
}
