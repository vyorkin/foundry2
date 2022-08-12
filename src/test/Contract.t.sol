// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "ds-test/test.sol";
import "../Contract.sol";

contract ContractTest is DSTest {
    Factory factory;

    function setUp() public {
        factory = new Factory();
    }

    function testDeployFoo() public {
        factory.deployFoo();
    }

    function testDeployBaz() public {
        factory.deployBaz();
    }
}
