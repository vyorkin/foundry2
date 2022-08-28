// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Signature {
    function verify(
        address _signer,
        string memory _message,
        bytes memory _sig
    ) external pure returns (bool) {
        bytes32 hash = getHash(_message);
        bytes32 signedHash = getSignedHash(hash);
        return recover(signedHash, _sig) == _signer;
    }

    function recover(bytes32 _signedHash, bytes memory _sig)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = split(_sig);
        return ecrecover(_signedHash, v, r, s);
    }

    function split(bytes memory _sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        return (r, s, v);
    }

    function getSignedHash(bytes32 _hash) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }

    function getHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }
}
