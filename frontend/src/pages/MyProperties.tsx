import React from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  CardMedia,
  CardActions,
  Button,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';

interface Property {
  id: number;
  title: string;
  description: string;
  price: number;
  location: string;
  image: string;
}

const MyProperties: React.FC = () => {
  const navigate = useNavigate();

  // Mock data - replace with actual data from your smart contract
  const properties: Property[] = [
    {
      id: 1,
      title: 'My Beach House',
      description: 'Beautiful beachfront property',
      price: 1500000,
      location: 'Miami, FL',
      image: 'https://source.unsplash.com/random/800x600/?beach-house',
    },
    // Add more properties as needed
  ];

  const handlePropertyClick = (id: number) => {
    navigate(`/property/${id}`);
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          My Properties
        </Typography>

        {properties.length === 0 ? (
          <Typography variant="body1" color="text.secondary">
            You don't own any properties yet. Visit the marketplace to purchase one.
          </Typography>
        ) : (
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(3, 1fr)' }, gap: 3 }}>
            {properties.map((property) => (
              <Card key={property.id} sx={{ maxWidth: 345 }}>
                <CardMedia
                  component="img"
                  height="140"
                  image={property.image}
                  alt={property.title}
                />
                <CardContent>
                  <Typography gutterBottom variant="h5" component="div">
                    {property.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {property.description}
                  </Typography>
                  <Typography variant="h6" color="primary" sx={{ mt: 2 }}>
                    ${property.price.toLocaleString()}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {property.location}
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => handlePropertyClick(property.id)}>
                    View Details
                  </Button>
                  <Button size="small" color="primary">
                    List for Sale
                  </Button>
                </CardActions>
              </Card>
            ))}
          </Box>
        )}
      </Box>
    </Container>
  );
};

export default MyProperties; 