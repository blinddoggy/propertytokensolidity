// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./PropertyToken.sol";

contract PropertyMaster is Ownable{

    PropertyToken[] public properties;

     struct Proyecto {
        string name;
        string symbol;
        string img;
        uint256 balanceERC20;
        uint256 balanceERC721;
        address nftAddress;
    }

    function getTokenIndex(string memory ipfsHash) public view returns (uint256) {
    for (uint256 i = 0; i < properties.length; i++) {
        if (keccak256(bytes(properties[i].getHash())) == keccak256(bytes(ipfsHash))) {
            return i;
        }
    }
        revert("No token found with the given IPFS hash");
    }

    //llamas no por index si no por hash
    //function getProject(uint256 index,address nftAddress)
      //  public
       // view
        //returns (Proyecto memory)
    //{
        //address owner = owner();
      //  return
        //    Proyecto(
          //      getPropertyName(index),
            //    getPropertySymbol(index),
                //address del contrato
                //getPropertyBalance(index,nftAddress),
              //  getPropertyUri(index)
                //properties[index].address(his).balance
            //);
   // }

    function getProject(string memory ipfsHash) public view returns (Proyecto memory) {
    uint256 index = getTokenIndex(ipfsHash);
    return Proyecto(
        properties[index].name(),
        properties[index].symbol(),
        //properties[index].getNFTBalance(nftAddress),
        properties[index].tokenURI(0),
        address(properties[index]).balance,
        properties[index].balanceOf(properties[index].getAddress()),
        properties[index].getAddress()
    );
    }

    event NewPropertyToken(address indexed _address, uint256 indexed _tokenId);

    function createNewProperty(string memory name, string memory symbol, string memory ipfsHash) public payable returns( PropertyToken ) {
        PropertyToken ppt = new PropertyToken(name, symbol, ipfsHash);
        properties.push(ppt);
        emit NewPropertyToken(address(this), properties.length);
        return ppt;
    }
    //get hash
    function getPropertyHash(uint256 index) public  view returns(string memory){
        return properties[index].getHash();
    }
    //get name
    function getPropertyName(uint256 index) public  view returns(string memory){
        return properties[index].name();
    }
    
    //get symbol
    function getPropertySymbol(uint256 index) public  view returns(string memory){
        return properties[index].symbol();
    }

    //function URI
    function getPropertyUri(uint256 index) public  view returns(string memory){
        return properties[index].tokenURI(0);
    }

    //get balance NFT
     //function getPropertyBalance(uint256 index,address nftAddress) public  view returns(uint256){
       // return properties[index].getNFTBalance(nftAddress);
   // }





    function mintProjectSelfOwner(uint256 index) public{
     //   address owner = properties[index].address(this);
       // properties[index].safeMint(owner,"");
    }

    function mintProjectMasterOwner(uint256 index) public {
        address owner = owner();
        properties[index].safeMint(owner, "");
    }
     
}

