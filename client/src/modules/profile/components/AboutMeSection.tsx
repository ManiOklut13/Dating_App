import React, { useState } from 'react';
import { User, Briefcase, GraduationCap, MapPin, Globe, Sparkles, Edit3, Check, X } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const AboutMeSection: React.FC = () => {
  const { profile, updateProfile } = useProfile();

  const [isEditingInline, setIsEditingInline] = useState(false);
  const [bio, setBio] = useState(profile.bio);
  const [profession, setProfession] = useState(profile.profession);
  const [company, setCompany] = useState(profile.company || '');
  const [education, setEducation] = useState(profile.education);
  const [neighborhood, setNeighborhood] = useState(profile.neighborhood);
  const [promptAnswer, setPromptAnswer] = useState(profile.personalPrompt.answer);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({
      bio,
      profession,
      company,
      education,
      neighborhood,
      personalPrompt: {
        ...profile.personalPrompt,
        answer: promptAnswer,
      },
    });
    setIsEditingInline(false);
  };

  const handleCancel = () => {
    setBio(profile.bio);
    setProfession(profile.profession);
    setCompany(profile.company || '');
    setEducation(profile.education);
    setNeighborhood(profile.neighborhood);
    setPromptAnswer(profile.personalPrompt.answer);
    setIsEditingInline(false);
  };

  return (
    <div
      id="section-aboutme"
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
            <User size={18} />
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', margin: 0 }}>About Me</h3>
            <p style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.65)', margin: '2px 0 0 0' }}>Tell people about you</p>
          </div>
        </div>

        {!isEditingInline ? (
          <button
            onClick={() => setIsEditingInline(true)}
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
            aria-label="Edit about me"
            title="Edit about me"
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

      {!isEditingInline ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <p style={{ fontSize: '13.5px', lineHeight: 1.6, color: 'rgba(255,255,255,0.9)' }}>
            {profile.bio}
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px 12px', borderRadius: '12px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '10px', background: 'rgba(255, 77, 126, 0.18)', color: '#ff4d7e', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid rgba(255, 77, 126, 0.5)' }}>
                <Briefcase size={16} />
              </div>
              <div>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Profession</div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#ffffff' }}>{profile.profession} {profile.company && `• ${profile.company}`}</div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px 12px', borderRadius: '12px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '10px', background: 'rgba(34, 211, 238, 0.18)', color: '#22d3ee', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid rgba(34, 211, 238, 0.5)' }}>
                <GraduationCap size={16} />
              </div>
              <div>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Education</div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#ffffff' }}>{profile.education}</div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px 12px', borderRadius: '12px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '10px', background: 'rgba(255, 210, 74, 0.18)', color: '#ffd24a', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid rgba(255, 210, 74, 0.5)' }}>
                <MapPin size={16} />
              </div>
              <div>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>City / Location</div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#ffffff' }}>{profile.location} ({profile.neighborhood})</div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px 12px', borderRadius: '12px', background: '#14101a', border: '1px solid #2a2030' }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '10px', background: 'rgba(46, 212, 122, 0.18)', color: '#2ed47a', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid rgba(46, 212, 122, 0.5)' }}>
                <Globe size={16} />
              </div>
              <div>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Languages</div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#ffffff' }}>{profile.languages.join(', ')}</div>
              </div>
            </div>
          </div>

          <div
            style={{
              padding: '14px 16px',
              borderRadius: '14px',
              background: 'linear-gradient(90deg, rgba(255, 77, 126, 0.18) 0%, rgba(168, 85, 247, 0.12) 100%)',
              border: '1px solid rgba(255, 77, 126, 0.5)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: '#ff4d7e', fontWeight: 700, textTransform: 'uppercase', marginBottom: '6px', letterSpacing: '0.6px' }}>
              <Sparkles size={13} />
              <span>Personal Dating Prompt</span>
            </div>
            <div style={{ fontSize: '14px', fontWeight: 800, color: '#ffffff', marginBottom: '4px' }}>
              "{profile.personalPrompt.question}"
            </div>
            <div style={{ fontSize: '13px', color: 'rgba(255,255,255,0.8)', lineHeight: 1.6 }}>
              {profile.personalPrompt.answer}
            </div>
          </div>
        </div>
      ) : (
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div>
            <label style={{ fontSize: '12px', fontWeight: 700, color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '6px' }}>Personal Bio</label>
            <textarea
              rows={3}
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              style={{
                width: '100%',
                padding: '10px 14px',
                borderRadius: '12px',
                background: '#14101a',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '13px',
                outline: 'none',
                resize: 'vertical',
              }}
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px' }}>
            <div>
              <label style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '4px' }}>Profession</label>
              <input
                type="text"
                value={profession}
                onChange={(e) => setProfession(e.target.value)}
                style={{
                  width: '100%',
                  padding: '8px 12px',
                  borderRadius: '10px',
                  background: '#14101a',
                  border: '1px solid #2a2030',
                  color: '#ffffff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
            </div>
            <div>
              <label style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '4px' }}>Company</label>
              <input
                type="text"
                value={company}
                onChange={(e) => setCompany(e.target.value)}
                style={{
                  width: '100%',
                  padding: '8px 12px',
                  borderRadius: '10px',
                  background: '#14101a',
                  border: '1px solid #2a2030',
                  color: '#ffffff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
            </div>
            <div>
              <label style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '4px' }}>Education</label>
              <input
                type="text"
                value={education}
                onChange={(e) => setEducation(e.target.value)}
                style={{
                  width: '100%',
                  padding: '8px 12px',
                  borderRadius: '10px',
                  background: '#14101a',
                  border: '1px solid #2a2030',
                  color: '#ffffff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
            </div>
            <div>
              <label style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '4px' }}>Neighborhood</label>
              <input
                type="text"
                value={neighborhood}
                onChange={(e) => setNeighborhood(e.target.value)}
                style={{
                  width: '100%',
                  padding: '8px 12px',
                  borderRadius: '10px',
                  background: '#14101a',
                  border: '1px solid #2a2030',
                  color: '#ffffff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
            </div>
          </div>

          <div>
            <label style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', display: 'block', marginBottom: '4px' }}>Personal Prompt Answer ("{profile.personalPrompt.question}")</label>
            <input
              type="text"
              value={promptAnswer}
              onChange={(e) => setPromptAnswer(e.target.value)}
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: '10px',
                background: '#14101a',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '13px',
                outline: 'none',
              }}
            />
          </div>
        </form>
      )}
    </div>
  );
};
