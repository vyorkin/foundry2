// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {MultiSigWallet} from "../MultiSigWallet.sol";
import {MultiSigWalletFixed} from "../MultiSigWalletFixed.sol";

contract MultiSigWalletTest is Test {
    using ECDSA for bytes32;

    uint256 private immutable alicePk = 1;
    uint256 private immutable bobPk = 2;
    uint256 private immutable charliePk = 2;

    address private immutable alice = vm.addr(1);
    address private immutable bob = vm.addr(2);
    address private immutable charlie = vm.addr(3);

    MultiSigWallet private wallet;
    MultiSigWalletFixed private walletFixed;

    function setUp() public {
        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(charlie, "charlie");

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 100 ether);

        // console2.log("alice: ", alice);
        // console2.log("bob: ", bob);
        // console2.log("charlie: ", charlie);

        address[2] memory owners = [alice, bob];
        wallet = new MultiSigWallet(owners);
        walletFixed = new MultiSigWalletFixed(owners);

        vm.label(address(wallet), "MultiSigWallet");
        vm.label(address(walletFixed), "MultiSigWalletFixed");

        vm.prank(alice);
        wallet.deposit{value: 9 ether}();

        vm.prank(bob);
        wallet.deposit{value: 9 ether}();

        vm.prank(charlie);
        walletFixed.deposit{value: 100 ether}();
    }

    function testReplay() public {
        bytes32 hash = wallet.getTxHash(alice, 4 ether);
        bytes32 signedHash = hash.toEthSignedMessageHash();

        (uint8 va, bytes32 ra, bytes32 sa) = vm.sign(alicePk, signedHash);
        (uint8 vb, bytes32 rb, bytes32 sb) = vm.sign(bobPk, signedHash);

        uint8[2] memory vs = [va, vb];
        bytes32[2] memory rs = [ra, rb];
        bytes32[2] memory ss = [sa, sb];

        // first tx
        wallet.transfer(alice, 4 ether, vs, rs, ss);
        // replay tx
        wallet.transfer(alice, 4 ether, vs, rs, ss);

        assertEq(alice.balance, 9 ether);
    }

    function testReplayFixed() public {
        bytes32 hash = walletFixed.getTxHash(alice, 4 ether, 1);
        bytes32 signedHash = hash.toEthSignedMessageHash();

        (uint8 va, bytes32 ra, bytes32 sa) = vm.sign(alicePk, signedHash);
        (uint8 vb, bytes32 rb, bytes32 sb) = vm.sign(bobPk, signedHash);

        bytes memory aliceSig = abi.encodePacked(ra, sa, va);
        bytes memory bobSig = abi.encodePacked(rb, sb, vb);

        bytes[2] memory sigs = [aliceSig, bobSig];

        walletFixed.transfer(alice, 4 ether, 1, sigs); // tx 1
        vm.expectRevert(
            abi.encodeWithSelector(
                MultiSigWalletFixed.ReplaySigError.selector,
                hash
            )
        );
        walletFixed.transfer(alice, 4 ether, 1, sigs); // replay tx 1
        assertEq(alice.balance, 5 ether);
    }
}
