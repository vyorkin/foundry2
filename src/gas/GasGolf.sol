// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract GasGolf {
    uint256 public total;

    function sumIfEvenAndLessThan99(uint256[] calldata nums) external {
        uint256 _total = total;
        for (uint256 i; i < nums.length; ++i) {
            uint256 x = nums[i];
            if (x % 2 == 0 && x < 99) {
                _total += x;
            }
        }
        total = _total;
    }
}
