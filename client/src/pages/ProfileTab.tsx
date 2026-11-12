import React from 'react';
import { useProfile } from '../modules/profile/ProfileContext';
import { ProfileHeaderCard } from '../modules/profile/components/ProfileHeaderCard';
import { ProfileCompletionCard } from '../modules/profile/components/ProfileCompletionCard';
import { PhotoGallery } from '../modules/profile/components/PhotoGallery';
import { AboutMeSection } from '../modules/profile/components/AboutMeSection';
import { InterestsSection } from '../modules/profile/components/InterestsSection';
import { PreferencesSection } from '../modules/profile/components/PreferencesSection';
import { VerificationCenter } from '../modules/profile/components/VerificationCenter';
import { EditProfileModal } from '../modules/profile/components/EditProfileModal';
import { ProfilePreviewModal } from '../modules/profile/components/ProfilePreviewModal';
import { VerificationModal } from '../modules/profile/components/VerificationModal';
import { PhotoViewerModal } from '../modules/profile/components/PhotoViewerModal';
import { NotificationsModal } from '../modules/profile/components/NotificationsModal';
import { MockLoginPage } from '../modules/profile/components/MockLoginPage';
import { Check, X, AlertTriangle, Info } from 'lucide-react';

interface ProfileTabProps {
  coinBalance?: number;
  onOpenStore: () => void;
  onOpenWheel: () => void;
  onOpenMatches?: () => void;
  onBack?: () => void;
}

const ProfileInnerContent: React.FC<{
  onOpenStore: () => void;
  onOpenWheel: () => void;
  onOpenMatches?: () => void;
  onBack?: () => void;
}> = ({
  onOpenStore,
  onOpenWheel,
  onOpenMatches,
  onBack,
}) => {
  const { isLoggedIn, toast, clearToast, profile } = useProfile();

  if (!isLoggedIn) {
    return <MockLoginPage />;
  }

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100%',
        width: '100%',
        position: 'relative',
        boxSizing: 'border-box',
        background: 'radial-gradient(1200px 600px at 90% -10%, rgba(255, 77, 126, 0.14) 0%, transparent 60%), radial-gradient(900px 500px at -10% 10%, rgba(168, 85, 247, 0.12) 0%, transparent 60%), #0b080e',
      }}
    >
      {/* Toast Feedback Banner */}
      {toast && (
        <div
          style={{
            position: 'fixed',
            top: '70px',
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 99999,
            minWidth: '280px',
            maxWidth: '92vw',
            padding: '10px 18px',
            borderRadius: '12px',
            background:
              toast.type === 'error'
                ? 'rgba(255, 71, 87, 0.95)'
                : toast.type === 'warning'
                ? 'rgba(255, 170, 0, 0.95)'
                : toast.type === 'info'
                ? 'rgba(34, 211, 238, 0.95)'
                : 'rgba(46, 212, 122, 0.95)',
            color: toast.type === 'warning' ? '#000000' : '#ffffff',
            boxShadow: '0 10px 40px rgba(0,0,0,0.5)',
            border: '1px solid rgba(255, 255, 255, 0.2)',
            backdropFilter: 'blur(16px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '10px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', fontWeight: 600 }}>
            {toast.type === 'error' && <AlertTriangle size={16} />}
            {toast.type === 'success' && <Check size={16} />}
            {toast.type === 'info' && <Info size={16} />}
            <span>{toast.message}</span>
          </div>
          <button
            onClick={clearToast}
            style={{ background: 'transparent', border: 'none', color: 'inherit', cursor: 'pointer', padding: 0 }}
          >
            <X size={15} />
          </button>
        </div>
      )}

      {/* Main Profile Sections */}
      <div
        style={{
          width: '100%',
          maxWidth: '420px',
          margin: '0 auto',
          padding: 'calc(12px + env(safe-area-inset-top, 0px)) 14px 90px',
          display: 'flex',
          flexDirection: 'column',
          gap: '14px',
          boxSizing: 'border-box',
        }}
      >
        <ProfileHeaderCard onOpenMatches={onOpenMatches} />
        <ProfileCompletionCard />
        <PhotoGallery />
        <AboutMeSection />
        <InterestsSection />
        <PreferencesSection />
        {profile.verification.status !== 'verified' && <VerificationCenter />}
      </div>

      <EditProfileModal />
      <ProfilePreviewModal />
      <VerificationModal />
      <PhotoViewerModal />
      <NotificationsModal />

    </div>
  );
};

export const ProfileTab: React.FC<ProfileTabProps> = ({
  coinBalance = 250,
  onOpenStore,
  onOpenWheel,
  onOpenMatches,
  onBack,
}) => {
  return (
    <ProfileInnerContent
      onOpenStore={onOpenStore}
      onOpenWheel={onOpenWheel}
      onOpenMatches={onOpenMatches}
      onBack={onBack}
    />
  );
};

export default ProfileTab;
