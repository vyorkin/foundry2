// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {DSTest} from "ds-test/test.sol";
import {console2} from "forge-std/console2.sol";
import {Proxy, Factory, Helper, Foo, Baz} from "../../src/basic/Contract.sol";

contract ContractTest is DSTest {
    Helper private helper;
    Proxy private proxy;
    Factory private factory;

    function setUp() public {
        helper = new Helper();
        proxy = new Proxy();
        factory = new Factory();
    }

    function testHelper() public {
        bytes memory bytecode = helper.getFooBytecode();
        console2.logBytes(bytecode);
    }

    function testDeployExecuteFoo() public {
        bytes memory bytecode = helper.getFooBytecode();

        address addr1 = proxy.deploy(bytecode);
        address addr2 = proxy.deploy(bytecode);

        console2.logAddress(addr1);
        console2.logAddress(addr2);

        bytes memory call = helper.getFooCalldata();
        proxy.execute(addr1, call);
        proxy.execute(addr2, call);
    }

    function testDeployExecuteBaz() public {
        uint256 quux = 100;
        bool corge = true;
        string memory grault = "grault";

        bytes memory bytecode = helper.getBazBytecode(quux, corge, grault);

        address addr1 = proxy.deploy(bytecode);
        address addr2 = proxy.deploy(bytecode);

        console2.logAddress(addr1);
        console2.logAddress(addr2);

        bytes memory call = helper.getBazCalldata(100);
        proxy.execute(addr1, call);
        proxy.execute(addr2, call);
    }

    function testDeployFoo2() public {
        factory.deployFoo2();
    }

    function testDeployBaz2() public {
        factory.deployBaz2();
    }
}
