// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Foo {
    event Bar();

    function bar() public {
        emit Bar();
    }
}

contract Baz {
    event Qux(uint256 x);

    uint256 quux;
    bool corge;
    string grault;

    constructor(
        uint256 _quux,
        bool _corge,
        string memory _grault
    ) {
        quux = _quux;
        corge = _corge;
        grault = _grault;
    }

    function qux(uint256 x) public {
        emit Qux(x);
    }
}

error Failed(string name);

// create2(v, p, n, s)
// v - amount of wei sent
// p - the start of the initCode
// n - length of the initCode
// s - the salt (256-bit value)

contract Factory {
    event Deployed(address addr, bytes32 salt);

    function deployFoo() public returns (address addr) {
        bytes32 salt = keccak256(abi.encodePacked("poebat"));
        bytes memory bytecode = type(Foo).creationCode;
        assembly {
            // bytecode is a dynamic bytes array,
            // first 32 bytes are to store the length of the array,
            // so here we shift the location of bytecode - add 32 bytes
            addr := create2(0, add(bytecode, 32), mload(bytecode), salt)
            //              ^    ^                  ^                ^ the salt
            //              |    |                  |- length of initCode
            //              |    |- start of initCode
            //              |- amount of wei sent
            //
            // mload loads a single word (32 bytes) located at the memory address
            // and as mentioned above, first 32 bytes of bytecode is the length

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, salt);
    }

    function deployBaz() public returns (address addr) {
        // Constructor args
        uint256 quux = 100;
        bool corge = true;
        string memory grault = "pohuyu";

        bytes32 salt = keccak256(abi.encodePacked(quux, corge, grault));

        bytes memory bytecode = type(Baz).creationCode;

        // The Baz contract needs arguments, so we need to
        // encode them and append after the creationCode (bytecode var)
        bytes memory args = abi.encode(quux, corge, grault);

        bytes memory initCode = abi.encodePacked(bytecode, args);

        assembly {
            addr := create2(0, add(initCode, 32), mload(initCode), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, salt);
    }
}
