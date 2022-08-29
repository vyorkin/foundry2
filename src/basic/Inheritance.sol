// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract A {
    function x() public virtual returns (uint256) {
        return 1;
    }
}

contract B {
    function x() public virtual returns (uint256) {
        return 2;
    }
}

contract C is A, B {
    function x() public override(A, B) returns (uint256) {
        return super.x();
    }
}

contract D is B, A {
    function x() public override(A, B) returns (uint256) {
        return super.x();
    }
}
