// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";

contract MultiSigWallet {
    using ECDSA for bytes32;

    error InvalidSig(address sig, address owner);

    address[2] public owners;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(
        address _to,
        uint256 _amount,
        uint8[2] memory _vs,
        bytes32[2] memory _rs,
        bytes32[2] memory _ss
    ) external {
        require(_vs.length == _rs.length);
        require(_rs.length == _ss.length);

        bytes32 txHash = getTxHash(_to, _amount);
        _checkSigs(_vs, _rs, _ss, txHash);

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "failed to send Ether");
    }

    function getTxHash(address _to, uint256 _amount)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    function _checkSigs(
        uint8[2] memory _vs,
        bytes32[2] memory _rs,
        bytes32[2] memory _ss,
        bytes32 _txHash
    ) private view {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint256 i; i < _vs.length; ++i) {
            address signer = ethSignedHash.recover(_vs[i], _rs[i], _ss[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                revert InvalidSig(signer, owners[i]);
            }
        }
    }
}
