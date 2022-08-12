// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

struct Foo {
    bool x;
    uint256 y;
    uint256 z;
}

contract Storage {
    uint256 public exists = 1;

    Foo[] public foos;

    constructor() {
        foos.push(Foo(false, 1, 2));
        foos.push(Foo({x: true, y: 3, z: 4}));
        Foo memory foo;
        foo.x = false;
        foo.y = 5;
        foo.z = 6;
        foos.push(foo);
    }
}
