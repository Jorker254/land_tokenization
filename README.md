# Land Tokenization Project

A decentralized platform for tokenizing land ownership using NFTs (ERC721) on the Ethereum blockchain. This project enables the digitization of land records, transparent ownership transfers, and a marketplace for land trading.

## Features

- **Land Tokenization**: Convert physical land parcels into NFTs
- **Geographic Data**: Store land coordinates and boundaries
- **Ownership History**: Track land ownership transfers
- **Marketplace**: Buy and sell land tokens
- **Verification System**: Authorized verification of land parcels
- **Location-based Search**: Query lands by location

## Smart Contracts

### 1. LandToken.sol
The core contract that handles land tokenization and management.

**Key Features:**
- ERC721 NFT implementation
- Detailed land information storage
- Ownership history tracking
- Geographic data management
- Role-based access control

**Land Details Include:**
- Title deed information
- Geographic coordinates
- Land boundaries
- Ownership history
- Property details
- Legal information
- Verification status

### 2. LandMarketplace.sol
A marketplace contract for trading land tokens.

**Key Features:**
- List land tokens for sale
- Purchase land tokens
- Price management
- Transaction security

## Technical Stack

- **Framework**: Foundry
- **Solidity Version**: 0.8.20
- **Dependencies**:
  - OpenZeppelin Contracts
  - Foundry Standard Library

## Project Structure

```
├── src/                    # Source contracts
│   ├── LandToken.sol      # Main land tokenization contract
│   └── LandMarketplace.sol # Marketplace contract
├── test/                   # Test files
├── script/                 # Deployment scripts
├── lib/                    # Dependencies
└── foundry.toml           # Foundry configuration
```

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for additional tooling)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Jorker254/land_tokenization.git
cd land_tokenization
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

### Testing

Run the test suite:
```bash
forge test
```

### Deployment

1. Configure your environment variables in `.env`:
```
RPC_URL=your_rpc_url
PRIVATE_KEY=your_private_key
```

2. Deploy the contracts:
```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## Security

- Role-based access control for sensitive operations
- Pausable functionality for emergency stops
- Comprehensive test coverage
- Reentrancy protection

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or suggestions, please open an issue in the repository.
