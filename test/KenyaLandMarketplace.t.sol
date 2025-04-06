// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LandToken.sol";
import "../src/KenyaLandMarketplace.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract KenyaLandMarketplaceTest is Test {
    LandToken public landToken;
    KenyaLandMarketplace public marketplace;
    MockERC20 public paymentToken;

    address public admin = address(1);
    address public registrar = address(2);
    address public seller = address(3);
    address public buyer = address(4);
    address public lessee = address(5);

    function setUp() public {
        vm.startPrank(admin);
        landToken = new LandToken();
        paymentToken = new MockERC20();
        marketplace = new KenyaLandMarketplace(
            address(landToken),
            address(paymentToken)
        );
        marketplace.grantRole(marketplace.LAND_REGISTRAR_ROLE(), registrar);

        // Distribute tokens to test accounts
        uint256 amount = 10000 * 10 ** paymentToken.decimals();
        paymentToken.transfer(seller, amount);
        paymentToken.transfer(buyer, amount);
        paymentToken.transfer(lessee, amount);
        vm.stopPrank();
    }

    function testCreateAuction() public returns (uint256) {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            seller,
            "T123",
            "Nairobi",
            1000,
            "1.2921",
            "36.8219",
            new string[](0),
            "Residential",
            "John Doe",
            "ID123",
            "TAX123",
            "M001"
        );
        vm.stopPrank();

        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        marketplace.createAuction(tokenId, 100, 7 days, true);

        KenyaLandMarketplace.Auction memory auction = marketplace.getAuction(
            tokenId
        );
        assertEq(auction.seller, seller);
        assertEq(auction.startingPrice, 100);
        assertEq(auction.isActive, true);
        assertEq(auction.requiresRegistrarApproval, true);
        assertEq(auction.isApproved, false);

        return tokenId;
    }

    function testPlaceBid() public {
        uint256 tokenId = testCreateAuction();

        vm.startPrank(registrar);
        marketplace.approveAuction(tokenId);
        vm.stopPrank();

        vm.startPrank(buyer);
        paymentToken.approve(address(marketplace), 150);
        marketplace.placeBid(tokenId, 150);

        KenyaLandMarketplace.Auction memory auction = marketplace.getAuction(
            tokenId
        );
        assertEq(auction.currentBid, 150);
        assertEq(auction.currentBidder, buyer);
    }

    function testCreateEscrow() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            seller,
            "T123",
            "Nairobi",
            1000,
            "1.2921",
            "36.8219",
            new string[](0),
            "Residential",
            "John Doe",
            "ID123",
            "TAX123",
            "M001"
        );
        vm.stopPrank();

        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        vm.stopPrank();

        vm.startPrank(buyer);
        paymentToken.approve(address(marketplace), 1000);
        vm.stopPrank();

        vm.startPrank(seller);
        marketplace.createEscrow(tokenId, buyer, 1000, true);

        KenyaLandMarketplace.Escrow memory escrow = marketplace.getEscrow(
            tokenId
        );
        assertEq(escrow.seller, seller);
        assertEq(escrow.buyer, buyer);
        assertEq(escrow.amount, 1000);
        assertEq(escrow.isActive, true);
        assertEq(escrow.requiresRegistrarApproval, true);
        assertEq(escrow.isApproved, false);
    }

    function testFractionalizeLand() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            seller,
            "T123",
            "Nairobi",
            1000,
            "1.2921",
            "36.8219",
            new string[](0),
            "Residential",
            "John Doe",
            "ID123",
            "TAX123",
            "M001"
        );
        vm.stopPrank();

        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        marketplace.fractionalizeLand(tokenId, 1000, 1, true);

        assertEq(marketplace.isFractionalized(tokenId), true);
        (
            uint256 totalShares,
            uint256 availableShares,
            uint256 pricePerShare,
            bool requiresRegistrarApproval,
            bool isApproved
        ) = marketplace.getFractionalShareInfo(tokenId);

        assertEq(totalShares, 1000);
        assertEq(availableShares, 1000);
        assertEq(pricePerShare, 1);
        assertEq(requiresRegistrarApproval, true);
        assertEq(isApproved, false);
    }

    function testCreateLease() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            seller,
            "T123",
            "Nairobi",
            1000,
            "1.2921",
            "36.8219",
            new string[](0),
            "Residential",
            "John Doe",
            "ID123",
            "TAX123",
            "M001"
        );
        vm.stopPrank();

        vm.startPrank(seller);
        landToken.approve(address(marketplace), tokenId);
        vm.stopPrank();

        vm.startPrank(lessee);
        paymentToken.approve(address(marketplace), 200);
        vm.stopPrank();

        vm.startPrank(seller);
        marketplace.createLease(tokenId, lessee, 365 days, 100, 200, true);

        KenyaLandMarketplace.LeaseAgreement memory lease = marketplace
            .getLeaseAgreement(tokenId);
        assertEq(lease.lessor, seller);
        assertEq(lease.lessee, lessee);
        assertEq(lease.monthlyRent, 100);
        assertEq(lease.securityDeposit, 200);
        assertEq(lease.isActive, true);
        assertEq(lease.requiresRegistrarApproval, true);
        assertEq(lease.isApproved, false);
    }

    function test_RevertWhen_NotRegistrarApproves() public {
        testCreateAuction();

        vm.startPrank(buyer);
        vm.expectRevert();
        marketplace.approveAuction(1);
    }

    function test_RevertWhen_NotOwnerCreatesAuction() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            seller,
            "T123",
            "Nairobi",
            1000,
            "1.2921",
            "36.8219",
            new string[](0),
            "Residential",
            "John Doe",
            "ID123",
            "TAX123",
            "M001"
        );
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectRevert();
        marketplace.createAuction(tokenId, 100, 7 days, true);
    }
}
