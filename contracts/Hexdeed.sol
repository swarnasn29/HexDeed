// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HomeRegistration is ERC721Enumerable, Ownable {
    struct Home {
        address owner;
        string propertyName;
        string propertyDescription;
        uint256 propertySize;
        uint256 registrationTime;
        string[] legalDocuments;
        string latitude; // Decimal latitude value
        string longitude; // Decimal longitude value
        string[] ipfsImageHashes; // Array of IPFS image hashes
    }

    mapping(uint256 => Home) public homes;
    mapping(uint256 => address[]) public ownershipHistory;

    mapping(uint256 => bool) public isHomeForSale;
    mapping(uint256 => uint256) public homePrices; // Mapping to store home prices

    event HomeListedForSale(uint256 indexed tokenId, uint256 price);
    event HomeSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    event HomeRegistered(
        uint256 indexed tokenId,
        address indexed owner,
        string propertyName,
        string propertyDescription,
        uint256 propertySize,
        uint256 registrationTime,
        string[] legalDocuments,
        string latitude,
        string longitude,
        string[] ipfsImageHashes
    );

    constructor(address initialOwner) ERC721("HomeRegistration", "HOME") Ownable(initialOwner) {}

    function listHomeForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can only list your own home for sale");
        isHomeForSale[_tokenId] = true;
        homePrices[_tokenId] = _price; // Set the home price
        emit HomeListedForSale(_tokenId, _price);
    }

    function updateHomePrice(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can only update the price of your own home");
        require(isHomeForSale[_tokenId], "This home is not for sale");
        homePrices[_tokenId] = _price; // Update the home price
    }

    function buyHome(uint256 _tokenId) public payable {
        require(isHomeForSale[_tokenId], "This home is not for sale");
        uint256 price = homePrices[_tokenId]; // Get the home price
        require(msg.value >= price, "Insufficient funds to buy this home");

        address payable seller = payable(ownerOf(_tokenId));
        address payable buyer = payable(msg.sender);

        (bool success,) = seller.call{value: price}("");
        require(success, "Payment to the seller failed");

        transferFrom(ownerOf(_tokenId), msg.sender, _tokenId);

        isHomeForSale[_tokenId] = false;

        emit HomeSold(_tokenId, msg.sender, price);
    }

    function registerHome(
        string memory _propertyName,
        string memory _propertyDescription,
        uint256 _propertySize,
        string[] memory _legalDocuments,
        string memory _latitude,
        string memory _longitude,
        string[] memory _ipfsImageHashes
    ) public {
        uint256 tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);

        homes[tokenId] = Home(
            msg.sender,
            _propertyName,
            _propertyDescription,
            _propertySize,
            block.timestamp,
            _legalDocuments,
            _latitude,
            _longitude,
            _ipfsImageHashes
        );
        ownershipHistory[tokenId].push(msg.sender);

        emit HomeRegistered(
            tokenId,
            msg.sender,
            _propertyName,
            _propertyDescription,
            _propertySize,
            block.timestamp,
            _legalDocuments,
            _latitude,
            _longitude,
            _ipfsImageHashes
        );
    }

    function getHomeDetails(uint256 _tokenId)
        public
        view
        returns (
            address owner,
            string memory propertyName,
            string memory propertyDescription,
            uint256 propertySize,
            uint256 registrationTime,
            string[] memory legalDocuments,
            string memory latitude,
            string memory longitude,
            string[] memory ipfsImageHashes
        )
    {
        Home memory home = homes[_tokenId];
        return (
            home.owner,
            home.propertyName,
            home.propertyDescription,
            home.propertySize,
            home.registrationTime,
            home.legalDocuments,
            home.latitude,
            home.longitude,
            home.ipfsImageHashes
        );
    }

    function getOwnershipHistory(uint256 _tokenId) public view returns (address[] memory) {
        return ownershipHistory[_tokenId];
    }
}
