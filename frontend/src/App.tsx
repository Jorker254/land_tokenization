import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { Web3ReactProvider } from '@web3-react/core';
import { ethers } from 'ethers';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import Marketplace from './pages/Marketplace';
import MyProperties from './pages/MyProperties';
import PropertyDetails from './pages/PropertyDetails';
import { Box } from '@mui/material';

// Create theme
const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#00ff00',
    },
    secondary: {
      main: '#ffffff',
    },
    background: {
      default: '#000000',
      paper: '#121212',
    },
  },
});

// Web3 provider setup
function getLibrary(provider: any) {
  return new ethers.providers.Web3Provider(provider);
}

function App() {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <ThemeProvider theme={theme}>
        <Router>
          <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
            <Navbar />
            <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/marketplace" element={<Marketplace />} />
                <Route path="/my-properties" element={<MyProperties />} />
                <Route path="/property/:id" element={<PropertyDetails />} />
              </Routes>
            </Box>
          </Box>
        </Router>
      </ThemeProvider>
    </Web3ReactProvider>
  );
}

export default App;
