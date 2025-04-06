// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./LandToken.sol";

contract EnhancedLandInfo is AccessControl {
    bytes32 public constant INFO_MANAGER_ROLE = keccak256("INFO_MANAGER_ROLE");

    struct ZoningInfo {
        string zoneType;
        string[] permittedUses;
        uint256 maxBuildingHeight;
        uint256 floorAreaRatio;
        string[] restrictions;
    }

    struct EnvironmentalData {
        string soilType;
        string floodRiskLevel;
        string[] environmentalHazards;
        string[] protectedSpecies;
        string waterSource;
    }

    struct ThreeDCoordinates {
        string latitude;
        string longitude;
        string altitude;
        string[] polygonCoordinates;
        string[] elevationPoints;
    }

    LandToken public landToken;

    mapping(uint256 => ZoningInfo) private _zoningInfo;
    mapping(uint256 => EnvironmentalData) private _environmentalData;
    mapping(uint256 => ThreeDCoordinates) private _threeDCoordinates;

    event ZoningInfoUpdated(uint256 indexed tokenId, string zoneType);
    event EnvironmentalDataUpdated(uint256 indexed tokenId, string soilType);
    event ThreeDCoordinatesUpdated(uint256 indexed tokenId);

    constructor(address _landToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(INFO_MANAGER_ROLE, msg.sender);
        landToken = LandToken(_landToken);
    }

    function updateZoningInfo(
        uint256 tokenId,
        string memory zoneType,
        string[] memory permittedUses,
        uint256 maxBuildingHeight,
        uint256 floorAreaRatio,
        string[] memory restrictions
    ) public onlyRole(INFO_MANAGER_ROLE) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );

        _zoningInfo[tokenId] = ZoningInfo({
            zoneType: zoneType,
            permittedUses: permittedUses,
            maxBuildingHeight: maxBuildingHeight,
            floorAreaRatio: floorAreaRatio,
            restrictions: restrictions
        });
        emit ZoningInfoUpdated(tokenId, zoneType);
    }

    function updateEnvironmentalData(
        uint256 tokenId,
        string memory soilType,
        string memory floodRiskLevel,
        string[] memory environmentalHazards,
        string[] memory protectedSpecies,
        string memory waterSource
    ) public onlyRole(INFO_MANAGER_ROLE) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );

        _environmentalData[tokenId] = EnvironmentalData({
            soilType: soilType,
            floodRiskLevel: floodRiskLevel,
            environmentalHazards: environmentalHazards,
            protectedSpecies: protectedSpecies,
            waterSource: waterSource
        });
        emit EnvironmentalDataUpdated(tokenId, soilType);
    }

    function updateThreeDCoordinates(
        uint256 tokenId,
        string memory latitude,
        string memory longitude,
        string memory altitude,
        string[] memory polygonCoordinates,
        string[] memory elevationPoints
    ) public onlyRole(INFO_MANAGER_ROLE) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );

        _threeDCoordinates[tokenId] = ThreeDCoordinates({
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            polygonCoordinates: polygonCoordinates,
            elevationPoints: elevationPoints
        });
        emit ThreeDCoordinatesUpdated(tokenId);
    }

    function getZoningInfo(
        uint256 tokenId
    ) public view returns (ZoningInfo memory) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );
        return _zoningInfo[tokenId];
    }

    function getEnvironmentalData(
        uint256 tokenId
    ) public view returns (EnvironmentalData memory) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );
        return _environmentalData[tokenId];
    }

    function getThreeDCoordinates(
        uint256 tokenId
    ) public view returns (ThreeDCoordinates memory) {
        require(
            landToken.ownerOf(tokenId) != address(0),
            "Token does not exist"
        );
        return _threeDCoordinates[tokenId];
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
