// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IERC721} from "openzeppelin/interfaces/IERC721.sol";

contract NFTMarketplace is ReentrancyGuard {
    error AlreadyListedError(address nft, uint256 tokenId);
    error NotListedError(address nft, uint256 tokenId);
    error NotOwnerError(address spender, address owner);
    error PriceMustBeAboveZeroError();
    error NotApprovedForMarketplaceError();
    error PriceNotMetError(address nft, uint256 tokenId, uint256 price);
    error NoProceedsError();

    struct Listing {
        uint256 price;
        address seller;
    }

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

    mapping(address => mapping(uint256 => Listing)) private listings;
    mapping(address => uint256) private proceeds;

    modifier notListed(address nft, uint256 tokenId) {
        Listing memory listing = listings[nft][tokenId];
        if (listing.price > 0) {
            revert AlreadyListedError(nft, tokenId);
        }
        _;
    }

    modifier isListed(address nft, uint256 tokenId) {
        Listing memory listing = listings[nft][tokenId];
        if (listing.price == 0) {
            revert NotListedError(nft, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nft,
        uint256 tokenId,
        address spender
    ) {
        address owner = IERC721(nft).ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwnerError(spender, owner);
        }
        _;
    }

    /**
     * @notice Lists a given NFT.
     * @param nft NFT contract address.
     * @param tokenId NFT token id.
     * @param price NFT sale price.
     */
    function list(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external notListed(nft, tokenId) isOwner(nft, tokenId, msg.sender) {
        if (price == 0) {
            revert PriceMustBeAboveZeroError();
        }
        if (IERC721(nft).getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplaceError();
        }
        listings[nft][tokenId] = Listing(price, msg.sender);
        emit Listed(msg.sender, nft, tokenId, price);
    }

    /**
     * @notice Cancels NFT listing.
     * @param nft NFT contract address.
     * @param tokenId NFT token id.
     */
    function cancel(address nft, uint256 tokenId)
        external
        isListed(nft, tokenId)
        isOwner(nft, tokenId, msg.sender)
    {
        delete listings[nft][tokenId];
        emit Canceled(msg.sender, nft, tokenId);
    }

    /**
     * @notice Buys NFT listing.
     * @param nft NFT contract address.
     * @param tokenId NFT token id.
     */
    function buy(address nft, uint256 tokenId)
        external
        payable
        isListed(nft, tokenId)
        nonReentrant
    {
        Listing memory item = listings[nft][tokenId];
        if (msg.value < item.price) {
            revert PriceNotMetError(nft, tokenId, item.price);
        }
        proceeds[item.seller] += msg.value;
        delete listings[nft][tokenId];
        IERC721(nft).safeTransferFrom(item.seller, msg.sender, tokenId);
        emit Bought(msg.sender, nft, tokenId, item.price);
    }

    function withdrawProceeds() external {
        uint256 amount = proceeds[msg.sender];
        if (amount == 0) {
            revert NoProceedsError();
        }
        proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");
    }
}
