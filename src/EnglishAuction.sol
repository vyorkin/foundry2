// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IERC721} from "openzeppelin/interfaces/IERC721.sol";

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address highestBidder, uint256 amount);

    IERC721 public immutable nft;
    uint256 public immutable nftId;
    address payable public immutable seller;
    uint32 public endAt;

    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bidsToRefund;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid) {
        seller = payable(msg.sender);
        nft = IERC721(_nft);
        nftId = _nftId;
        highestBid = _startingBid;
    }

    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");

        started = true;
        endAt = uint32(block.timestamp + 60);

        emit Start();
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest bid");

        if (highestBidder != address(0)) {
            bidsToRefund[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = bidsToRefund[msg.sender];
        bidsToRefund[msg.sender] = amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function end() external {
        require(started, "not started");
        require(!ended, "ended");
        require(block.timestamp >= endAt, "not ended");

        ended = true;

        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}
