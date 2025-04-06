import React, { useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  CardMedia,
  CardActions,
  Button,
  TextField,
  InputAdornment,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import { useNavigate } from 'react-router-dom';

interface Property {
  id: number;
  title: string;
  description: string;
  price: number;
  location: string;
  image: string;
}

const Marketplace: React.FC = () => {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState('all');

  // Mock data - replace with actual data from your smart contract
  const properties: Property[] = [
    {
      id: 1,
      title: 'Luxury Villa',
      description: 'Beautiful villa with ocean view',
      price: 1000000,
      location: 'Malibu, CA',
      image: 'https://source.unsplash.com/random/800x600/?house',
    },
    {
      id: 2,
      title: 'Mountain Cabin',
      description: 'Cozy cabin in the woods',
      price: 500000,
      location: 'Aspen, CO',
      image: 'https://source.unsplash.com/random/800x600/?cabin',
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
          Property Marketplace
        </Typography>

        <Box sx={{ display: 'flex', gap: 2, mb: 4 }}>
          <TextField
            fullWidth
            variant="outlined"
            placeholder="Search properties..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
          />
          <FormControl sx={{ minWidth: 200 }}>
            <InputLabel>Filter</InputLabel>
            <Select
              value={filter}
              label="Filter"
              onChange={(e) => setFilter(e.target.value)}
            >
              <MenuItem value="all">All Properties</MenuItem>
              <MenuItem value="forSale">For Sale</MenuItem>
              <MenuItem value="auction">Auction</MenuItem>
            </Select>
          </FormControl>
        </Box>

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
                  Buy Now
                </Button>
              </CardActions>
            </Card>
          ))}
        </Box>
      </Box>
    </Container>
  );
};

export default Marketplace; 