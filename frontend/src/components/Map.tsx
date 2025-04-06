import React, { useEffect, useRef, useState } from 'react';
import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { Box } from '@mui/material';

interface MapProps {
  center?: [number, number];
  zoom?: number;
  markers?: Array<{
    id: string;
    coordinates: [number, number];
    title?: string;
    color?: string;
  }>;
  onMarkerClick?: (markerId: string) => void;
  onMapLoad?: (map: maplibregl.Map) => void;
}

const Map: React.FC<MapProps> = ({ 
  center = [36.8219, 1.2921], // Default to Nairobi
  zoom = 12,
  markers = [],
  onMarkerClick,
  onMapLoad 
}) => {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<maplibregl.Map | null>(null);
  const [markerElements, setMarkerElements] = useState<maplibregl.Marker[]>([]);

  useEffect(() => {
    if (map.current) return; // Initialize map only once

    map.current = new maplibregl.Map({
      container: mapContainer.current!,
      style: {
        version: 8,
        sources: {
          'raster-tiles': {
            type: 'raster',
            tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
            tileSize: 256,
            attribution: '© OpenStreetMap contributors'
          }
        },
        layers: [{
          id: 'simple-tiles',
          type: 'raster',
          source: 'raster-tiles',
          minzoom: 0,
          maxzoom: 22
        }]
      },
      center: center,
      zoom: zoom
    });

    // Add navigation controls
    map.current.addControl(new maplibregl.NavigationControl(), 'top-right');

    // Add dark mode styling
    const style = document.createElement('style');
    style.textContent = `
      .maplibregl-map {
        background-color: #0A0A0A;
      }
      .maplibregl-ctrl-group {
        background-color: #1E1E1E !important;
        border: 1px solid #2D2D2D !important;
      }
      .maplibregl-ctrl button {
        background-color: #1E1E1E !important;
        color: #FFFFFF !important;
      }
      .maplibregl-ctrl button:hover {
        background-color: #2D2D2D !important;
      }
      .maplibregl-marker {
        cursor: pointer;
      }
      .maplibregl-popup {
        background-color: #1E1E1E;
        color: #FFFFFF;
        border: 1px solid #2D2D2D;
        border-radius: 4px;
      }
      .maplibregl-popup-content {
        padding: 12px;
      }
      .maplibregl-popup-close-button {
        color: #FFFFFF;
      }
    `;
    document.head.appendChild(style);

    if (onMapLoad) {
      map.current.on('load', () => onMapLoad(map.current!));
    }

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
      document.head.removeChild(style);
    };
  }, [center, zoom, onMapLoad]);

  // Update markers when they change
  useEffect(() => {
    if (!map.current) return;

    // Remove existing markers
    markerElements.forEach(marker => marker.remove());
    setMarkerElements([]);

    // Add new markers
    const newMarkers = markers.map(marker => {
      const el = document.createElement('div');
      el.className = 'marker';
      el.style.width = '24px';
      el.style.height = '24px';
      el.style.backgroundImage = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='${marker.color || '#00FF00'}'%3E%3Cpath d='M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z'/%3E%3C/svg%3E")`;
      el.style.backgroundSize = 'cover';
      el.style.cursor = 'pointer';

      const maplibreMarker = new maplibregl.Marker({
        element: el,
        anchor: 'bottom'
      })
        .setLngLat(marker.coordinates)
        .addTo(map.current!);

      if (marker.title) {
        const popup = new maplibregl.Popup({ offset: 25 })
          .setHTML(`<h3>${marker.title}</h3>`);

        maplibreMarker.setPopup(popup);
      }

      if (onMarkerClick) {
        el.addEventListener('click', () => onMarkerClick(marker.id));
      }

      return maplibreMarker;
    });

    setMarkerElements(newMarkers);
  }, [markers, onMarkerClick]);

  return (
    <Box
      ref={mapContainer}
      sx={{
        width: '100%',
        height: '100%',
        minHeight: '400px',
        borderRadius: '8px',
        overflow: 'hidden',
        border: '1px solid #2D2D2D'
      }}
    />
  );
};

export default Map; 