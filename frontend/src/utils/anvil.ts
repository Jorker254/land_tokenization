import { ethers } from 'ethers';

// Declare the ethereum provider type
declare global {
  interface Window {
    ethereum?: {
      request: (args: { method: string; params?: any[] }) => Promise<any>;
      isMetaMask?: boolean;
    };
  }
}

// Anvil's default private key for the first account
export const ANVIL_DEFAULT_PRIVATE_KEY = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

// Anvil's default RPC URL
export const ANVIL_RPC_URL = 'http://localhost:8545';

// Create a provider connected to Anvil
export const getAnvilProvider = () => {
  return new ethers.providers.JsonRpcProvider(ANVIL_RPC_URL);
};

// Create a signer using Anvil's default private key
export const getAnvilSigner = () => {
  const provider = getAnvilProvider();
  return new ethers.Wallet(ANVIL_DEFAULT_PRIVATE_KEY, provider);
};

// Helper to switch to Anvil network in MetaMask
export const switchToAnvilNetwork = async () => {
  if (window.ethereum) {
    try {
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [{
          chainId: '0x7a69', // 31337 in hex
          chainName: 'Anvil Local',
          nativeCurrency: {
            name: 'Ether',
            symbol: 'ETH',
            decimals: 18
          },
          rpcUrls: [ANVIL_RPC_URL],
          blockExplorerUrls: []
        }]
      });
    } catch (error) {
      console.error('Error switching to Anvil network:', error);
    }
  }
}; 