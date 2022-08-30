// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Counters} from "openzeppelin/utils/Counters.sol";

contract MEOW is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    error MaxSupplyError();

    uint256 constant MAX_SUPPLY = 10;

    Counters.Counter private _tokenId;

    constructor() ERC721("Meow Meow", "MEOW") {}

    function mint(address to, string memory uri) public returns (uint256 tokenId) {
        tokenId = _tokenId.current();
        if (tokenId > MAX_SUPPLY) {
            revert MaxSupplyError();
        }
        _tokenId.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
