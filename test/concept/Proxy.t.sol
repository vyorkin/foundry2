// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {Proxy} from "../../src/concept/Proxy.sol";

// https://jeiwan.net/posts/upgradeable-proxy-from-scratch/

contract Impl1 {
    uint256 value;

    constructor() {
      value = 0x42;
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

      (bool success, bytes memory data) = address(proxy).call(
        abi.encodeWithSignature("getValue()")
      );
      assertTrue(success);
      uint256 value = abi.decode(data, (uint256));

      // Slot collision:
      assertEq(value, 139029619697395845225089940521545625488669940458);
      // assertEq(value, 0x42);
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
