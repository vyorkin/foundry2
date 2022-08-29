// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {Create2} from "openzeppelin/utils/Create2.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Proxy, Factory, Helper, Foo, Baz} from "../../src/basic/Create2.sol";

contract Create2Test is Test {
    using Address for address payable;

    event Deploy(address indexed addr);
    event Deployed(address indexed addr, bytes32 salt);

    address private immutable alice = address(1);

    Helper private helper;
    Proxy private proxy;
    Factory private factory;

    function setUp() public {
        helper = new Helper();
        proxy = new Proxy();
        factory = new Factory();
        vm.label(address(helper), "Helper");
        vm.label(address(proxy), "Proxy");
        vm.label(address(factory), "Factory");

        vm.deal(address(this), 10 ether);

        vm.label(alice, "alice");
        vm.deal(alice, 10 ether);
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
        vm.expectEmit(true, false, false, false);
        emit Deployed(0x9e76A1Ff921c6960EECE402Fd3253a35Ef824C22, 0x7e7bffad144832c363f86604341901facbe3f7d8d833339e4bf070654d1a1b39);
        factory.deployFoo2();
    }

    function testDeployBaz2() public {
        factory.deployBaz2();
    }

    function testOZCreate2() public {
        bytes32 salt = keccak256(abi.encodePacked("whatever_salt"));
        bytes memory bytecode = type(Foo).creationCode;
        bytes32 bytecodeHash = keccak256(bytecode);

        address addrComputed = Create2.computeAddress(salt, bytecodeHash);
        assertEq(addrComputed, 0x5a8D9EBa165Cef7A70de7c4055c00B88dF18f726);

        // we can send ETH to a contract that will be deployed in the future
        vm.prank(alice);
        payable(addrComputed).sendValue(1 ether);
        // (bool sent,) = addrComputed.call{value: 1 ether}("");
        // require(sent, "failed to sent ether");

        address addrDeployed = Create2.deploy(1 ether, salt, bytecode);
        assertEq(addrComputed, addrDeployed);
        assertEq(addrComputed.balance, 2 ether);
    }
}
