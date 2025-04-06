import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
  useTheme,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useWeb3React } from '@web3-react/core';
import { InjectedConnector } from '@web3-react/injected-connector';
import { switchToAnvilNetwork } from '../utils/anvil';

const injected = new InjectedConnector({
  supportedChainIds: [31337], // Anvil's chain ID
});

const Navbar: React.FC = () => {
  const navigate = useNavigate();
  const theme = useTheme();
  const { active, account, activate, deactivate } = useWeb3React();

  const connect = async () => {
    try {
      await activate(injected);
      await switchToAnvilNetwork();
    } catch (error) {
      console.error('Error connecting to wallet:', error);
    }
  };

  const disconnect = async () => {
    try {
      deactivate();
    } catch (error) {
      console.error('Error disconnecting from wallet:', error);
    }
  };

  return (
    <AppBar position="static" elevation={0}>
      <Toolbar>
        <Typography
          variant="h6"
          component="div"
          sx={{ flexGrow: 1, cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          Land Tokenization
        </Typography>
        <Box sx={{ display: 'flex', gap: 2 }}>
          <Button
            color="inherit"
            href="/"
          >
            Home
          </Button>
          <Button
            color="inherit"
            href="/marketplace"
          >
            Marketplace
          </Button>
          <Button
            color="inherit"
            href="/my-properties"
          >
            My Properties
          </Button>
          {active ? (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography variant="body2">
                {account?.slice(0, 6)}...{account?.slice(-4)}
              </Typography>
              <Button 
                variant="outlined" 
                color="inherit" 
                size="small"
                onClick={disconnect}
              >
                Disconnect
              </Button>
            </Box>
          ) : (
            <Button 
              variant="contained" 
              color="primary"
              onClick={connect}
            >
              Connect Wallet
            </Button>
          )}
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar; 