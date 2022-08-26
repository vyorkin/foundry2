// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {Vault4626} from "../Vault4626.sol";

contract Vault4626Test is Test {
    MockERC20 private underlying;
    Vault4626 private vault;

    address payable alice;
    address payable bob;

    function setUp() public {
        alice = payable(address(1));
        bob = payable(address(2));

        vm.label(alice, "alice");
        vm.label(bob, "bob");

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        underlying = new MockERC20("Token", "TKN", 18);
        vault = new Vault4626(address(underlying), "Vault Token", "vTKN");

        vm.label(address(underlying), "TKN");
        vm.label(address(vault), "Vault");

        underlying.mint(alice, 10 ether);
    }

    function testDepositWithdraw() public {
        vm.startPrank(alice);
        uint256 aliceDeposit = 1 ether;
        underlying.approve(address(vault), aliceDeposit);
        uint256 aliceShare = vault.deposit(aliceDeposit, alice);
        console2.log("alice share: %d vTKN", aliceShare / 1e18);
        assertEq(aliceShare, aliceDeposit);
        // how much shares alice will get for the given deposit
        // same as convertToShares
        assertEq(vault.previewDeposit(aliceDeposit), aliceShare);
        // how much alice can withdraw for the given amount of shares
        // same as convertToAssets
        assertEq(vault.previewWithdraw(aliceShare), aliceDeposit);

        vm.stopPrank();
    }
}
