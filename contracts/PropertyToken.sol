pragma solidity 0.8.18;

//openzeppelin interface for ERC721 contract (love)
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyToken is ERC721, Ownable {
  
    using Counters for Counters.Counter;

   //NFT name and symbol
   
    Counters.Counter private _tokenIdCounter;   

    constructor() ERC721("PropertyToken", "PPTT") {}

    //mint function
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
    }

    function ownerNft(uint256 tokenId) external view returns(address){   
            return(ownerOf(tokenId));        
    }


    function transfer(address from, address to,uint256 tokenId) external payable{
            transferOwnership(to);
            transferFrom(from,to,tokenId);
    }

    function nftBalance(address _address) public view returns(uint256 _balance){
            return(balanceOf(_address));
   
    }





}