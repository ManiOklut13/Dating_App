import React from 'react';
import { Search, ChevronRight, Heart } from 'lucide-react';
import { planDateTheme } from '../theme';
import { Partner } from '../types';

interface PartnerCardProps {
  partner: Partner | null;
  searchValue: string;
  onSearchChange: (value: string) => void;
  onPartnerClick?: () => void;
}

export const PartnerCard: React.FC<PartnerCardProps> = ({
  partner,
  searchValue,
  onSearchChange,
  onPartnerClick,
}) => {
  return (
    <div
      style={{
        background: planDateTheme.gradients.highlightCard,
        border: `1px solid ${planDateTheme.colors.highlightCardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
        display: 'flex',
        flexDirection: 'column',
        gap: '12px',
        position: 'relative',
        alignItems: 'center',
      }}
    >
      <div style={{ textAlign: 'center', marginBottom: '24px' }}>
        <div
          style={{
            fontSize: '11px',
            fontWeight: planDateTheme.typography.weights.semibold,
            color: '#F0318B',
            textTransform: 'uppercase',
            letterSpacing: '0.5px',
          }}
        >
          YOUR DATE PAIR
        </div>
      </div>

      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          gap: '8px',
          position: 'relative',
          width: '100%',
          maxWidth: '600px',
        }}
      >
        <div
          style={{
            width: '150px',
            height: '190px',
            borderRadius: '28px',
            background: 'linear-gradient(135deg, #A855F7, #D946EF)',
            position: 'relative',
            flexShrink: 0,
            transform: 'rotate(-6deg)',
            marginLeft: '6px',
            marginRight: '6px',
            overflow: 'hidden',
          }}
        >
          <div
            style={{
              width: '60px',
              height: '60px',
              borderRadius: '50%',
              background: planDateTheme.gradients.partnerRing,
              position: 'absolute',
              top: '12px',
              left: '45px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <img
              src={partner?.avatar || '/default-avatar.png'}
              alt={partner?.name || 'Partner'}
              style={{
                width: '50px',
                height: '50px',
                borderRadius: '50%',
                objectFit: 'cover',
              }}
            />
          </div>
          <div
            style={{
              position: 'absolute',
              bottom: '12px',
              left: '12px',
              fontSize: '12px',
              fontWeight: 'bold',
              color: '#FFFFFF',
              textShadow: '0 2px 4px rgba(0,0,0,0.3)',
            }}
          >
            You
          </div>
          <div
            style={{
              width: '8px',
              height: '8px',
              borderRadius: '50%',
              backgroundColor: planDateTheme.colors.success,
              position: 'absolute',
              top: '12px',
              right: '12px',
            }}
          />
        </div>

        <div
          style={{
            width: '150px',
            height: '190px',
            borderRadius: '28px',
            background: partner?.avatar
              ? 'transparent'
              : planDateTheme.colors.card,
            position: 'relative',
            flexShrink: 0,
            transform: 'rotate(6deg)',
            marginLeft: '-75px',
            overflow: 'hidden',
          }}
        >
          {partner?.avatar && (
            <img
              src={partner?.avatar}
              alt={partner?.name || 'Partner'}
              style={{
                width: '100%',
                height: '100%',
                borderRadius: '28px',
                objectFit: 'cover',
              }}
            />
          )}
          <div
            style={{
              position: 'absolute',
              bottom: '12px',
              left: '12px',
              fontSize: '14px',
              fontWeight: 'bold',
              color: '#FFFFFF',
              textShadow: '0 2px 4px rgba(0,0,0,0.5)',
              textDecoration: 'none',
            }}
          >
            {partner?.name || 'Select Partner'}
          </div>
          <div
            style={{
              width: '8px',
              height: '8px',
              borderRadius: '50%',
              backgroundColor: planDateTheme.colors.success,
              position: 'absolute',
              top: '12px',
              right: '12px',
            }}
          />
        </div>
      </div>

      <div
        style={{
          position: 'absolute',
          width: '72px',
          height: '72px',
          borderRadius: '50%',
          background: 'linear-gradient(135deg, #F0318B, #A21CAF)',
          top: '60px',
          left: '50%',
          transform: 'translateX(-50%)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          border: '2px solid #FFFFFF',
          zIndex: 10,
        }}
      >
        <Heart size={20} color="#FFFFFF" />
      </div>

      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          width: '100%',
          maxWidth: '600px',
        }}
      >
        <Search
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
          value={searchValue}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder="Search for partner..."
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
    </div>
  );
};