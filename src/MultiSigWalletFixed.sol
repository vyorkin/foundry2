// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";

contract MultiSigWalletFixed {
    using ECDSA for bytes32;

    error InvalidSigError(address sig, address owner);
    error ReplaySigError(bytes32 txHash);

    address[2] public owners;
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(
        address _to,
        uint256 _amount,
        uint256 _nonce,
        bytes[2] memory _sigs
    ) external {
        bytes32 txHash = getTxHash(_to, _amount, _nonce);

        if (executed[txHash]) {
            revert ReplaySigError(txHash);
        }
        _checkSigs(_sigs, txHash);

        executed[txHash] = true;

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "failed to send Ether");
    }

    function getTxHash(
        address _to,
        uint256 _amount,
        uint256 _nonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }

    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash) private view {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint256 i; i < _sigs.length; ++i) {
            address signer = ethSignedHash.recover(_sigs[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                revert InvalidSigError(signer, owners[i]);
            }
        }
    }
}
