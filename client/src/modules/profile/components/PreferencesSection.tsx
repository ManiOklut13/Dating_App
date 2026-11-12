import React, { useState } from 'react';
import { Compass, Check, Edit3, X } from 'lucide-react';
import { useProfile } from '../ProfileContext';
import { DEFAULT_ACTIVITY_OPTIONS } from '../mockProfile';

const LOOKING_FOR_OPTIONS: Array<
  'Dating' | 'Friendship' | 'New Friends' | 'Both Dating and Friendship'
> = ['Dating', 'Friendship', 'New Friends', 'Both Dating and Friendship'];

const INTERESTED_IN_OPTIONS: Array<
  'Men' | 'Women' | 'Non-binary people' | 'Everyone'
> = ['Men', 'Women', 'Non-binary people', 'Everyone'];

export const PreferencesSection: React.FC = () => {
  const { profile, updatePreferences } = useProfile();

  const [isEditing, setIsEditing] = useState(false);
  const [lookingFor, setLookingFor] = useState(profile.preferences.lookingFor);
  const [interestedIn, setInterestedIn] = useState(profile.preferences.interestedIn);
  const [minAge, setMinAge] = useState(profile.preferences.ageRange[0]);
  const [maxAge, setMaxAge] = useState(profile.preferences.ageRange[1]);
  const [distanceKm, setDistanceKm] = useState(profile.preferences.distanceRangeKm);
  const [activities, setActivities] = useState<string[]>(profile.preferences.activities);

  const toggleActivity = (act: string) => {
    setActivities((prev) =>
      prev.includes(act) ? prev.filter((a) => a !== act) : [...prev, act]
    );
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    updatePreferences({
      lookingFor,
      interestedIn,
      ageRange: [Number(minAge), Number(maxAge)],
      distanceRangeKm: Number(distanceKm),
      activities,
    });
    setIsEditing(false);
  };

  const handleCancel = () => {
    setLookingFor(profile.preferences.lookingFor);
    setInterestedIn(profile.preferences.interestedIn);
    setMinAge(profile.preferences.ageRange[0]);
    setMaxAge(profile.preferences.ageRange[1]);
    setDistanceKm(profile.preferences.distanceRangeKm);
    setActivities(profile.preferences.activities);
    setIsEditing(false);
  };

  return (
    <div
      id="section-preferences"
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
              background: 'rgba(168, 85, 247, 0.18)',
              color: '#a855f7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: '1px solid rgba(168, 85, 247, 0.5)',
              flexShrink: 0,
            }}
          >
            <Compass size={18} />
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', margin: 0 }}>Dating & Discovery Preferences</h3>
            <p style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.65)', margin: '2px 0 0 0' }}>Who you want to meet</p>
          </div>
        </div>

        {!isEditing ? (
          <button
            onClick={() => setIsEditing(true)}
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
            aria-label="Edit dating and discovery preferences"
            title="Edit dating and discovery preferences"
          >
            <Edit3 size={16} />
          </button>
        ) : (
          <div style={{ display: 'flex', gap: '6px' }}>
            <button
              onClick={handleCancel}
              style={{
                padding: '8px 12px',
                borderRadius: '10px',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '12px',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                cursor: 'pointer',
              }}
            >
              <X size={14} />
              Cancel
            </button>
            <button
              onClick={handleSave}
              style={{
                padding: '8px 14px',
                borderRadius: '10px',
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
              <Check size={14} />
              Save
            </button>
          </div>
        )}
      </div>

      {!isEditing ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
            <div style={{ padding: '12px', borderRadius: '14px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '6px' }}>Looking For</div>
              <div style={{ fontSize: '16px', fontWeight: 800, color: '#ff4d7e' }}>{profile.preferences.lookingFor}</div>
            </div>
            <div style={{ padding: '12px', borderRadius: '14px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '6px' }}>Interested In</div>
              <div style={{ fontSize: '16px', fontWeight: 800, color: '#22d3ee' }}>{profile.preferences.interestedIn}</div>
            </div>
          </div>

          <div style={{ padding: '12px', borderRadius: '14px', background: '#14101a', border: '1px solid #2a2030' }}>
            <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '6px' }}>Age Range</div>
            <div style={{ fontSize: '16px', fontWeight: 800, color: '#ffd24a' }}>{profile.preferences.ageRange[0]} – {profile.preferences.ageRange[1]} years old</div>
          </div>

          <div style={{ padding: '12px', borderRadius: '14px', background: '#14101a', border: '1px solid #2a2030' }}>
            <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '6px' }}>Max Distance</div>
            <div style={{ fontSize: '16px', fontWeight: 800, color: '#2ed47a' }}>Within {profile.preferences.distanceRangeKm} km</div>
          </div>

          {profile.preferences.activities.length > 0 && (
            <div>
              <div style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', marginBottom: '8px' }}>Activities To Do Together</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {profile.preferences.activities.map((act) => (
                  <span
                    key={act}
                    style={{
                      padding: '4px 10px',
                      borderRadius: '999px',
                      background: '#1a141f',
                      border: '1px solid #2a2030',
                      fontSize: '12px',
                      color: '#ffffff',
                      fontWeight: 600,
                    }}
                  >
                    {act}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
      ) : (
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div>
            <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '8px' }}>I am Looking For</label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {LOOKING_FOR_OPTIONS.map((opt) => (
                <button
                  type="button"
                  key={opt}
                  onClick={() => setLookingFor(opt)}
                  style={{
                    padding: '8px 12px',
                    borderRadius: '999px',
                    border: lookingFor === opt ? '1px solid #ff4d7e' : '1px solid #2a2030',
                    background: lookingFor === opt ? 'rgba(255, 77, 126, 0.2)' : '#14101a',
                    color: '#ffffff',
                    fontSize: '12.5px',
                    fontWeight: lookingFor === opt ? 700 : 500,
                    cursor: 'pointer',
                  }}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '8px' }}>Interested In Meeting</label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {INTERESTED_IN_OPTIONS.map((opt) => (
                <button
                  type="button"
                  key={opt}
                  onClick={() => setInterestedIn(opt)}
                  style={{
                    padding: '8px 12px',
                    borderRadius: '999px',
                    border: interestedIn === opt ? '1px solid #22d3ee' : '1px solid #2a2030',
                    background: interestedIn === opt ? 'rgba(34, 211, 238, 0.2)' : '#14101a',
                    color: '#ffffff',
                    fontSize: '12.5px',
                    fontWeight: interestedIn === opt ? 700 : 500,
                    cursor: 'pointer',
                  }}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
              <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)' }}>Age Range</label>
              <span style={{ fontSize: '13px', fontWeight: 700, color: '#ffd24a' }}>{minAge} – {maxAge} years</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <input type="range" min="18" max="60" value={minAge} onChange={(e) => setMinAge(Math.min(Number(e.target.value), maxAge - 1))} style={{ flex: 1, accentColor: '#ff4d7e' }} />
              <span style={{ color: 'rgba(255,255,255,0.5)' }}>to</span>
              <input type="range" min="18" max="60" value={maxAge} onChange={(e) => setMaxAge(Math.max(Number(e.target.value), minAge + 1))} style={{ flex: 1, accentColor: '#ff4d7e' }} />
            </div>
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
              <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)' }}>Discovery Distance</label>
              <span style={{ fontSize: '13px', fontWeight: 700, color: '#2ed47a' }}>Up to {distanceKm} km</span>
            </div>
            <input type="range" min="5" max="100" value={distanceKm} onChange={(e) => setDistanceKm(Number(e.target.value))} style={{ width: '100%', accentColor: '#2ed47a' }} />
          </div>

          <div>
            <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '8px' }}>Activities To Do Together</label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {DEFAULT_ACTIVITY_OPTIONS.map((act) => {
                const isSelected = activities.includes(act);
                return (
                  <button
                    type="button"
                    key={act}
                    onClick={() => toggleActivity(act)}
                    style={{
                      padding: '6px 12px',
                      borderRadius: '999px',
                      border: isSelected ? '1px solid #2ed47a' : '1px solid #2a2030',
                      background: isSelected ? 'rgba(46, 212, 122, 0.2)' : '#14101a',
                      color: isSelected ? '#2ed47a' : '#ffffff',
                      fontSize: '12px',
                      fontWeight: isSelected ? 700 : 500,
                      cursor: 'pointer',
                    }}
                  >
                    {act}
                  </button>
                );
              })}
            </div>
          </div>
        </form>
      )}
    </div>
  );
};
