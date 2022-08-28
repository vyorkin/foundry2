// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/test.sol";
import {console2} from "forge-std/console2.sol";
import {DutchAuction} from "../../src/concept/DutchAuction.sol";
import {NFT} from "../../src/erc/NFT.sol";

contract DutchAuctionTest is Test {
    NFT private nft;
    uint256 private nftId;
    DutchAuction private auction;
    address payable private seller;
    address payable private buyer;

    function setUp() public {
        seller = payable(address(1));
        buyer = payable(address(2));

        vm.deal(seller, 1 ether);
        vm.deal(buyer, 1 ether);

        vm.label(seller, "seller");
        vm.label(buyer, "buyer");

        nft = new NFT("Meow", "MEO", "baseUri");
        vm.label(address(nft), "NFT");

        nftId = nft.mintTo{value: nft.MINT_PRICE()}(seller);
        assertEq(nft.ownerOf(nftId), seller);

        auction = new DutchAuction(1 ether, 10, address(nft), nftId);
        vm.label(address(auction), "DutchAuction");

        vm.prank(seller);
        nft.transferFrom(seller, address(auction), nftId);
    }

    function testBuy() public {
        vm.prank(buyer);
        auction.buy{value: 1 ether}();
    }

    function testDiscount() public {
        uint256 price0 = auction.getPrice();
        console2.log("price0: ", price0);

        vm.warp(1 days);

        uint256 price1 = auction.getPrice();
        console2.log("price1: ", price1);

        vm.warp(6 days);

        uint256 price2 = auction.getPrice();
        console2.log("price2: ", price2);
    }
}
