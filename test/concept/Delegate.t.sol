// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {console2} from "forge-std/console2.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Test} from "forge-std/test.sol";

contract A {
    event LogSender(address);

    function a() public {
        emit LogSender(msg.sender);
    }
}

contract B {
    event LogSender(address);

    function b(A _a) public {
        emit LogSender(msg.sender);
        _a.a();
    }
}

contract C {
    using Address for address;

    event LogSender(address);

    B private b;

    constructor(B _b) {
        b = _b;
    }

    function run(address _target, bytes calldata _data) external {
        emit LogSender(msg.sender);
        _target.functionDelegateCall(_data);
    }
}

contract DelegateTest is Test {
    event LogSender(address);

    A private a;
    B private b;
    C private c;

    function setUp() public {
        a = new A();
        b = new B();
        c = new C(b);

        vm.label(address(a), "A");
        vm.label(address(b), "B");
        vm.label(address(c), "C");
    }

    function testDelegate() public {
        bytes memory data = abi.encodeWithSelector(B.b.selector, a);
        c.run(address(b), data);
    }
}
