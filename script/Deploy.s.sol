// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/LandToken.sol";
import "../src/LandMarketplace.sol";

contract Deploy is Script {
    function run() external {
        // Use the first Anvil account
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy LandToken
        LandToken landToken = new LandToken();
        console.log("LandToken deployed at:", address(landToken));

        // Deploy Marketplace
        LandMarketplace marketplace = new LandMarketplace(address(landToken));
        console.log("LandMarketplace deployed at:", address(marketplace));

        // Mint initial test token to deployer
        string[] memory polygonCoordinates = new string[](4);
        polygonCoordinates[0] = "-1.2345,6.7890";
        polygonCoordinates[1] = "-1.2346,6.7891";
        polygonCoordinates[2] = "-1.2347,6.7892";
        polygonCoordinates[3] = "-1.2345,6.7890";

        landToken.mintLandToken(
            deployer, // Mint to deployer
            "DEED001",
            "123 Test Street",
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

        vm.stopBroadcast();
    }
}
