// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Foo {
    event Bar();

    constructor() payable {}

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

// The destination address is calculated as the
// rightmost 20 bytes (160 bits) of the
// Keccak-256 hash of the rlp encoding of the
// sender address followed by its nonce:

// address = keccak256(rlp([sender_address,sender_nonce]))[12:]

// create(v, o, s)
// v - value in wei to send to the new account
// o - bytes offset in the memory in bytes
//     (the initialization code for the new account/contract)
// s - size of the initialization code that needs to be copied
// returns: address of the deployed contract
//          or 0 if the deployment failed

contract Proxy {
    event Deploy(address indexed addr);

    function deploy(bytes memory _code)
        external
        payable
        returns (address addr)
    {
        assembly {
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
            //             ^ msg.value       ^             ^ size of the code is stored at first 32 bytes
            //                               |
            //               actual code starts at 32 bytes
        }
        require(addr != address(0), "deploy failed");

        emit Deploy(addr);
    }

    function execute(address _target, bytes memory _data) external payable {
        (bool success, ) = _target.call{value: msg.value}(_data);
        require(success, "execute failed");
    }
}

contract Helper {
    function getFooBytecode() external pure returns (bytes memory) {
        bytes memory bytecode = type(Foo).creationCode;
        return bytecode;
    }

    function getBazBytecode(
        uint256 _quux,
        bool _corge,
        string memory _grault
    ) external pure returns (bytes memory) {
        bytes memory bytecode = type(Baz).creationCode;
        bytes memory result = abi.encodePacked(
            bytecode,
            abi.encode(_quux, _corge, _grault)
        );
        return result;
    }

    function getFooCalldata() external pure returns (bytes memory) {
        return abi.encodeWithSignature("bar()");
    }

    function getBazCalldata(uint256 _x) external pure returns (bytes memory) {
        return abi.encodeWithSignature("qux(uint256)", _x);
    }

    fallback() external payable {}
}

// new_address = hash(0xFF, sender, salt, bytecode)
//
// 0xFF - a constant that prevents collisions with CREATE
// sender - the sender’s own address
// salt - an arbitrary value provided by the sender
// bytecode - the to-be-deployed contract’s bytecode

// create2(v, p, n, s)
//
// v - amount of wei sent
// p - the start of the initCode
// n - length of the initCode
// s - the salt (256-bit value)

contract Factory {
    event Deployed(address indexed addr, bytes32 salt);

    function deployFoo2() public returns (address addr) {
        bytes32 salt = keccak256(abi.encodePacked("whatever_you_want"));
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

    function deployBaz2() public returns (address addr) {
        // Constructor args
        uint256 quux = 100;
        bool corge = true;
        string memory grault = "pohuy";

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
