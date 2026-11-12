import React from 'react';
import { X, Star, Trash2 } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const PhotoViewerModal: React.FC = () => {
  const {
    viewingPhoto,
    setViewingPhoto,
    setPrimaryPhoto,
    removePhoto,
  } = useProfile();

  if (!viewingPhoto) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 99999,
        background: 'rgba(0, 0, 0, 0.94)',
        backdropFilter: 'blur(24px)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: '20px',
      }}
      onClick={() => setViewingPhoto(null)}
    >
      {/* Top Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          zIndex: 10,
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {viewingPhoto.isPrimary && (
            <span
              style={{
                background: 'var(--gradient-flame)',
                color: 'var(--text-primary)',
                padding: '4px 10px',
                borderRadius: 'var(--radius-full)',
                fontSize: '11px',
                fontWeight: 800,
                display: 'inline-flex',
                alignItems: 'center',
                gap: '4px',
              }}
            >
              <Star size={12} fill="#ffffff" />
              Primary Photo
            </span>
          )}
        </div>

        <button
          onClick={() => setViewingPhoto(null)}
          style={{
            background: 'var(--surface-hover)',
            border: 'none',
            color: 'var(--text-primary)',
            borderRadius: '50%',
            width: '40px',
            height: '40px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
          }}
        >
          <X size={20} />
        </button>
      </div>

      {/* Main Image */}
      <div
        style={{
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '16px',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <img
          src={viewingPhoto.url}
          alt={viewingPhoto.caption || 'Profile Photo'}
          style={{
            maxWidth: '100%',
            maxHeight: '75vh',
            objectFit: 'contain',
            borderRadius: 'var(--radius-md)',
            boxShadow: 'var(--shadow-lg)',
          }}
        />
      </div>

      {/* Bottom Action Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '12px',
          zIndex: 10,
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {!viewingPhoto.isPrimary && (
          <button
            onClick={() => {
              setPrimaryPhoto(viewingPhoto.id);
              setViewingPhoto({ ...viewingPhoto, isPrimary: true });
            }}
            className="btn-primary"
            style={{ padding: '10px 20px', fontSize: '13px', gap: '6px' }}
          >
            <Star size={15} />
            Set as Primary
          </button>
        )}

        <button
          onClick={() => {
            removePhoto(viewingPhoto.id);
            setViewingPhoto(null);
          }}
          className="btn-ghost"
          style={{ padding: '10px 18px', fontSize: '13px', gap: '6px', color: '#ff4757', borderColor: 'rgba(255, 71, 87, 0.4)' }}
        >
          <Trash2 size={15} />
          Remove Photo
        </button>
      </div>
    </div>
  );
};
