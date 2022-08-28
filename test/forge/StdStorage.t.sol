// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import {Storage, Foo} from "../../src/forge/Storage.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    Storage private s;

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

    function testWriteStruct() public {
        stdstore
            .target(address(s))
            .sig(s.foos.selector)
            .with_key(1)
            .depth(1)
            .checked_write(99);

        (, uint256 y, ) = s.foos(1);

        assertEq(y, 99);
    }
}
