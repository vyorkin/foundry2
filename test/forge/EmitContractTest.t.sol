// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "ds-test/test.sol";
import "../../src/basic/ExpectEmit.sol";

interface CheatCodes {
    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;
}

contract EmitContractTest is DSTest {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    function testExpectEmit() public {
        ExpectEmit emitter = new ExpectEmit();
        // we want to check the 1st and 2nd indexed topic for the next event
        // 4th argument is true:
        // we want to check "non-indexed topics", also known as data
        cheats.expectEmit(true, true, false, true);
        // this event is compared against the event emitted from the call below
        emit Transfer(address(this), address(1337), 1337);
        emitter.t();
    }
}
