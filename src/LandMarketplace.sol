// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LandMarketplace is ReentrancyGuard {
    IERC721 public landToken;

    struct Listing {
        address seller;
        uint256 price;
        bool isActive;
        uint256 listingDate;
    }

    mapping(uint256 => Listing) public listings;
    uint256[] public activeListings;
    mapping(uint256 => uint256) private listingIndex;

    event LandListed(uint256 indexed tokenId, address seller, uint256 price);
    event LandSold(uint256 indexed tokenId, address seller, address buyer, uint256 price);
    event ListingCancelled(uint256 indexed tokenId);

    constructor(address _landTokenAddress) {
        landToken = IERC721(_landTokenAddress);
    }

    function listLand(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        require(landToken.ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(landToken.getApproved(tokenId) == address(this), "Marketplace not approved");

        listings[tokenId] = Listing(msg.sender, price, true, block.timestamp);
        activeListings.push(tokenId);
        listingIndex[tokenId] = activeListings.length - 1;
        
        emit LandListed(tokenId, msg.sender, price);
    }

    function buyLand(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.isActive, "Listing not active");
        require(msg.value == listing.price, "Incorrect price");

        _removeListing(tokenId);
        
        address seller = listing.seller;
        uint256 price = listing.price;
        listing.isActive = false;

        landToken.safeTransferFrom(seller, msg.sender, tokenId);
        payable(seller).transfer(price);

        emit LandSold(tokenId, seller, msg.sender, price);
    }

    function cancelListing(uint256 tokenId) external {
        require(listings[tokenId].seller == msg.sender, "Not the seller");
        require(listings[tokenId].isActive, "Listing not active");

        _removeListing(tokenId);
        delete listings[tokenId];
        
        emit ListingCancelled(tokenId);
    }

    function getAllActiveListings() public view returns (uint256[] memory) {
        return activeListings;
    }

    function getActiveListing(uint256 tokenId) 
        public 
        view 
        returns (
            address seller,
            uint256 price,
            uint256 listingDate
        ) 
    {
        Listing memory listing = listings[tokenId];
        require(listing.isActive, "Listing not active");
        return (listing.seller, listing.price, listing.listingDate);
    }

    function _removeListing(uint256 tokenId) internal {
        uint256 index = listingIndex[tokenId];
        uint256 lastTokenId = activeListings[activeListings.length - 1];

        if (tokenId != lastTokenId) {
            activeListings[index] = lastTokenId;
            listingIndex[lastTokenId] = index;
        }

        activeListings.pop();
        delete listingIndex[tokenId];
    }
}