// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {Proxy} from "../../src/concept/Proxy.sol";

// https://jeiwan.net/posts/upgradeable-proxy-from-scratch/

contract Impl1 {
    bool initialized;
    uint256 value;

    // When constructor is used to initialize state variables,
    // they’re initialized within the state of the contract.
    // But we want them to be initialized within the state of the proxy contract.
    constructor() {
        value = 0x42;
    }

    function initialize() public {
        require(!initialized, "already initialized");

        value = 0x42;
        initialized = true;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }

    function say() public view returns (uint8) {
        console2.log("impl1");
        return 1;
    }
}

contract Impl2 {
    bool initialized;
    uint256 value;

    function initialize() public {
        require(!initialized, "already initialized");

        value = 0x42;
        initialized = true;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }

    function say() public view returns (uint8) {
        console2.log("impl2");
        return 2;
    }
}

contract ProxyTest is Test {
    Impl1 private impl1;
    Impl2 private impl2;
    Proxy private proxy;

    function setUp() public {
        proxy = new Proxy();
        impl1 = new Impl1();
        impl2 = new Impl2();
    }

    function testGetValue() public {
        proxy.setImpl(address(impl1));
        Impl1 proxied1 = Impl1(address(proxy));
        proxied1.initialize();

        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success);
        uint256 value1 = abi.decode(data, (uint256));

        // Slot collision:
        // assertEq(value, 139029619697395845225089940521545625488669940458);

        assertEq(value1, 0x42);

        proxy.setImpl(address(impl2));
        Impl2 proxied2 = Impl2(address(proxy));

        proxied2.setValue(0x44);
        assertEq(0x44, proxied2.getValue());
        proxy.setImpl(address(impl1));
        assertEq(0x44, proxied1.getValue());
    }

    function testProxy() public {
        proxy.setImpl(address(impl1));

        (bool success1, bytes memory data1) = address(proxy).call(
            abi.encodeWithSignature("say()")
        );
        assertTrue(success1);
        uint8 x1 = abi.decode(data1, (uint8));
        assertEq(x1, 1);

        proxy.setImpl(address(impl2));

        (bool success2, bytes memory data2) = address(proxy).call(
            abi.encodeWithSignature("say()")
        );
        assertTrue(success2);
        uint8 x2 = abi.decode(data2, (uint8));
        assertEq(x2, 2);
    }
}
