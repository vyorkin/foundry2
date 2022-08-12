// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../../forge/Error.sol";

// stdError is a helper contract for errors and reverts,
// it provides all compiler builtin errors

contract StdErrorTest is DSTest {
    Vm private vm = Vm(HEVM_ADDRESS);
    Error e;

    function setUp() public {
        e = new Error();
    }

    function testExpectAssertion() public {
        vm.expectRevert(stdError.assertionError);
        e.assertionError();
    }

    function testExpectArithmetic() public {
        vm.expectRevert(stdError.arithmeticError);
        e.arithmeticError(10);
    }
}
