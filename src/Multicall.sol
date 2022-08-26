// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Multicall {
    function run(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target.length != data.length");
        bytes[] memory results = new bytes[](data.length);
        for (uint256 i; i < targets.length; ++i) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = result;
        }
        return results;
    }
}
