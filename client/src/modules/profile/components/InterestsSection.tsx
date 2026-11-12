import React, { useState } from 'react';
import { Heart, Plus, X, Sparkles, Check, Edit3 } from 'lucide-react';
import { useProfile } from '../ProfileContext';
import { DEFAULT_INTEREST_OPTIONS } from '../mockProfile';

export const InterestsSection: React.FC = () => {
  const {
    profile,
    toggleInterest,
    addCustomInterest,
    removeCustomInterest,
  } = useProfile();

  const [isEditing, setIsEditing] = useState(false);
  const [customInput, setCustomInput] = useState('');

  const handleAddCustom = (e: React.FormEvent) => {
    e.preventDefault();
    if (!customInput.trim()) return;
    addCustomInterest(customInput.trim());
    setCustomInput('');
  };

  const totalCount = profile.interests.length + profile.customInterests.length;

  return (
    <div
      id="section-interests"
      style={{
        borderRadius: '22px',
        padding: '16px',
        border: '1px solid #262030',
        background: 'linear-gradient(180deg, #18121e 0%, #120d17 100%)',
      }}
    >
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
            <Heart size={18} />
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', margin: 0 }}>Interests & Passions ({totalCount})</h3>
            <p style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.65)', margin: '2px 0 0 0' }}>Selected topics help matches find you</p>
          </div>
        </div>

        <button
          onClick={() => setIsEditing(!isEditing)}
          style={{
            width: '36px',
            height: '36px',
            borderRadius: '10px',
            background: '#1a141f',
            border: '1px solid #2a2030',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
          }}
          aria-label={isEditing ? 'Done editing interests' : 'Edit interests'}
          title={isEditing ? 'Done editing interests' : 'Edit interests'}
        >
          {isEditing ? <Check size={16} color="#2ed47a" /> : <Edit3 size={16} />}
        </button>
      </div>

      {!isEditing ? (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
          {profile.interests.map((interest) => (
            <div
              key={interest}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '6px',
                padding: '6px 12px',
                borderRadius: '999px',
                background: 'rgba(255, 77, 126, 0.16)',
                border: '1px solid rgba(255, 77, 126, 0.6)',
                color: '#ffffff',
                fontSize: '12.5px',
                fontWeight: 600,
              }}
            >
              <Sparkles size={12} color="#ff4d7e" />
              <span>{interest}</span>
            </div>
          ))}
          {profile.customInterests.map((custom) => (
            <div
              key={custom}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '6px',
                padding: '6px 12px',
                borderRadius: '999px',
                background: 'rgba(34, 211, 238, 0.16)',
                border: '1px solid rgba(34, 211, 238, 0.6)',
                color: '#ffffff',
                fontSize: '12.5px',
                fontWeight: 600,
              }}
            >
              <span style={{ color: '#22d3ee' }}>#</span>
              <span>{custom}</span>
            </div>
          ))}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <form onSubmit={handleAddCustom} style={{ display: 'flex', gap: '8px' }}>
            <input
              type="text"
              value={customInput}
              onChange={(e) => setCustomInput(e.target.value)}
              placeholder="Add custom interest..."
              style={{
                flex: 1,
                padding: '10px 14px',
                borderRadius: '12px',
                background: '#14101a',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '13px',
                outline: 'none',
              }}
            />
            <button
              type="submit"
              style={{
                padding: '10px 16px',
                borderRadius: '12px',
                background: 'linear-gradient(90deg, #ff4d7e 0%, #e0264f 100%)',
                border: 'none',
                color: '#ffffff',
                fontSize: '12px',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                cursor: 'pointer',
              }}
            >
              <Plus size={15} />
              Add
            </button>
          </form>

          {profile.customInterests.length > 0 && (
            <div>
              <div style={{ fontSize: '11px', fontWeight: 700, color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', marginBottom: '8px', letterSpacing: '0.6px' }}>Your Custom Tags</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                {profile.customInterests.map((custom) => (
                  <div
                    key={custom}
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '6px',
                      padding: '4px 10px',
                      borderRadius: '999px',
                      background: 'rgba(34, 211, 238, 0.16)',
                      border: '1px solid rgba(34, 211, 238, 0.6)',
                      fontSize: '12px',
                      color: '#ffffff',
                    }}
                  >
                    <span>{custom}</span>
                    <button
                      type="button"
                      onClick={() => removeCustomInterest(custom)}
                      style={{ background: 'transparent', border: 'none', color: '#ff4d7e', cursor: 'pointer', padding: 0 }}
                    >
                      <X size={13} />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          <div>
            <div style={{ fontSize: '11px', fontWeight: 700, color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', marginBottom: '8px', letterSpacing: '0.6px' }}>Select from Popular Categories</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {DEFAULT_INTEREST_OPTIONS.map((interest) => {
                const isSelected = profile.interests.includes(interest);
                return (
                  <button
                    type="button"
                    key={interest}
                    onClick={() => toggleInterest(interest)}
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '6px',
                      padding: '8px 14px',
                      borderRadius: '999px',
                      border: isSelected ? '1px solid #ff4d7e' : '1px solid #2a2030',
                      background: isSelected ? 'linear-gradient(90deg, rgba(255,77,126,0.3) 0%, rgba(224,38,79,0.3) 100%)' : '#14101a',
                      color: '#ffffff',
                      fontSize: '12.5px',
                      fontWeight: isSelected ? 700 : 500,
                      cursor: 'pointer',
                    }}
                  >
                    {isSelected && <Check size={13} />}
                    <span>{interest}</span>
                  </button>
                );
              })}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
            <button
              onClick={() => setIsEditing(false)}
              style={{
                padding: '8px 16px',
                borderRadius: '10px',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '12px',
                cursor: 'pointer',
              }}
            >
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
