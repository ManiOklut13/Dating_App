import React, { useState } from 'react';
import { ArrowLeft, Heart, Camera, Plus, X } from 'lucide-react';
import { planDateTheme } from '../theme';

interface AfterTheDateScreenProps {
  mode: 'virtual' | 'offline';
  dateType: string;
  spotName?: string;
  dateInfo: string;
  onBack: () => void;
  partnerName?: string;
}

const SPECIAL_TAGS = ['Great conversation', 'Lots of laughs', 'Felt comfortable', 'Great food', 'Perfect spot', 'Would repeat'];

export const AfterTheDateScreen: React.FC<AfterTheDateScreenProps> = ({
  mode,
  dateType,
  spotName,
  dateInfo,
  onBack,
  partnerName = 'partner',
}) => {
  const [rating, setRating] = useState(0);
  const [photos, setPhotos] = useState<string[]>([]);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [memoryNote, setMemoryNote] = useState('');
  const [shareWithPartner, setShareWithPartner] = useState(true);
  const [demoMode, setDemoMode] = useState(mode);

  const handleAddPhoto = () => {
    if (photos.length < 6) {
      // Mock photo addition
      setPhotos([...photos, `https://picsum.photos/200/200?random=${Date.now()}`]);
    }
  };

  const removePhoto = (index: number) => {
    setPhotos(photos.filter((_, i) => i !== index));
  };

  const toggleTag = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter(t => t !== tag));
    } else {
      setSelectedTags([...selectedTags, tag]);
    }
  };

  const title = demoMode === 'virtual' ? dateType : spotName ? `${dateType} at ${spotName}` : dateType;
  const subtitle = demoMode === 'virtual' ? `Virtual Date · ${dateInfo}` : `Offline Date · ${dateInfo}`;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 10001,
        backgroundColor: planDateTheme.colors.background,
        backgroundImage: `${planDateTheme.gradients.backgroundRadialPink}, ${planDateTheme.gradients.backgroundRadialViolet}`,
        backgroundPosition: 'top right, top left',
        backgroundRepeat: 'no-repeat',
        display: 'flex',
        flexDirection: 'column',
        fontFamily: planDateTheme.typography.fontFamily,
      }}
    >
      <div
        style={{
          padding: '16px',
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          borderBottom: `1px solid ${planDateTheme.colors.cardBorder}`,
        }}
      >
        <button
          onClick={onBack}
          aria-label="Go back"
          style={{
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            backgroundColor: 'transparent',
            border: 'none',
            color: planDateTheme.colors.text,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            padding: 0,
          }}
        >
          <ArrowLeft size={20} />
        </button>
        <h1
          style={{
            fontSize: '20px',
            fontWeight: planDateTheme.typography.weights.extrabold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
            flex: 1,
          }}
        >
          After the{' '}
          <span
            style={{
              background: planDateTheme.gradients.dateText,
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              backgroundClip: 'text',
            }}
          >
            Date
          </span>
        </h1>
      </div>

      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '16px',
          display: 'flex',
          flexDirection: 'column',
          gap: '16px',
        }}
      >
        <div
          style={{
            background: planDateTheme.gradients.highlightCard,
            border: `1px solid ${planDateTheme.colors.highlightCardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '16px',
                background: planDateTheme.gradients.primary,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF',
                flexShrink: 0,
              }}
            >
              <Heart size={24} />
            </div>
            <div style={{ flex: 1 }}>
              <div
                style={{
                  fontSize: '16px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {title}
              </div>
              <div
                style={{
                  fontSize: '13px',
                  color: planDateTheme.colors.muted,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {subtitle}
              </div>
            </div>
          </div>

          <div
            style={{
              display: 'flex',
              backgroundColor: planDateTheme.colors.innerField,
              border: `1px solid ${planDateTheme.colors.innerFieldBorder}`,
              borderRadius: `${planDateTheme.borderRadius.large}px`,
              padding: '5px',
              gap: '6px',
            }}
          >
            <button
              onClick={() => setDemoMode('virtual')}
              style={{
                flex: 1,
                height: '48px',
                borderRadius: `${planDateTheme.borderRadius.inner}px`,
                background: demoMode === 'virtual' ? planDateTheme.gradients.primary : 'transparent',
                border: 'none',
                color: demoMode === 'virtual' ? '#FFFFFF' : planDateTheme.colors.softText,
                fontSize: '14px',
                fontWeight: planDateTheme.typography.weights.bold,
                fontFamily: planDateTheme.typography.fontFamily,
                cursor: 'pointer',
              }}
            >
              Virtual
            </button>
            <button
              onClick={() => setDemoMode('offline')}
              style={{
                flex: 1,
                height: '48px',
                borderRadius: `${planDateTheme.borderRadius.inner}px`,
                background: demoMode === 'offline' ? planDateTheme.gradients.primary : 'transparent',
                border: 'none',
                color: demoMode === 'offline' ? '#FFFFFF' : planDateTheme.colors.softText,
                fontSize: '14px',
                fontWeight: planDateTheme.typography.weights.bold,
                fontFamily: planDateTheme.typography.fontFamily,
                cursor: 'pointer',
              }}
            >
              Offline
            </button>
          </div>
        </div>

        <div
          style={{
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.cardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <h3
            style={{
              fontSize: '16px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              margin: '0 0 4px 0',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            How did it go?
          </h3>
          <p
            style={{
              fontSize: '12px',
              color: planDateTheme.colors.muted,
              margin: '0 0 12px 0',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            Your rating is private until your partner shares hers.
          </p>
          <div style={{ display: 'flex', gap: '8px', justifyContent: 'center' }}>
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                onClick={() => setRating(star)}
                aria-label={`Rate ${star} hearts`}
                style={{
                  width: '56px',
                  height: '56px',
                  borderRadius: '18px',
                  backgroundColor: star <= rating ? '#2A1522' : planDateTheme.colors.idleChip,
                  border: `1px solid ${star <= rating ? '#6B2A48' : planDateTheme.colors.cardBorder}`,
                  color: star <= rating ? '#FF5C9A' : '#8F83A3',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  padding: 0,
                }}
              >
                <Heart size={24} fill={star <= rating ? '#FF5C9A' : 'none'} />
              </button>
            ))}
          </div>
        </div>

        <div
          style={{
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.cardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
            <h3
              style={{
                fontSize: '16px',
                fontWeight: planDateTheme.typography.weights.bold,
                color: planDateTheme.colors.text,
                margin: 0,
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              Add Photos
            </h3>
            <span
              style={{
                fontSize: '12px',
                fontWeight: planDateTheme.typography.weights.bold,
                color: planDateTheme.colors.accentText,
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {photos.length} of 6 added
            </span>
          </div>
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: '10px',
            }}
          >
            {photos.map((photo, index) => (
              <div
                key={index}
                style={{
                  aspectRatio: '1',
                  borderRadius: '18px',
                  overflow: 'hidden',
                  position: 'relative',
                }}
              >
                <img src={photo} alt={`Photo ${index + 1}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                <button
                  onClick={() => removePhoto(index)}
                  style={{
                    position: 'absolute',
                    top: '4px',
                    right: '4px',
                    width: '24px',
                    height: '24px',
                    borderRadius: '50%',
                    backgroundColor: 'rgba(0,0,0,0.6)',
                    border: 'none',
                    color: '#FFFFFF',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                    padding: 0,
                  }}
                >
                  <X size={12} />
                </button>
              </div>
            ))}
            {photos.length < 6 && (
              <button
                onClick={handleAddPhoto}
                style={{
                  aspectRatio: '1',
                  borderRadius: '18px',
                  border: '1.5px dashed #4A3A5E',
                  backgroundColor: 'transparent',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                  cursor: 'pointer',
                  color: planDateTheme.colors.accentText,
                }}
              >
                <Camera size={24} />
                <span style={{ fontSize: '11px', fontWeight: planDateTheme.typography.weights.semibold }}>Add</span>
              </button>
            )}
          </div>
        </div>

        <div
          style={{
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.cardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <h3
            style={{
              fontSize: '16px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              margin: '0 0 12px 0',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            What made it special?
          </h3>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {SPECIAL_TAGS.map((tag) => (
              <button
                key={tag}
                onClick={() => toggleTag(tag)}
                style={{
                  height: '44px',
                  borderRadius: '14px',
                  backgroundColor: selectedTags.includes(tag) ? planDateTheme.colors.raisedButton : planDateTheme.colors.idleChip,
                  border: `1px solid ${selectedTags.includes(tag) ? planDateTheme.colors.raisedButtonBorder : planDateTheme.colors.idleChipBorder}`,
                  color: planDateTheme.colors.softText,
                  fontSize: '13px',
                  fontWeight: planDateTheme.typography.weights.semibold,
                  fontFamily: planDateTheme.typography.fontFamily,
                  padding: '0 14px',
                  cursor: 'pointer',
                }}
              >
                {tag}
              </button>
            ))}
          </div>
        </div>

        <div
          style={{
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.cardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <h3
            style={{
              fontSize: '16px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              margin: '0 0 10px 0',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            Memory Note
          </h3>
          <div
            style={{
              backgroundColor: planDateTheme.colors.innerField,
              borderRadius: '16px',
              padding: '10px',
              height: '80px',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <textarea
              value={memoryNote}
              onChange={(e) => setMemoryNote(e.target.value.slice(0, 200))}
              placeholder="Write a memory..."
              style={{
                flex: 1,
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.text,
                fontSize: '13px',
                fontFamily: planDateTheme.typography.fontFamily,
                resize: 'none',
                outline: 'none',
              }}
            />
            <div
              style={{
                fontSize: '11px',
                color: planDateTheme.colors.placeholder,
                textAlign: 'right',
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {memoryNote.length}/200
            </div>
          </div>
        </div>

        <div
          style={{
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.cardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div>
            <div
              style={{
                fontSize: '15px',
                fontWeight: planDateTheme.typography.weights.bold,
                color: planDateTheme.colors.text,
                fontFamily: planDateTheme.typography.fontFamily,
                marginBottom: '2px',
              }}
            >
              Share with {partnerName || 'partner'}
            </div>
            <div
              style={{
                fontSize: '13px',
                color: planDateTheme.colors.muted,
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {shareWithPartner ? 'Aanya can see your photos and note in your shared memories.' : 'Only you can see these memories.'}
            </div>
          </div>
          <button
            onClick={() => setShareWithPartner(!shareWithPartner)}
            style={{
              width: '52px',
              height: '30px',
              borderRadius: '15px',
              background: shareWithPartner ? planDateTheme.gradients.primary : '#3A2F4A',
              border: 'none',
              position: 'relative',
              cursor: 'pointer',
              minWidth: '60px',
              minHeight: '44px',
            }}
            aria-label="Toggle sharing"
          >
            <div
              style={{
                width: '24px',
                height: '24px',
                borderRadius: '50%',
                backgroundColor: '#FFFFFF',
                position: 'absolute',
                top: '3px',
                left: shareWithPartner ? '25px' : '3px',
                transition: 'left 0.2s ease',
              }}
            />
          </button>
        </div>

        <button
          style={{
            width: '100%',
            height: '60px',
            borderRadius: '20px',
            background: planDateTheme.gradients.primary,
            border: 'none',
            color: '#FFFFFF',
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.extrabold,
            fontFamily: planDateTheme.typography.fontFamily,
            cursor: 'pointer',
            boxShadow: planDateTheme.colors.ctaShadow,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
          }}
        >
          <Heart size={18} />
          Save to memories
        </button>
      </div>
    </div>
  );
};
