// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/test.sol";
import {console2} from "forge-std/console2.sol";
import {EnglishAuction} from "../EnglishAuction.sol";
import {NFT} from "../NFT.sol";

contract EnglishAuctionTest is Test {
    NFT private nft;
    uint256 private nftId;
    EnglishAuction private auction;
    address payable private seller;
    address payable private buyer;

    function setUp() public {
        seller = payable(address(1));
        buyer = payable(address(2));

        vm.deal(seller, 1 ether);
        vm.deal(buyer, 1 ether);

        vm.label(seller, "seller");
        vm.label(buyer, "buyer");

        nft = new NFT("Moew", "MEO", "baseUri");
        vm.label(address(nft), "NFT");

        nftId = nft.mintTo{value: nft.MINT_PRICE()}(seller);
        assertEq(nft.ownerOf(nftId), seller);

        auction = new EnglishAuction(address(nft), nftId, 0.1 ether);
        vm.label(address(auction), "EnglishAuction");

        vm.prank(seller);
        nft.transferFrom(seller, address(auction), nftId);
    }

    function testBuy() public {
    }
}
