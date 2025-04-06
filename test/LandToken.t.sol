// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LandToken.sol";
import "../src/LandMarketplace.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract LandTokenizationTest is Test {
    LandToken public landToken;
    LandMarketplace public marketplace;

    address public admin = makeAddr("admin");
    address public seller = makeAddr("seller");
    address public buyer = makeAddr("buyer");

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event LandTokenMinted(
        uint256 indexed tokenId, string titleDeedNumber, address indexed owner, string latitude, string longitude
    );

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

    function testMintLandToken() public {
        vm.startPrank(admin);

        string[] memory polygonCoordinates = new string[](4);
        polygonCoordinates[0] = "-1.2345,6.7890";
        polygonCoordinates[1] = "-1.2346,6.7891";
        polygonCoordinates[2] = "-1.2347,6.7892";
        polygonCoordinates[3] = "-1.2345,6.7890";

        vm.expectEmit(true, true, false, true);
        emit LandTokenMinted(0, "DEED123", seller, "-1.2345", "6.7890");

        uint256 tokenId = landToken.mintLandToken(
            seller,
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

        assertEq(landToken.ownerOf(tokenId), seller);

        LandToken.LandDetails memory details = landToken.getLandDetails(tokenId);
        assertEq(details.titleDeedNumber, "DEED123");
        assertEq(details.location, "123 Main St");
        assertEq(details.area, 1000);
        assertEq(details.ownerName, "John Doe");
        assertEq(details.isVerified, false);

        vm.stopPrank();
    }

    function test_RevertWhen_MintingWithoutRole() public {
        string[] memory polygonCoordinates = new string[](4);

        vm.startPrank(seller);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, seller, MINTER_ROLE)
        );
        landToken.mintLandToken(
            seller,
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
        vm.stopPrank();
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

    function testCancelListing() public {
        uint256 tokenId = _mintTestToken(seller);

        // List and cancel token
        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        marketplace.listLand(tokenId, 1 ether);
        marketplace.cancelListing(tokenId);
        vm.stopPrank();

        // Try to buy cancelled listing
        vm.deal(buyer, 1 ether);
        vm.startPrank(buyer);
        vm.expectRevert("Listing not active");
        marketplace.buyLand{value: 1 ether}(tokenId);
        vm.stopPrank();
    }

    function test_RevertWhen_ListingWithoutApproval() public {
        uint256 tokenId = _mintTestToken(seller);

        // Try to list without approval
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

        // Try to buy with incorrect price
        vm.deal(buyer, 0.5 ether);
        vm.startPrank(buyer);
        vm.expectRevert("Incorrect price");
        marketplace.buyLand{value: 0.5 ether}(tokenId);
        vm.stopPrank();
    }

    function testGeographicalFeatures() public {
        vm.startPrank(admin);

        string[] memory polygonCoordinates = new string[](4);
        polygonCoordinates[0] = "-1.2345,6.7890";
        polygonCoordinates[1] = "-1.2346,6.7891";
        polygonCoordinates[2] = "-1.2347,6.7892";
        polygonCoordinates[3] = "-1.2345,6.7890";

        uint256 tokenId = landToken.mintLandToken(
            seller,
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

        LandToken.LandDetails memory details = landToken.getLandDetails(tokenId);

        assertEq(details.geoLocation.latitude, "-1.2345");
        assertEq(details.geoLocation.longitude, "6.7890");
        assertEq(details.geoLocation.polygonCoordinates.length, 4);
        assertEq(details.geoLocation.polygonCoordinates[0], "-1.2345,6.7890");

        // Test boundary update
        string[] memory newPolygonCoordinates = new string[](5);
        newPolygonCoordinates[0] = "-1.2345,6.7890";
        newPolygonCoordinates[1] = "-1.2346,6.7891";
        newPolygonCoordinates[2] = "-1.2347,6.7892";
        newPolygonCoordinates[3] = "-1.2348,6.7893";
        newPolygonCoordinates[4] = "-1.2345,6.7890";

        landToken.updateLandBoundary(tokenId, newPolygonCoordinates);

        details = landToken.getLandDetails(tokenId);
        assertEq(details.geoLocation.polygonCoordinates.length, 5);

        vm.stopPrank();
    }
}
