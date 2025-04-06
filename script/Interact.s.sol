// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/LandToken.sol";
import "../src/LandMarketplace.sol";

contract Interact is Script {
    LandToken landToken;
    LandMarketplace marketplace;

    function setUp() public {
        landToken = LandToken(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        marketplace = LandMarketplace(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
    }

    function run() public {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(privateKey);

        // Create test data
        string[] memory polygonCoordinates = new string[](4);
        polygonCoordinates[0] = "-1.2345,6.7890";
        polygonCoordinates[1] = "-1.2346,6.7891";
        polygonCoordinates[2] = "-1.2347,6.7892";
        polygonCoordinates[3] = "-1.2345,6.7890";

        // Mint a new token
        uint256 tokenId = landToken.mintLandToken(
            msg.sender,
            "DEED002",
            "456 Test Ave",
            2000,
            "-1.2345",
            "6.7890",
            polygonCoordinates,
            "Commercial",
            "Jane Doe",
            "ID789012",
            "TAX002",
            "MUN001"
        );

        console.log("Minted token ID:", tokenId);

        // List it for sale
        landToken.approve(address(marketplace), tokenId);
        marketplace.listLand(tokenId, 1 ether);
        console.log("Listed token for sale for 1 ETH");

        vm.stopBroadcast();
    }
}
