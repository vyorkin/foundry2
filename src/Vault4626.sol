// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

contract Vault4626 is ERC4626 {
    constructor(address _underlying, string memory _name, string memory _symbol)
      ERC4626(ERC20(_underlying), _name, _symbol) {}

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
