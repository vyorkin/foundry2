// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _ntfId) external;
}

contract DutchAuction {
    uint256 private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint256 public immutable nftId;
    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;

    constructor(uint256 _startingPrice, uint256 _discountRate, address _nft, uint256 _nftId) {
        require(_startingPrice >= _discountRate * DURATION, "startingPrice < DISCOUNT");

        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;

        nft = IERC721(_nft);
        nftId = _nftId;

        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(address(this), msg.sender, nftId);

        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        selfdestruct(seller);
    }
}
