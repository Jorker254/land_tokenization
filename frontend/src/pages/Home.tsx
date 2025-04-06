import React from 'react';
import { Container, Typography, Box, Grid, Card, CardContent, Button } from '@mui/material';
import { useNavigate } from 'react-router-dom';

const Home: React.FC = () => {
  const navigate = useNavigate();

  const features = [
    {
      title: 'Tokenized Land',
      description: 'Convert physical land into digital tokens for easy trading and ownership transfer.',
    },
    {
      title: 'Secure Transactions',
      description: 'All transactions are recorded on the blockchain, ensuring transparency and security.',
    },
    {
      title: 'Global Marketplace',
      description: 'Buy and sell land tokens from anywhere in the world.',
    },
  ];

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Typography variant="h2" component="h1" gutterBottom align="center">
          Welcome to Land Tokenization
        </Typography>
        <Typography variant="h5" component="h2" gutterBottom align="center" color="text.secondary">
          Transforming Real Estate with Blockchain Technology
        </Typography>
        
        <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, my: 4 }}>
          <Button
            variant="contained"
            size="large"
            onClick={() => navigate('/marketplace')}
          >
            Explore Marketplace
          </Button>
          <Button
            variant="outlined"
            size="large"
            onClick={() => navigate('/my-properties')}
          >
            My Properties
          </Button>
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(3, 1fr)' }, gap: 3, mt: 6 }}>
          {features.map((feature, index) => (
            <Card key={index} sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h5" component="h3" gutterBottom>
                  {feature.title}
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  {feature.description}
                </Typography>
              </CardContent>
            </Card>
          ))}
        </Box>
      </Box>
    </Container>
  );
};

export default Home; 