// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable 
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint => address) public mintTokenIdToOwner;
    uint256[] private mintTokenIdKeys;

    string ipfsHash;

    constructor(
        string memory name,
        string memory symbol,
        string memory _ipfsHash
    ) ERC721(name, symbol) {
        require(!compareStrings(name, ""));
        require(!compareStrings(symbol, ""));
        ipfsHash = _ipfsHash;
        //transferOwnership(_propertyMaster);

    }

    function getHash() public view returns (string memory) {
        return ipfsHash;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function concatenate(
            string memory a,
            string memory b
        ) public pure returns (string memory) {
            return string(bytes.concat(bytes(a), bytes(b)));
    }

    function getTokenIdWithoutOwner() public view returns (uint256) {
        for (uint i = 0; i < mintTokenIdKeys.length; i++) {
            if (mintTokenIdToOwner[i] == address(0)) {
                return i;
            }
        }
        revert("There are no NFTs without owner");
    }

    function safeBatchMint(
        address to,
        uint256 numTokens,
        string memory baseUri
    ) public onlyOwner {
        for (uint256 i = 0; i < numTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            mintTokenIdKeys.push(tokenId);
            mintTokenIdToOwner[tokenId] = address(0);
            _setTokenURI(
                tokenId,
                string(abi.encodePacked(baseUri, uint2str(tokenId)))
            );
        }
    }

    function uint2str(
        uint256 _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function safeMint(address to, address approved, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        approve(approved, tokenId);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _baseURI() internal view override returns (string memory) {
        string memory url = "https://ipfs.io/ipns/";
        string memory hash = getHash();
        return concatenate(url, hash);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}