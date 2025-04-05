// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract LandToken is ERC721, Pausable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    uint256 private _nextTokenId;

    struct GeoLocation {
        string latitude;
        string longitude;
        string[] polygonCoordinates;
    }

    struct LandDetails {
        // Title Identification
        string titleDeedNumber;
        uint256 registrationDate;
        
        // Property Information
        string location;
        uint256 area;
        GeoLocation geoLocation;
        string landUseType;
        
        // Ownership Information
        string ownerName;
        string ownerIdentification;
        address[] previousOwners;
        uint256[] transferDates;
        
        // Legal Information
        string[] encumbrances;
        string propertyTaxId;
        
        // Administrative
        bool isVerified;
        string municipalityCode;
    }

    mapping(uint256 => LandDetails) private _landDetails;
    mapping(string => uint256[]) private _locationToTokenIds;
    mapping(string => bool) private _titleDeedExists;
    uint256[] public allTokenIds;

    event LandTokenMinted(
        uint256 indexed tokenId,
        string titleDeedNumber,
        address indexed owner,
        string latitude,
        string longitude
    );

    event LandBoundaryUpdated(
        uint256 indexed tokenId,
        string[] polygonCoordinates
    );

    constructor() ERC721("Land Title Token", "LAND") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function _createGeoLocation(
        string memory latitude,
        string memory longitude,
        string[] memory polygonCoordinates
    ) internal pure returns (GeoLocation memory) {
        return GeoLocation({
            latitude: latitude,
            longitude: longitude,
            polygonCoordinates: polygonCoordinates
        });
    }

    function _initializeOwnership() internal view returns (address[] memory, uint256[] memory) {
        address[] memory initialOwners = new address[](1);
        initialOwners[0] = msg.sender;
        
        uint256[] memory initialDates = new uint256[](1);
        initialDates[0] = block.timestamp;

        return (initialOwners, initialDates);
    }

    function mintLandToken(
        address to,
        string calldata titleDeedNumber,
        string calldata location,
        uint256 area,
        string calldata latitude,
        string calldata longitude,
        string[] calldata polygonCoordinates,
        string calldata landUseType,
        string calldata ownerName,
        string calldata ownerIdentification,
        string calldata propertyTaxId,
        string calldata municipalityCode
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        require(!_titleDeedExists[titleDeedNumber], "Title deed already exists");
        
        uint256 tokenId = _nextTokenId++;
        
        GeoLocation memory geoLocation = _createGeoLocation(
            latitude,
            longitude,
            polygonCoordinates
        );

        (address[] memory initialOwners, uint256[] memory initialDates) = _initializeOwnership();

        _landDetails[tokenId] = LandDetails({
            titleDeedNumber: titleDeedNumber,
            registrationDate: block.timestamp,
            location: location,
            area: area,
            geoLocation: geoLocation,
            landUseType: landUseType,
            ownerName: ownerName,
            ownerIdentification: ownerIdentification,
            previousOwners: initialOwners,
            transferDates: initialDates,
            encumbrances: new string[](0),
            propertyTaxId: propertyTaxId,
            isVerified: false,
            municipalityCode: municipalityCode
        });

        _titleDeedExists[titleDeedNumber] = true;
        allTokenIds.push(tokenId);
        _locationToTokenIds[location].push(tokenId);
        
        _safeMint(to, tokenId);
        
        emit LandTokenMinted(tokenId, titleDeedNumber, to, latitude, longitude);
        return tokenId;
    }

    function getLandDetails(uint256 tokenId) 
        public 
        view 
        returns (LandDetails memory) 
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return _landDetails[tokenId];
    }

    function updateLandBoundary(
        uint256 tokenId,
        string[] memory newPolygonCoordinates
    ) public onlyRole(MINTER_ROLE) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        _landDetails[tokenId].geoLocation.polygonCoordinates = newPolygonCoordinates;
        emit LandBoundaryUpdated(tokenId, newPolygonCoordinates);
    }

    function getLandsByLocation(string memory location) 
        public 
        view 
        returns (uint256[] memory) 
    {
        return _locationToTokenIds[location];
    }

    function getAllLandTokens() public view returns (uint256[] memory) {
        return allTokenIds;
    }

    function verifyLand(uint256 tokenId, bool verified) 
        public 
        onlyRole(MINTER_ROLE) 
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        _landDetails[tokenId].isVerified = verified;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        address previousOwner = super._update(to, tokenId, auth);

        if (from != address(0)) {
            _landDetails[tokenId].previousOwners.push(to);
            _landDetails[tokenId].transferDates.push(block.timestamp);
        }

        return previousOwner;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}