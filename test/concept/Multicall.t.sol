// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {DSTest} from "ds-test/test.sol";
import {console2} from "forge-std/console2.sol";
import {Multicall} from "../../src/concept/Multicall.sol";

contract Callable {
    function fn1() external view returns (uint256, uint256) {
        return (1, block.timestamp);
    }

    function fn2() external view returns (uint256, uint256) {
        return (2, block.timestamp);
    }

    function getData1() external pure returns (bytes memory) {
        // abi.encodeWithSignature("fn1()");
        return abi.encodeWithSelector(this.fn1.selector);
    }

    function getData2() external pure returns (bytes memory) {
        // abi.encodeWithSignature("fn2()");
        return abi.encodeWithSelector(this.fn2.selector);
    }
}

contract MulticallTest is DSTest {
    Multicall private multicall;
    Callable private callable;

    function setUp() public {
        callable = new Callable();
        multicall = new Multicall();
    }

    function testMulticall() public {
        address[] memory targets = new address[](2);
        targets[0] = address(callable);
        targets[1] = address(callable);

        bytes[] memory data = new bytes[](2);
        data[0] = callable.getData1();
        data[1] = callable.getData2();

        bytes[] memory results = multicall.run(targets, data);

        (uint256 n1, uint256 block1) = abi.decode(
            results[0],
            (uint256, uint256)
        );
        (uint256 n2, uint256 block2) = abi.decode(
            results[1],
            (uint256, uint256)
        );

        assertEq(1, n1);
        assertEq(1, block1);
        assertEq(2, n2);
        assertEq(1, block2);
    }
}
