# Kenya Land Tokenization Platform

A blockchain-based platform for land tokenization in Kenya, enabling secure, transparent, and efficient land transactions.

## Overview

This project implements a comprehensive land tokenization system for Kenya, featuring:

- Land tokenization as ERC721 NFTs
- Enhanced land information storage
- Marketplace for land transactions
- Support for auctions, escrow, and fractional ownership
- Compliance with Kenyan land laws

## Smart Contracts

### Core Contracts

1. **LandToken.sol**
   - ERC721-based land token
   - Stores land metadata and ownership information
   - Implements Kenyan land registration requirements

2. **EnhancedLandInfo.sol**
   - Stores detailed land information
   - 3D coordinates and elevation data
   - Zoning and environmental information
   - Access control for authorized updates

3. **KenyaLandMarketplace.sol**
   - Land trading platform
   - Auction system
   - Escrow service
   - Fractional ownership
   - Lease management

## Features

### Land Tokenization
- Unique land parcels as NFTs
- Detailed metadata storage
- Ownership tracking
- Transfer restrictions

### Enhanced Land Information
- 3D coordinates and elevation
- Zoning information
- Environmental data
- Historical records

### Marketplace Features
- **Auctions**
  - Duration: 1-30 days
  - Automatic bid refunds
  - Registrar approval
  - Early termination option

- **Escrow**
  - 7-day escrow period
  - Buyer and seller protection
  - Registrar approval
  - Automatic refunds

- **Fractional Ownership**
  - Customizable shares
  - Share price setting
  - Share tracking
  - Registrar approval

- **Leasing**
  - Duration: 30 days to 99 years
  - Monthly rent tracking
  - Security deposits
  - Registrar approval

## Security Features

- Access control for admin and registrar roles
- Reentrancy protection
- Secure token transfers
- Input validation
- Compliance with Kenyan land laws

## Getting Started

### Prerequisites

- Node.js (v16 or later)
- Foundry
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/kenya-land-tokenization.git
cd kenya-land-tokenization
```

2. Install dependencies:
```bash
forge install
```

3. Compile contracts:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## Testing

The project includes comprehensive test coverage:

```bash
forge test --match-path test/LandToken.t.sol -vv
forge test --match-path test/EnhancedLandInfo.t.sol -vv
forge test --match-path test/KenyaLandMarketplace.t.sol -vv
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Contact

For questions or support, please contact [your-email@example.com]
