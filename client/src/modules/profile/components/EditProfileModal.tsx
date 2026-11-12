import React, { useState } from 'react';
import {
  X, Save, User, Calendar, MapPin, Briefcase, GraduationCap, Globe, Lock, ChevronDown, Sparkles,
} from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const EditProfileModal: React.FC = () => {
  const {
    profile,
    updateProfile,
    isEditProfileOpen,
    setIsEditProfileOpen,
  } = useProfile();

  const [displayName] = useState(profile.nickname);
  const [dateOfBirth] = useState(profile.dateOfBirth);
  const [preferredNickname, setPreferredNickname] = useState(profile.nickname);
  const [gender, setGender] = useState(profile.gender);
  const [sexualOrientation, setSexualOrientation] = useState(profile.sexualOrientation);
  const [bio, setBio] = useState(profile.bio);
  const [profession, setProfession] = useState(profile.profession);
  const [company, setCompany] = useState(profile.company || '');
  const [education, setEducation] = useState(profile.education);
  const [neighborhood, setNeighborhood] = useState(profile.neighborhood);
  const [languagesStr, setLanguagesStr] = useState(profile.languages.join(', '));
  const [promptAnswer, setPromptAnswer] = useState(profile.personalPrompt.answer);

  if (!isEditProfileOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({
      nickname: preferredNickname,
      gender,
      sexualOrientation,
      bio,
      profession,
      company,
      education,
      neighborhood,
      languages: languagesStr.split(',').map((l) => l.trim()).filter(Boolean),
      personalPrompt: { ...profile.personalPrompt, answer: promptAnswer },
    });
    setIsEditProfileOpen(false);
  };

  const inputBase: React.CSSProperties = {
    width: '100%',
    height: '48px',
    padding: '0 14px',
    borderRadius: '14px',
    background: '#15111b',
    border: '1px solid #2a2332',
    color: '#ffffff',
    fontSize: '14px',
    fontWeight: 600,
    outline: 'none',
    fontFamily: 'inherit',
  };

  const readOnlyInput: React.CSSProperties = {
    ...inputBase,
    background: '#100d15',
    border: '1px dashed #3a3046',
    color: 'rgba(255,255,255,0.5)',
    cursor: 'not-allowed',
    paddingRight: '36px',
  };

  const textareaStyle: React.CSSProperties = {
    width: '100%',
    minHeight: '124px',
    padding: '12px 14px',
    borderRadius: '14px',
    background: '#15111b',
    border: '1px solid #2a2332',
    color: '#ffffff',
    fontSize: '13.5px',
    lineHeight: 1.6,
    outline: 'none',
    resize: 'vertical',
    fontFamily: 'inherit',
  };

  const labelStyle: React.CSSProperties = {
    fontSize: '11.5px',
    fontWeight: 700,
    color: '#b9aec7',
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    marginBottom: '6px',
  };

  const hintStyle: React.CSSProperties = {
    fontSize: '10.5px',
    color: 'rgba(185, 174, 199, 0.7)',
    marginLeft: '4px',
  };

  const fieldWrap: React.CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
  };

  const gridTwo: React.CSSProperties = {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '12px',
  };

  const sectionHeader: React.CSSProperties = {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    marginBottom: '10px',
  };

  const sectionIcon = (color: string, bg: string, border: string): React.CSSProperties => ({
    width: '30px',
    height: '30px',
    borderRadius: '10px',
    background: bg,
    color,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    border: `1px solid ${border}`,
    flexShrink: 0,
  });

  const sectionLabel: React.CSSProperties = {
    fontSize: '11.5px',
    fontWeight: 800,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: '#b9aec7',
  };

  const divider: React.CSSProperties = {
    flex: 1,
    height: '1px',
    background: 'linear-gradient(90deg, rgba(58,48,70,0.9) 0%, transparent 100%)',
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'radial-gradient(600px 400px at 90% -10%, rgba(255, 77, 126, 0.18) 0%, transparent 60%), #0a070d',
        backdropFilter: 'blur(18px)',
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'center',
        padding: '0',
      }}
      onClick={() => setIsEditProfileOpen(false)}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '420px',
          maxHeight: '96vh',
          borderRadius: '30px 30px 0 0',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          border: '1px solid #2a2230',
          borderBottom: 'none',
          background: 'linear-gradient(180deg, #17121d 0%, #110d16 100%)',
          boxShadow: '0 -20px 60px rgba(255, 77, 126, 0.18)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Drag handle */}
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: '10px' }}>
          <div style={{ width: '40px', height: '4px', borderRadius: '999px', background: '#3a3046' }} />
        </div>

        {/* Header */}
        <div
          style={{
            padding: '12px 18px 14px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexShrink: 0,
            borderBottom: '1px solid #2a2230',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '46px',
                height: '46px',
                borderRadius: '14px',
                background: 'linear-gradient(135deg, #ff4d7e 0%, #c026d3 100%)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#ffffff',
                flexShrink: 0,
                boxShadow: '0 10px 30px rgba(255, 77, 126, 0.25)',
              }}
            >
              <User size={22} />
            </div>
            <div>
              <div style={{ fontSize: '19px', fontWeight: 800, color: '#ffffff' }}>Edit Profile</div>
              <div style={{ fontSize: '11.5px', color: 'rgba(255,255,255,0.55)' }}>Update your identity, bio, and dating intro</div>
            </div>
          </div>
          <button
            type="button"
            onClick={() => setIsEditProfileOpen(false)}
            style={{
              width: '36px',
              height: '36px',
              borderRadius: '50%',
              background: '#1a141f',
              border: '1px solid #2a2030',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              flexShrink: 0,
            }}
            aria-label="Close"
          >
            <X size={18} />
          </button>
        </div>

        {/* Form */}
        <form
          id="edit-profile-form"
          onSubmit={handleSubmit}
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: '18px',
            display: 'flex',
            flexDirection: 'column',
            gap: '18px',
          }}
        >
          {/* Identity */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={sectionHeader}>
              <div style={sectionIcon('#ff4d7e', 'rgba(255,77,126,0.18)', 'rgba(255,77,126,0.5)')}>
                <User size={16} />
              </div>
              <div style={sectionLabel}>Identity</div>
              <div style={divider} />
            </div>

            <div style={gridTwo}>
              <div style={fieldWrap}>
                <div style={labelStyle}>
                  <span>Full Name</span>
                </div>
                <div style={{ position: 'relative' }}>
                  <input type="text" value={displayName} disabled style={readOnlyInput} />
                  <Lock size={14} color="rgba(255,255,255,0.4)" style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)' }} />
                </div>
              </div>
              <div style={fieldWrap}>
                <div style={labelStyle}>
                  <Calendar size={12} />
                  <span>Date of Birth</span>
                </div>
                <div style={{ position: 'relative' }}>
                  <input type="date" value={dateOfBirth} disabled style={readOnlyInput} />
                  <Lock size={14} color="rgba(255,255,255,0.4)" style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)' }} />
                </div>
              </div>
            </div>

            <div style={fieldWrap}>
              <div style={labelStyle}>
                <span>Nickname</span>
                <span style={hintStyle}>(visible to others)</span>
              </div>
              <input
                type="text"
                value={preferredNickname}
                onChange={(e) => setPreferredNickname(e.target.value)}
                style={inputBase}
              />
            </div>

            <div style={gridTwo}>
              <div style={fieldWrap}>
                <div style={labelStyle}>Gender</div>
                <div style={{ position: 'relative' }}>
                  <select
                    value={gender}
                    onChange={(e) => setGender(e.target.value)}
                    style={{ ...inputBase, appearance: 'none', paddingRight: '36px', cursor: 'pointer' }}
                  >
                    <option value="Man">Man</option>
                    <option value="Woman">Woman</option>
                    <option value="Non-binary">Non-binary</option>
                    <option value="Prefer not to say">Prefer not to say</option>
                  </select>
                  <ChevronDown size={16} color="rgba(255,255,255,0.5)" style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none' }} />
                </div>
              </div>
              <div style={fieldWrap}>
                <div style={labelStyle}>Sexual Orientation</div>
                <div style={{ position: 'relative' }}>
                  <select
                    value={sexualOrientation}
                    onChange={(e) => setSexualOrientation(e.target.value)}
                    style={{ ...inputBase, appearance: 'none', paddingRight: '36px', cursor: 'pointer' }}
                  >
                    <option value="Straight">Straight</option>
                    <option value="Gay">Gay</option>
                    <option value="Lesbian">Lesbian</option>
                    <option value="Bisexual">Bisexual</option>
                    <option value="Queer">Queer</option>
                    <option value="Pansexual">Pansexual</option>
                  </select>
                  <ChevronDown size={16} color="rgba(255,255,255,0.5)" style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none' }} />
                </div>
              </div>
            </div>
          </div>

          {/* About Me */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={sectionHeader}>
              <div style={sectionIcon('#a855f7', 'rgba(168,85,247,0.18)', 'rgba(168,85,247,0.5)')}>
                <User size={16} />
              </div>
              <div style={sectionLabel}>About Me</div>
              <div style={divider} />
            </div>

            <div style={fieldWrap}>
              <div style={labelStyle}>Personal Bio</div>
              <textarea value={bio} onChange={(e) => setBio(e.target.value)} style={textareaStyle} />
            </div>

            <div
              style={{
                borderRadius: '16px',
                padding: '12px',
                border: '1px solid rgba(255,77,126,0.6)',
                background: 'linear-gradient(90deg, rgba(255,77,126,0.18) 0%, rgba(168,85,247,0.12) 100%)',
                display: 'flex',
                flexDirection: 'column',
                gap: '8px',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#ff4d7e', fontSize: '11.5px', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                <Sparkles size={14} />
                <span>Dating Prompt: "The key to my heart is…"</span>
              </div>
              <input
                type="text"
                value={promptAnswer}
                onChange={(e) => setPromptAnswer(e.target.value)}
                style={{ ...inputBase, background: '#120d17' }}
              />
            </div>
          </div>

          {/* Career & Education */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={sectionHeader}>
              <div style={sectionIcon('#22d3ee', 'rgba(34,211,238,0.18)', 'rgba(34,211,238,0.5)')}>
                <Briefcase size={16} />
              </div>
              <div style={sectionLabel}>Career & Education</div>
              <div style={divider} />
            </div>

            <div style={gridTwo}>
              <div style={fieldWrap}>
                <div style={labelStyle}>
                  <Briefcase size={12} />
                  <span>Profession</span>
                </div>
                <input type="text" value={profession} onChange={(e) => setProfession(e.target.value)} style={inputBase} />
              </div>
              <div style={fieldWrap}>
                <div style={labelStyle}>
                  <Briefcase size={12} />
                  <span>Company / Organisation</span>
                </div>
                <input type="text" value={company} onChange={(e) => setCompany(e.target.value)} style={inputBase} />
              </div>
            </div>

            <div style={fieldWrap}>
              <div style={labelStyle}>
                <GraduationCap size={12} />
                <span>Education / College</span>
              </div>
              <input type="text" value={education} onChange={(e) => setEducation(e.target.value)} style={inputBase} />
            </div>
          </div>

          {/* Location & Languages */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={sectionHeader}>
              <div style={sectionIcon('#2ed47a', 'rgba(46,212,122,0.18)', 'rgba(46,212,122,0.5)')}>
                <MapPin size={16} />
              </div>
              <div style={sectionLabel}>Location & Languages</div>
              <div style={divider} />
            </div>

            <div style={fieldWrap}>
              <div style={labelStyle}>
                <MapPin size={12} />
                <span>City & Neighbourhood</span>
              </div>
              <input type="text" value={neighborhood} onChange={(e) => setNeighborhood(e.target.value)} style={inputBase} />
            </div>

            <div style={fieldWrap}>
              <div style={labelStyle}>
                <Globe size={12} />
                <span>Languages Spoken</span>
                <span style={hintStyle}>(comma-separated)</span>
              </div>
              <input type="text" value={languagesStr} onChange={(e) => setLanguagesStr(e.target.value)} style={inputBase} />
            </div>
          </div>
        </form>

        {/* Footer */}
        <div
          style={{
            flexShrink: 0,
            padding: '12px 18px calc(12px + env(safe-area-inset-bottom, 0px))',
            borderTop: '1px solid #2a2230',
            background: 'rgba(17,13,22,0.98)',
            display: 'flex',
            gap: '10px',
          }}
        >
          <button
            type="button"
            onClick={() => setIsEditProfileOpen(false)}
            style={{
              flex: 1,
              height: '52px',
              borderRadius: '16px',
              background: '#1a141f',
              border: '1px solid #2a2030',
              color: '#ffffff',
              fontSize: '14px',
              fontWeight: 700,
              cursor: 'pointer',
            }}
          >
            Cancel
          </button>
          <button
            type="submit"
            form="edit-profile-form"
            style={{
              flex: 1.5,
              height: '52px',
              borderRadius: '16px',
              background: 'linear-gradient(90deg, #ff4d7e 0%, #c026d3 100%)',
              border: 'none',
              color: '#ffffff',
              fontSize: '14px',
              fontWeight: 800,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              cursor: 'pointer',
              boxShadow: '0 12px 40px rgba(255, 77, 126, 0.28)',
            }}
          >
            <Save size={18} />
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
};
