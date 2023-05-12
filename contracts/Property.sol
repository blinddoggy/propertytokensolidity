// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "@openzeppelin/contracts/token/BEP20/BEP20.sol";

interface IBEP20 {
    function balanceOf(address) external view returns (uint256);
}




/// @custom:security-contact cucarachatraicionera@gmail.com
contract Property is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string ipfsHash;
    address tokenAddress = 0x242a1fF6eE06f2131B7924Cacb74c7F9E3a5edc9;

    constructor(
        string memory nombre,
        string memory simbolo,
        string memory _ipfsHash
    ) ERC721(nombre, simbolo) {
        ipfsHash = _ipfsHash;
    }

    function getHash() public view returns (string memory) {
        return ipfsHash;
    }

    //easy concatenate
    function concatenate(string memory a,string memory b) public pure returns (string memory){
        return string(bytes.concat(bytes(a), bytes(b)));
    } 

    function _baseURI() internal view override returns (string memory) {
        string memory url = "https://ipfs.io/ipns/";
        string memory hash = getHash();
        return concatenate(url,hash);
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

    

    struct Proyecto {
        string name;
        string symbol;
        uint256 amount;
        string img;
        uint256 balance;
    }

    //function returning struct
    function getproject(address contractProjectAddress)
        public
        view
        returns (Proyecto memory)
    {
        address owner = owner();
        return
            Proyecto(
                name(),
                symbol(),
                balanceNfts(owner),
                tokenURI(0),
                address(this).balance
            );
    }

    //balance token ERC20 contract
    function balanceToken(address tknDdrss, address ddrss)
        public
        view
        returns (uint256)
    {
        return IERC20(tknDdrss).balanceOf(ddrss);
        //return IBEP20(tknDdrss).balanceOf(ddrss);
    }

    //balanace nft contract
    function balanceNfts(address ddrss) public view returns (uint256) {
        return balanceOf(ddrss);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

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
