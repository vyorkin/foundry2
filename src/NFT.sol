// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// gas optimised implementation of the ERC721 standard
import "solmate/tokens/ERC721.sol";

import "openzeppelin/utils/Strings.sol";
import "openzeppelin/access/Ownable.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    string public baseURI;
    uint256 public currentTokenId;

    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    function mintTo(address recipient) public payable returns (uint256) {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        uint256 newItemId = ++currentTokenId;
        if (newItemId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(_tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _tokenId.toString()))
                : "";
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payee.call{value: balance}("");
        if (!success) {
            revert WithdrawTransfer();
        }
    }
}
