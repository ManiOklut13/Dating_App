import React, { useState, useEffect, useRef } from 'react';
import { Search, MapPin, Navigation, Target } from 'lucide-react';
import { planDateTheme } from '../theme';
import * as maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';

interface Spot {
  id: string;
  name: string;
  kind: string;
  distance: string;
  lat: number;
  lng: number;
}

interface MeetupSpotCardProps {
  onSpotSelect: (spot: Spot) => void;
  selectedSpot: Spot | null;
}

const SUGGESTED_SPOTS: Spot[] = [
  { id: '1', name: 'Blue Bottle Cafe', kind: 'Cafe', distance: '0.8 mi', lat: 40.7128, lng: -74.0060 },
  { id: '2', name: 'Central Park', kind: 'Park', distance: '1.2 mi', lat: 40.7851, lng: -73.9683 },
  { id: '3', name: 'Sushi Palace', kind: 'Restaurant', distance: '0.5 mi', lat: 40.7589, lng: -73.9851 },
];

export const MeetupSpotCard: React.FC<MeetupSpotCardProps> = ({ onSpotSelect, selectedSpot }) => {
  const [searchQuery, setSearchQuery] = useState('');
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<maplibregl.Map | null>(null);

  useEffect(() => {
    if (map.current || !mapContainer.current) return;

    map.current = new maplibregl.Map({
      container: mapContainer.current,
      style: {
        version: 8,
        sources: {
          osm: {
            type: 'raster',
            tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
            tileSize: 256,
            attribution: '© OpenStreetMap contributors'
          }
        },
        layers: [
          {
            id: 'osm',
            type: 'raster',
            source: 'osm',
            paint: {
              'raster-saturation': -0.3,
              'raster-brightness-min': 0.2,
              'raster-brightness-max': 0.8,
            }
          }
        ]
      },
      center: [-74.0060, 40.7128],
      zoom: 12
    });

    map.current.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-right');

    // Add markers
    new maplibregl.Marker({ color: '#8B5CF6' })
      .setLngLat([-74.01, 40.71])
      .addTo(map.current);

    new maplibregl.Marker({ color: '#FF5C9A' })
      .setLngLat([-74.002, 40.715])
      .addTo(map.current);

    if (selectedSpot) {
      new maplibregl.Marker({ color: '#FF5C9A' })
        .setLngLat([selectedSpot.lng, selectedSpot.lat])
        .addTo(map.current);
    }
  }, [selectedSpot]);

  const handleRecenter = () => {
    if (map.current) {
      map.current.flyTo({ center: [-74.0060, 40.7128], zoom: 12 });
    }
  };

  const handleOpenMaps = () => {
    if (selectedSpot) {
      window.open(`https://www.google.com/maps/search/?api=1&query=${selectedSpot.lat},${selectedSpot.lng}`, '_blank');
    }
  };

  return (
    <div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '10px',
        }}
      >
        <h3
          style={{
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          Meetup Spot
        </h3>
        <span
          style={{
            fontSize: '12px',
            fontWeight: planDateTheme.typography.weights.semibold,
            color: planDateTheme.colors.muted,
            fontFamily: planDateTheme.typography.fontFamily,
            cursor: 'pointer',
          }}
        >
          View on map
        </span>
      </div>

      <div
        style={{
          position: 'relative',
          display: 'flex',
          alignItems: 'center',
          marginBottom: '10px',
        }}
      >
        <MapPin
          size={18}
          color={planDateTheme.colors.placeholder}
          style={{
            position: 'absolute',
            left: '12px',
            pointerEvents: 'none',
          }}
        />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search a cafe, restaurant or park..."
          style={{
            width: '100%',
            height: '46px',
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            backgroundColor: planDateTheme.colors.innerField,
            border: `1px solid ${planDateTheme.colors.innerFieldBorder}`,
            color: planDateTheme.colors.text,
            fontSize: '14px',
            fontFamily: planDateTheme.typography.fontFamily,
            paddingLeft: '40px',
            paddingRight: '12px',
            outline: 'none',
            boxSizing: 'border-box',
          }}
        />
      </div>

      <div
        style={{
          position: 'relative',
          height: '200px',
          borderRadius: `${planDateTheme.borderRadius.large}px`,
          border: `1px solid ${planDateTheme.colors.cardBorder}`,
          overflow: 'hidden',
          marginBottom: '10px',
        }}
      >
        <div ref={mapContainer} style={{ width: '100%', height: '100%' }} />
        <button
          onClick={handleRecenter}
          aria-label="Recenter map"
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            backgroundColor: 'rgba(21,16,28,.92)',
            border: 'none',
            color: planDateTheme.colors.accentText,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            padding: 0,
            zIndex: 1,
          }}
        >
          <Target size={18} />
        </button>
        <div
          style={{
            position: 'absolute',
            bottom: '6px',
            right: '6px',
            backgroundColor: 'rgba(10,6,16,.88)',
            color: '#E6DDF0',
            fontSize: '10px',
            padding: '2px 6px',
            borderRadius: '4px',
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
        </div>
      </div>

      {selectedSpot && (
        <div
          style={{
            backgroundColor: planDateTheme.colors.innerField,
            border: `1px solid ${planDateTheme.colors.highlightCardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.large}px`,
            padding: '10px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            marginBottom: '10px',
          }}
        >
          <div
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: planDateTheme.gradients.primary,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              flexShrink: 0,
            }}
          >
            <MapPin size={20} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div
              style={{
                fontSize: '15px',
                fontWeight: planDateTheme.typography.weights.extrabold,
                color: planDateTheme.colors.text,
                fontFamily: planDateTheme.typography.fontFamily,
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap',
              }}
            >
              {selectedSpot.name}
            </div>
            <div
              style={{
                fontSize: '12px',
                fontWeight: planDateTheme.typography.weights.semibold,
                color: planDateTheme.colors.muted,
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {selectedSpot.kind} • {selectedSpot.distance}
            </div>
          </div>
          <button
            onClick={handleOpenMaps}
            aria-label="Get directions"
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              backgroundColor: 'transparent',
              border: 'none',
              color: planDateTheme.colors.accentText,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              padding: 0,
            }}
          >
            <Navigation size={18} />
          </button>
        </div>
      )}

      <div style={{ display: 'flex', gap: '8px' }}>
        {SUGGESTED_SPOTS.map((spot) => (
          <button
            key={spot.id}
            onClick={() => onSpotSelect(spot)}
            style={{
              flex: 1,
              height: `${planDateTheme.sizes.chipHeight}px`,
              borderRadius: `${planDateTheme.borderRadius.small}px`,
              backgroundColor: selectedSpot?.id === spot.id ? planDateTheme.colors.raisedButton : planDateTheme.colors.idleChip,
              border: `1px solid ${selectedSpot?.id === spot.id ? planDateTheme.colors.raisedButtonBorder : planDateTheme.colors.idleChipBorder}`,
              color: planDateTheme.colors.softText,
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.semibold,
              fontFamily: planDateTheme.typography.fontFamily,
              cursor: 'pointer',
              transition: 'all 0.2s ease',
              padding: '0 8px',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
            }}
          >
            {spot.name}
          </button>
        ))}
      </div>
    </div>
  );
};
