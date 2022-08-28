// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../../src/erc/NFT.sol";

contract NFTTest is DSTest {
    using stdStorage for StdStorage;

    Vm private vm = Vm(HEVM_ADDRESS);
    NFT private nft;
    StdStorage private store;

    function setUp() public {
        nft = new NFT("NFT_tutorial", "TUT", "baseUri");
    }

    function testNoMintPricePaid() public {
        vm.expectRevert(MintPriceNotPaid.selector);
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: nft.MINT_PRICE()}(address(1));
    }

    function testMaxSupplyReached() public {
        uint256 slot = store
            .target(address(nft))
            .sig("currentTokenId()")
            .find();

        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(nft.TOTAL_SUPPLY()));
        vm.store(address(nft), loc, mockedCurrentTokenId);
        uint256 price = nft.MINT_PRICE();
        emit log_named_uint("mint price", price);
        vm.expectRevert(MaxSupply.selector);
        nft.mintTo{value: price}(address(1));
    }

    function testFailMintToZeroAddress() public {
        uint256 price = nft.MINT_PRICE();
        nft.mintTo{value: price}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        // minting sets the owner in mapping variable of ERC721
        nft.mintTo{value: nft.MINT_PRICE()}(address(1));

        uint256 slotOfNewOwner = store
            .target(address(nft))
            .sig(nft.ownerOf.selector)
            .with_key(1)
            .find();

        uint160 ownerOfTokenIdOne = uint160(
            uint256(vm.load(address(nft), bytes32(abi.encode(slotOfNewOwner))))
        );
        assertEq(address(ownerOfTokenIdOne), address(1));
    }
}
