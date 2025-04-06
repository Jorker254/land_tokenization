// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LandToken.sol";
import "../src/LandMarketplace.sol";

contract LandMarketplaceTest is Test {
    LandToken public landToken;
    LandMarketplace public marketplace;

    address public admin = makeAddr("admin");
    address public seller = makeAddr("seller");
    address public buyer = makeAddr("buyer");

    event LandListed(uint256 indexed tokenId, address seller, uint256 price);
    event LandSold(uint256 indexed tokenId, address seller, address buyer, uint256 price);

    function setUp() public {
        vm.startPrank(admin);
        landToken = new LandToken();
        marketplace = new LandMarketplace(address(landToken));
        vm.stopPrank();
    }

    function _mintTestToken(address to) internal returns (uint256) {
        string[] memory polygonCoordinates = new string[](4);
        polygonCoordinates[0] = "-1.2345,6.7890";
        polygonCoordinates[1] = "-1.2346,6.7891";
        polygonCoordinates[2] = "-1.2347,6.7892";
        polygonCoordinates[3] = "-1.2345,6.7890";

        vm.prank(admin);
        return landToken.mintLandToken(
            to,
            "DEED123",
            "123 Main St",
            1000,
            "-1.2345",
            "6.7890",
            polygonCoordinates,
            "Residential",
            "John Doe",
            "ID123456",
            "TAX001",
            "MUN001"
        );
    }

    function testListAndBuyLand() public {
        uint256 tokenId = _mintTestToken(seller);

        // List token
        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);

        vm.expectEmit(true, false, false, true);
        emit LandListed(tokenId, seller, 1 ether);

        marketplace.listLand(tokenId, 1 ether);
        vm.stopPrank();

        // Buy token
        vm.deal(buyer, 1 ether);
        vm.startPrank(buyer);

        vm.expectEmit(true, false, false, true);
        emit LandSold(tokenId, seller, buyer, 1 ether);

        marketplace.buyLand{value: 1 ether}(tokenId);

        assertEq(landToken.ownerOf(tokenId), buyer);
        assertEq(buyer.balance, 0);
        assertEq(seller.balance, 1 ether);

        vm.stopPrank();
    }

    function test_RevertWhen_ListingWithoutApproval() public {
        uint256 tokenId = _mintTestToken(seller);

        vm.startPrank(seller);
        vm.expectRevert("Marketplace not approved");
        marketplace.listLand(tokenId, 1 ether);
        vm.stopPrank();
    }

    function test_RevertWhen_BuyingWithIncorrectPrice() public {
        uint256 tokenId = _mintTestToken(seller);

        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        marketplace.listLand(tokenId, 1 ether);
        vm.stopPrank();

        vm.deal(buyer, 0.5 ether);
        vm.startPrank(buyer);
        vm.expectRevert("Incorrect price");
        marketplace.buyLand{value: 0.5 ether}(tokenId);
        vm.stopPrank();
    }
}
