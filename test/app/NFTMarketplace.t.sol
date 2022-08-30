// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/test.sol";
import {console2} from "forge-std/console2.sol";
import {NFTMarketplace} from "../../src/app/NFTMarketplace.sol";
import {MEOW} from "../../src/erc/MEOW.sol";

contract NFTMarketplaceTest is Test {
    event Listed(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 price
    );
    event Canceled(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId
    );
    event Bought(
        address indexed buyer,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 price
    );

    NFTMarketplace private marketplace;
    MEOW private meow;

    address private alice;
    address private bob;

    string constant CAT1 =
        "https://ipfs.io/ipfs/QmNNYd5F26Ffdqnp4QCAwWkd3GPcMUKiaUD9d7JhjT9Hrz?filename=colorful-space-felines-galactic-cats-jen-bartel-1.jpeg";
    string constant CAT2 =
        "https://ipfs.io/ipfs/QmPamCCTTvbCvgHmkX8qYWube47ooU7VgDJiPQQwbjRqDF?filename=colorful-space-felines-galactic-cats-jen-bartel-2.jpeg";

    uint256 private cat1;
    uint256 private cat2;

    function setUp() public {
        alice = address(1);
        bob = address(2);

        vm.label(alice, "alice");
        vm.label(bob, "bob");

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        marketplace = new NFTMarketplace();
        vm.label(address(marketplace), "NFTMarketplace");

        meow = new MEOW();
        vm.label(address(meow), "MEOW");

        cat1 = meow.mint(alice, CAT1);
        cat2 = meow.mint(bob, CAT2);

        vm.prank(alice);
        meow.approve(address(marketplace), cat1);
        vm.prank(bob);
        meow.approve(address(marketplace), cat2);
    }

    function testList() public {
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Listed(alice, address(meow), cat1, 1 ether);
        marketplace.list(address(meow), cat1, 1 ether);

        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit Listed(bob, address(meow), cat2, 2 ether);
        marketplace.list(address(meow), cat2, 2 ether);
    }

    function testBuyWithdraw() public {
        vm.prank(alice);
        marketplace.list(address(meow), cat1, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit Bought(bob, address(meow), cat1, 1 ether);
        vm.prank(bob);
        marketplace.buy{value: 1 ether}(address(meow), cat1);

        vm.prank(alice);
        marketplace.withdrawProceeds();
        assertEq(alice.balance, 11 ether);
    }

    function testCancel() public {
        vm.startPrank(alice);
        marketplace.list(address(meow), cat1, 1 ether);
        vm.expectEmit(true, true, true,true);
        emit Canceled(alice, address(meow), cat1);
        marketplace.cancel(address(meow), cat1);
        vm.stopPrank();
    }
}
