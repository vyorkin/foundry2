// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";

library Signature {
    error InvalidSignature();

    function toVRS(bytes memory signature)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        if (signature.length == 65) {
            // ecrecover takes the signature parameters,
            // and the only way to get them currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else {
            revert InvalidSignature();
        }
    }

    function fromVRS(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(r, s, v);
    }
}

contract SignTest is Test {
    using ECDSA for bytes32;

    uint256 private immutable alicePk = 1;
    uint256 private immutable bobPk = 2;
    address private immutable alice = vm.addr(1);
    address private immutable bob = vm.addr(2);

    function setUp() public {}

    function testSignature() public {
        bytes32 hash = keccak256("signed by Alice");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hash);
        address signer = ecrecover(hash, v, r, s);
        assertEq(alice, signer);

        bytes memory signature = Signature.fromVRS(v, r, s);
        (uint8 v1, bytes32 r1, bytes32 s1) = Signature.toVRS(signature);
        signer = ecrecover(hash, v1, r1, s1);
        assertEq(alice, signer);
    }

    function testRecoverVRS() public {
        bytes32 h = keccak256(abi.encodePacked(uint256(1), "whatever"));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, h);
        bytes memory signature = Signature.fromVRS(v, r, s);
        console2.log("signature length: %d", signature.length);
        (uint8 v1, bytes32 r1, bytes32 s1) = Signature.toVRS(signature);

        assertEq(v, v1);
        assertEq(r, r1);
        assertEq(s, s1);
    }
}
