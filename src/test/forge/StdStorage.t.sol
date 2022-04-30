// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../../forge/Storage.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    Storage s;

    function setUp() public {
        s = new Storage();
    }

    function testFindExists() public {
        uint256 slot = stdstore.target(address(s)).sig("exists()").find();
        assertEq(slot, 0);
    }

    function testWriteExists() public {
        stdstore.target(address(s)).sig("exists()").checked_write(100);
        assertEq(s.exists(), 100);
    }
}
