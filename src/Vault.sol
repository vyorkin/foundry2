// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IERC20} from "openzeppelin/interfaces/IERC20.sol";

contract Vault {
    IERC20 public immutable token;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint256 _amount) private {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }

    function _burn(address _to, uint256 _amount) private {
        totalSupply -= _amount;
        balanceOf[_to] -= _amount;
    }

    function deposit(uint256 _amount) external {
        // a = amount
        // B = balance of token before deposit
        // T = total supply
        // s = shares to mint

        // (T + s) / T = (a + B) / B
        // s = aT / B

        uint256 shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _shares) external {
        // a = amount
        // B = balance of token before withdraw
        // T = total supply
        // s = shares to burn

        // (T - s) / T = (B - a) / B
        // a = sB / T

        uint256 amount = (_shares * token.balanceOf(address(this))) / totalSupply;

        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
}
