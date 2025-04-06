# Land Tokenization Platform

A decentralized platform for tokenizing and trading land properties using blockchain technology.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) (for Docker method)
- [Node.js](https://nodejs.org/) (v16 or later) (for manual method)
- [MetaMask](https://metamask.io/) browser extension
- A modern web browser (Chrome, Firefox, or Edge recommended)

## Quick Start Guide

### Option 1: Using Docker (Recommended)

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/land_tokenization.git
   cd land_tokenization
   ```

2. **Start the Application**
   ```bash
   docker-compose up
   ```

3. **Access the Application**
   - Open your browser and go to: `http://localhost:3000`
   - The Anvil Ethereum testnet will be available at: `http://localhost:8545`

4. **Connect MetaMask**
   - Open MetaMask
   - Click on the network dropdown and select "Add Network"
   - Add the following network details:
     - Network Name: Anvil
     - RPC URL: http://localhost:8545
     - Chain ID: 31337
     - Currency Symbol: ETH
   - Click "Save"

### Option 2: Manual Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/land_tokenization.git
   cd land_tokenization
   ```

2. **Install Foundry (for Anvil)**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   source ~/.bashrc
   foundryup
   ```

3. **Start Anvil**
   ```bash
   anvil
   ```
   Keep this terminal window open.

4. **Setup Frontend**
   Open a new terminal window and run:
   ```bash
   cd frontend
   npm install
   npm start
   ```

5. **Access the Application**
   - Open your browser and go to: `http://localhost:3000`
   - Connect MetaMask as described in the Docker setup

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   - If you see "Something is already running on port 3000":
     - Press 'Y' to run on a different port
     - Or find and stop the process using the port:
       ```bash
       lsof -i :3000
       kill -9 <PID>
       ```

2. **Anvil Not Found**
   - If you see "anvil: command not found":
     - Make sure Foundry is installed correctly
     - Try running `foundryup` again
     - Check if `~/.foundry/bin` is in your PATH

3. **MetaMask Connection Issues**
   - Ensure MetaMask is unlocked
   - Check if you're on the correct network
   - Try refreshing the page
   - Clear browser cache if needed

## Development

### Project Structure
- `src/` - Smart contracts
- `frontend/` - React application
- `test/` - Smart contract tests

### Running Tests
```bash
# Smart contract tests
forge test

# Frontend tests
cd frontend
npm test
```

## License
MIT
