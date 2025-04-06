import React from 'react';
import { useParams } from 'react-router-dom';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  CardMedia,
  Button,
  Grid,
  Paper,
} from '@mui/material';
import Map from '../components/Map';

interface Property {
  id: number;
  title: string;
  description: string;
  price: number;
  location: string;
  image: string;
  details: {
    bedrooms: number;
    bathrooms: number;
    area: number;
    yearBuilt: number;
  };
}

const PropertyDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  
  // Mock data - replace with actual data from your smart contract
  const property: Property = {
    id: Number(id),
    title: 'Luxury Villa',
    description: 'Beautiful villa with ocean view and modern amenities',
    price: 1000000,
    location: 'Malibu, CA',
    image: 'https://source.unsplash.com/random/800x600/?villa',
    details: {
      bedrooms: 4,
      bathrooms: 3,
      area: 2500,
      yearBuilt: 2015,
    },
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          {property.title}
        </Typography>

        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Card>
              <CardMedia
                component="img"
                height="400"
                image={property.image}
                alt={property.title}
              />
              <CardContent>
                <Typography variant="h5" gutterBottom>
                  ${property.price.toLocaleString()}
                </Typography>
                <Typography variant="body1" paragraph>
                  {property.description}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Location: {property.location}
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={4}>
            <Paper sx={{ p: 2, mb: 2 }}>
              <Typography variant="h6" gutterBottom>
                Property Details
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={6}>
                  <Typography variant="body2" color="text.secondary">
                    Bedrooms
                  </Typography>
                  <Typography variant="body1">
                    {property.details.bedrooms}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="body2" color="text.secondary">
                    Bathrooms
                  </Typography>
                  <Typography variant="body1">
                    {property.details.bathrooms}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="body2" color="text.secondary">
                    Area (sq ft)
                  </Typography>
                  <Typography variant="body1">
                    {property.details.area}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="body2" color="text.secondary">
                    Year Built
                  </Typography>
                  <Typography variant="body1">
                    {property.details.yearBuilt}
                  </Typography>
                </Grid>
              </Grid>
            </Paper>

            <Button
              variant="contained"
              color="primary"
              fullWidth
              size="large"
            >
              Buy Now
            </Button>
          </Grid>

          <Grid item xs={12}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom>
                Location
              </Typography>
              <Box sx={{ height: 400 }}>
                <Map />
              </Box>
            </Paper>
          </Grid>
        </Grid>
      </Box>
    </Container>
  );
};

export default PropertyDetails; 