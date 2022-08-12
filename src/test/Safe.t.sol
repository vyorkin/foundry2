// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "ds-test/test.sol";
import "../Safe.sol";

interface CheatCodes {
    function assume(bool) external;
}

contract SafeTest is DSTest {
    Safe safe;
    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function testWithdraw(uint96 amount) public {
        // used to exclude certain use cases
        // in false cases, fuzzer will discard the inputs and start a new fuzz run
        cheats.assume(amount > 0.1 ether);
        cheats.assume(amount < 1 ether);
        // by default, the fuzzer will generate 256 scenarios
        // controlled by the FOUNDRY_FUZZ_RUNS env var

        // μ - mean gas used across all fuzz runs

        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
