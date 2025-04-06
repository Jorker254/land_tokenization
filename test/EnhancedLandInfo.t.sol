// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LandToken.sol";
import "../src/EnhancedLandInfo.sol";

contract EnhancedLandInfoTest is Test {
    LandToken public landToken;
    EnhancedLandInfo public enhancedInfo;
    address public admin = address(1);
    address public user = address(2);
    address public infoManager = address(3);

    function setUp() public {
        vm.startPrank(admin);
        landToken = new LandToken();
        enhancedInfo = new EnhancedLandInfo(address(landToken));
        enhancedInfo.grantRole(enhancedInfo.INFO_MANAGER_ROLE(), infoManager);
        vm.stopPrank();
    }

    function testUpdateZoningInfo() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            user,
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

        vm.startPrank(infoManager);
        string[] memory permittedUses = new string[](2);
        permittedUses[0] = "Residential";
        permittedUses[1] = "Commercial";

        string[] memory restrictions = new string[](1);
        restrictions[0] = "No industrial use";

        enhancedInfo.updateZoningInfo(
            tokenId,
            "R2",
            permittedUses,
            10,
            2,
            restrictions
        );

        EnhancedLandInfo.ZoningInfo memory info = enhancedInfo.getZoningInfo(
            tokenId
        );
        assertEq(info.zoneType, "R2");
        assertEq(info.permittedUses.length, 2);
        assertEq(info.maxBuildingHeight, 10);
        assertEq(info.floorAreaRatio, 2);
        assertEq(info.restrictions.length, 1);
    }

    function testUpdateEnvironmentalData() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            user,
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

        vm.startPrank(infoManager);
        string[] memory hazards = new string[](1);
        hazards[0] = "Flood prone";

        string[] memory species = new string[](1);
        species[0] = "Protected tree species";

        enhancedInfo.updateEnvironmentalData(
            tokenId,
            "Clay",
            "Medium",
            hazards,
            species,
            "Municipal water"
        );

        EnhancedLandInfo.EnvironmentalData memory data = enhancedInfo
            .getEnvironmentalData(tokenId);
        assertEq(data.soilType, "Clay");
        assertEq(data.floodRiskLevel, "Medium");
        assertEq(data.environmentalHazards.length, 1);
        assertEq(data.protectedSpecies.length, 1);
        assertEq(data.waterSource, "Municipal water");
    }

    function testUpdateThreeDCoordinates() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            user,
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

        vm.startPrank(infoManager);
        string[] memory polygon = new string[](4);
        polygon[0] = "1.2921,36.8219,1600";
        polygon[1] = "1.2922,36.8220,1600";
        polygon[2] = "1.2923,36.8221,1600";
        polygon[3] = "1.2924,36.8222,1600";

        string[] memory elevation = new string[](2);
        elevation[0] = "1600";
        elevation[1] = "1605";

        enhancedInfo.updateThreeDCoordinates(
            tokenId,
            "1.2921",
            "36.8219",
            "1600",
            polygon,
            elevation
        );

        EnhancedLandInfo.ThreeDCoordinates memory coords = enhancedInfo
            .getThreeDCoordinates(tokenId);
        assertEq(coords.latitude, "1.2921");
        assertEq(coords.longitude, "36.8219");
        assertEq(coords.altitude, "1600");
        assertEq(coords.polygonCoordinates.length, 4);
        assertEq(coords.elevationPoints.length, 2);
    }

    function test_RevertWhen_NotInfoManager() public {
        vm.startPrank(admin);
        uint256 tokenId = landToken.mintLandToken(
            user,
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

        vm.startPrank(user);
        vm.expectRevert();
        enhancedInfo.updateZoningInfo(
            tokenId,
            "R2",
            new string[](0),
            10,
            2,
            new string[](0)
        );
    }
}
