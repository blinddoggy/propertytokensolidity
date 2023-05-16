// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyToken is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string ipfsHash;

    struct Proyecto {
        string name;
        string symbol;
        uint256 amount;
        string img;
        uint256 balance;
    }

    constructor(string memory name, string memory symbol, string memory _ipfsHash ) 
        ERC721( name , symbol) notEmptyConstuctor(name, symbol) {
            ipfsHash = _ipfsHash;
        }

    modifier notEmptyConstuctor(string memory name, string memory symbol){
        // for(uint i = 0; i<args.length; i++ ){
        require( ! compareStrings(name, "") );
        require( ! compareStrings(symbol, "") );
        _;
    }

    function getHash() public view returns (string memory) {
        return ipfsHash;
    }

    function getProject()
        public
        view
        returns (Proyecto memory)
    {
        address owner = owner();
        return
            Proyecto(
                name(),
                symbol(),
                balanceOf(owner),
                tokenURI(0),
                address(this).balance
            );
    }

    function getAddress() public view returns(address){
        return address(this);
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function concatenate(string memory a,string memory b) public pure returns (string memory){
        return string(bytes.concat(bytes(a), bytes(b)));
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _baseURI() internal view override returns (string memory) {
        string memory url = "https://ipfs.io/ipns/";
        string memory hash = getHash();
        return concatenate(url,hash);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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