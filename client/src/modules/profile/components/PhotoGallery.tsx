import React, { useRef } from 'react';
import { Plus, Star, Edit3, Image as ImageIcon } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const PhotoGallery: React.FC = () => {
  const {
    profile,
    addPhoto,
    setViewingPhoto,
  } = useProfile();

  const fileInputRef = useRef<HTMLInputElement>(null);

  const maxPhotos = 6;
  const photos = profile.photos;
  const canAddMore = photos.length < maxPhotos;

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const previewUrl = URL.createObjectURL(file);
      addPhoto(previewUrl, file.name.replace(/\.[^/.]+$/, ''));
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  return (
    <div
      id="section-photos"
      style={{
        borderRadius: '22px',
        padding: '16px',
        border: '1px solid #262030',
        background: 'linear-gradient(180deg, #18121e 0%, #120d17 100%)',
      }}
    >
      {/* Hidden file input */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/*"
        style={{ display: 'none' }}
      />

      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '10px',
              background: 'rgba(255, 77, 126, 0.18)',
              color: '#ff4d7e',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: '1px solid rgba(255, 77, 126, 0.5)',
              flexShrink: 0,
            }}
          >
            <ImageIcon size={18} />
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', margin: 0 }}>
              Photos ({photos.length}/{maxPhotos})
            </h3>
            <p style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.65)', margin: '2px 0 0 0' }}>
              Upload up to 6 high-resolution photos
            </p>
          </div>
        </div>
      </div>

      {/* Photo Grid */}
      {photos.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px 20px', background: '#14101a', borderRadius: '16px', color: 'rgba(255,255,255,0.5)', border: '1px solid #2a2030' }}>
          No photos added yet
        </div>
      ) : (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '10px',
          }}
        >
          {photos.map((photo, index) => (
            <div
              key={photo.id}
              style={{
                position: 'relative',
                aspectRatio: '3/4',
                borderRadius: '16px',
                overflow: 'hidden',
                border: photo.isPrimary ? '2px solid #ff4d7e' : '1px solid #2a2030',
                boxShadow: photo.isPrimary ? '0 0 0 1px rgba(255, 77, 126, 0.4), 0 10px 30px rgba(255, 77, 126, 0.15)' : 'none',
                background: '#14101a',
              }}
            >
              <img
                src={photo.url}
                alt={photo.caption || `Photo ${index + 1}`}
                onClick={() => setViewingPhoto(photo)}
                style={{ width: '100%', height: '100%', objectFit: 'cover', cursor: 'pointer' }}
              />

              {photo.isPrimary && (
                <div
                  style={{
                    position: 'absolute',
                    top: '8px',
                    left: '8px',
                    background: 'linear-gradient(90deg, #ff4d7e 0%, #a855f7 100%)',
                    color: '#ffffff',
                    fontSize: '10px',
                    fontWeight: 800,
                    padding: '2px 8px',
                    borderRadius: '999px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                    boxShadow: '0 6px 20px rgba(168, 85, 247, 0.25)',
                  }}
                >
                  <Star size={10} fill="#ffffff" />
                  Primary
                </div>
              )}

              <div
                style={{
                  position: 'absolute',
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: '40%',
                  background: 'linear-gradient(180deg, transparent 0%, rgba(11,8,14,0.9) 100%)',
                }}
              />

              <button
                onClick={() => fileInputRef.current?.click()}
                style={{
                  position: 'absolute',
                  bottom: '8px',
                  right: '8px',
                  background: '#1a141f',
                  border: '1px solid #2a2030',
                  color: '#ffffff',
                  borderRadius: '50%',
                  width: '28px',
                  height: '28px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
                title="Edit Photo"
              >
                <Edit3 size={12} />
              </button>
            </div>
          ))}

          {canAddMore && (
            <div
              onClick={() => fileInputRef.current?.click()}
              style={{
                aspectRatio: '3/4',
                borderRadius: '16px',
                border: '1px dashed rgba(255, 77, 126, 0.6)',
                background: '#14101a',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                cursor: 'pointer',
                color: 'rgba(255,255,255,0.7)',
              }}
            >
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '50%',
                  background: 'rgba(255, 77, 126, 0.18)',
                  color: '#ff4d7e',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: '1px solid rgba(255, 77, 126, 0.5)',
                }}
              >
                <Plus size={20} />
              </div>
              <span style={{ fontSize: '11px', fontWeight: 600 }}>Add Photo</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
