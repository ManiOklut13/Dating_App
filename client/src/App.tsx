import React, { useState } from 'react';
import { Gem } from 'lucide-react';
import { TopNav } from './components/TopNav';
import { BottomNav } from './components/BottomNav';
import { StreakTrackerModal } from './components/StreakTrackerModal';
import { MatchModal } from './components/MatchModal';
import { CoinStoreModal } from './components/CoinStoreModal';
import { SpinWheelModal } from './components/SpinWheelModal';

import { DiscoveryTab } from './pages/DiscoveryTab';
import { ConnectTab } from './pages/ConnectTab';
import { ChatTab } from './pages/ChatTab';
import { CallsTab } from './pages/CallsTab';
import { ProfileWalletTab } from './pages/ProfileWalletTab';
import { SplashLandingPage } from './pages/SplashLandingPage';
import { SignInPage, LoginPayload } from './pages/SignInPage';
import { OnboardingWizardPage, OnboardingProfileData } from './pages/OnboardingWizardPage';
import { NotificationsPage } from './pages/NotificationsPage';
import { DatePlanPage } from './pages/DatePlanPage';
import { RubiesPage } from './pages/RubiesPage';
import { CandidateCard, ScheduledDate } from './types';

/** Scheduled date with is_date === true driving the conditional calendar reminder */
const DEMO_SCHEDULED_DATE: ScheduledDate = {
  id: 'sd_1',
  with_user_id: '22222222-2222-2222-2222-222222222222',
  nickname: 'Ananya',
  avatar: '/ananya.jpg',
  venue: 'Olive Bistro, Jubilee Hills',
  address: 'Road No. 46, Jubilee Hills, Hyderabad, Telangana 500033',
  city: 'Hyderabad',
  scheduled_at: new Date(Date.now() + 1000 * 60 * 60 * 72).toISOString(),
  duration_mins: 120,
  is_date: true,
  activity_type: 'Specialty Coffee Tasting & Vinyl Browsing ☕🎵',
  dress_code: 'Smart Casual / Indie Chic 👗',
  table_reservation: 'Corner Vinyl Lounge (Reserved under "YoUnMe")',
  romantic_milestone: '7-Day Connection Streak 🔥 • 98% Compatibility Vibe',
  shared_playlist: 'Acoustic Sunset Romance • 18 Songs Curated for Two',
  vibe_notes: 'Subko has cozy candlelit booths, artisan sourdough croissants, and an eclectic vinyl selection. Perfect quiet ambiance to chat and unwind together.',
  status: 'confirmed',
};

type AuthScreen = 'splash' | 'signin' | 'onboarding';

export const App: React.FC = () => {
  // Authentication & Onboarding state
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authScreen, setAuthScreen] = useState<AuthScreen>('splash');
  const [isStreakModalOpen, setIsStreakModalOpen] = useState(false);

  // Main App Navigation
  const [activeTab, setActiveTab] = useState('discovery');
  const [coinBalance, setCoinBalance] = useState(250);
  const [streakDays, setStreakDays] = useState(4);
  const [initialDraftText, setInitialDraftText] = useState<string | undefined>(undefined);

  // Modals
  const [isStoreOpen, setIsStoreOpen] = useState(false);
  const [isWheelOpen, setIsWheelOpen] = useState(false);
  const [isMatchOpen, setIsMatchOpen] = useState(false);
  const [matchedProfile, setMatchedProfile] = useState<CandidateCard | null>(null);

  // Deep Link States
  const [selectedConvId, setSelectedConvId] = useState<string | undefined>(undefined);
  const [directCallTarget, setDirectCallTarget] = useState<{ calleeId: string; name: string; avatar: string; mode?: 'audio' | 'video' } | null>(null);

  // MODULE 6 Item 1: Daily Login Ruby Boost State & Hook
  const [dailyRubyBoostToast, setDailyRubyBoostToast] = useState<{ amount: number; message: string } | null>(null);

  const triggerDailyLoginRubyBoost = () => {
    const todayStr = new Date().toISOString().split('T')[0];
    const lastClaim = localStorage.getItem('younme_last_ruby_boost');
    if (lastClaim !== todayStr) {
      const boostAmount = 50; // Daily Login Rubies
      setCoinBalance((prev) => prev + boostAmount);
      localStorage.setItem('younme_last_ruby_boost', todayStr);
      setDailyRubyBoostToast({
        amount: boostAmount,
        message: `Daily Login Ruby Boost: +${boostAmount} Rubies credited to your wallet! 💎`,
      });
      setTimeout(() => {
        setDailyRubyBoostToast(null);
      }, 3500);
    }
  };

  // Login handler -> direct transition into Discovery with login streak check
  const handleLogin = (_payload: LoginPayload) => {
    setIsAuthenticated(true);
    setActiveTab('discovery');
    triggerDailyLoginRubyBoost();
    setTimeout(() => {
      setIsStreakModalOpen(true);
    }, 600);
  };

  const handleOnboardingComplete = (_profileData: OnboardingProfileData) => {
    setIsAuthenticated(true);
    setActiveTab('discovery');
    triggerDailyLoginRubyBoost();
    setTimeout(() => {
      setIsStreakModalOpen(true);
    }, 600);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setAuthScreen('splash');
    setIsStreakModalOpen(false);
  };

  const handleTestOnboarding = () => {
    setIsAuthenticated(false);
    setAuthScreen('onboarding');
  };

  const handleMutualMatch = (profile: CandidateCard) => {
    setMatchedProfile(profile);
    setIsMatchOpen(true);
  };

  const handleOpenChatFromMatch = () => {
    setIsMatchOpen(false);
    setSelectedConvId('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    setActiveTab('chat');
  };

  const handleOpenCallFromMatch = (
    calleeId = '22222222-2222-2222-2222-222222222222',
    name = 'Ananya',
    avatar = '/ananya.jpg',
    mode: 'audio' | 'video' = 'audio'
  ) => {
    setIsMatchOpen(false);
    setDirectCallTarget({ calleeId, name, avatar, mode });
    setActiveTab('calls');
  };

  // -------------------------------------------------------------
  // 1. UNAUTHENTICATED STATE: Splash, Sign In, or Onboarding Wizard
  // -------------------------------------------------------------
  if (!isAuthenticated) {
    return (
      <div className="phone-frame-wrap">
        <div className="phone-frame">
          <div className="phone-screen flex flex-col justify-between h-full bg-[#111318]">
            <div className="flex-1 overflow-y-auto min-h-0 relative">
              {authScreen === 'splash' && (
                <SplashLandingPage
                  onGoToSignUp={() => setAuthScreen('onboarding')}
                  onGoToSignIn={() => setAuthScreen('signin')}
                />
              )}

              {authScreen === 'signin' && (
                <SignInPage
                  onBack={() => setAuthScreen('splash')}
                  onLogin={handleLogin}
                  onGoToSignUp={() => setAuthScreen('onboarding')}
                />
              )}

              {authScreen === 'onboarding' && (
                <OnboardingWizardPage
                  onBack={() => setAuthScreen('splash')}
                  onComplete={handleOnboardingComplete}
                  onGoToSignIn={() => setAuthScreen('signin')}
                />
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }

  const isSubPage = activeTab === 'datePlan' || activeTab === 'notifications' || activeTab === 'rubies';

  // -------------------------------------------------------------
  // 2. AUTHENTICATED STATE: Centered Realistic Mobile Container
  // -------------------------------------------------------------
  return (
    <div className="phone-frame-wrap">
      <div className="phone-frame">
        <div className="phone-screen">
          {/* Top Application Header (Hidden on focused subpages) */}
          {!isSubPage && (
            <TopNav
              rubyBalance={coinBalance}
              streakDays={streakDays}
              onOpenRubies={() => setActiveTab('rubies')}
              onOpenStreak={() => setIsStreakModalOpen(true)}
              onOpenNotifications={() => setActiveTab('notifications')}
              onLogoClick={() => setActiveTab('discovery')}
            />
          )}

          {/* MODULE 6 Item 1: Instant Visual Ruby Reward Banner Toast */}
          {dailyRubyBoostToast && (
            <div
              style={{
                position: 'absolute',
                top: '56px',
                left: '14px',
                right: '14px',
                zIndex: 150,
                background: 'linear-gradient(135deg, rgba(244, 63, 94, 0.96), rgba(225, 29, 72, 0.96))',
                border: '1.5px solid #ffd700',
                borderRadius: '16px',
                padding: '10px 14px',
                color: '#ffffff',
                boxShadow: '0 8px 24px rgba(244, 63, 94, 0.5), 0 0 16px rgba(255, 215, 0, 0.4)',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
              }}
            >
              <div
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '10px',
                  background: 'rgba(255, 255, 255, 0.2)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                <Gem size={18} color="#ffd700" />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: '13px', fontWeight: 800 }}>
                  Daily Login Boost Unlocked!
                </div>
                <div style={{ fontSize: '11px', color: '#ffe4e8', marginTop: '1px' }}>
                  +{dailyRubyBoostToast.amount} Rubies credited directly to your wallet.
                </div>
              </div>
            </div>
          )}

          {/* Main Active Tab Content View Container */}
          <main style={{ flex: 1, minHeight: 0, overflowY: 'auto', position: 'relative' }}>
            {activeTab === 'discovery' && (
              <DiscoveryTab
                onMutualMatch={handleMutualMatch}
                onCoinDeducted={(newBal) => setCoinBalance(newBal)}
                coinBalance={coinBalance}
                streakDays={streakDays}
                onOpenStore={() => setActiveTab('rubies')}
                onOpenWheel={() => setIsWheelOpen(true)}
                onOpenChat={(convId) => {
                  setSelectedConvId(convId);
                  setActiveTab('chat');
                }}
                onStartCall={(calleeId, name, avatar, mode) => {
                  handleOpenCallFromMatch(calleeId, name, avatar, mode);
                }}
                onOpenDatePlan={() => {
                  setActiveTab('datePlan');
                }}
                onGoToRandomCall={() => {
                  setActiveTab('connect');
                }}
                scheduledDate={DEMO_SCHEDULED_DATE}
              />
            )}

            {activeTab === 'rubies' && (
              <RubiesPage
                rubyBalance={coinBalance}
                onUpdateBalance={(newBal) => setCoinBalance(newBal)}
                onBack={() => setActiveTab('discovery')}
              />
            )}

            {activeTab === 'datePlan' && (
              <DatePlanPage
                datePlan={DEMO_SCHEDULED_DATE}
                onBack={() => setActiveTab('discovery')}
                onStartCall={(calleeId, name, avatar, mode) => {
                  handleOpenCallFromMatch(calleeId, name, avatar, mode || 'audio');
                }}
                onOpenChat={(convId) => {
                  setSelectedConvId(convId || 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
                  setActiveTab('chat');
                }}
              />
            )}

            {activeTab === 'notifications' && (
              <NotificationsPage
                onBack={() => setActiveTab('discovery')}
                onOpenStore={() => setActiveTab('rubies')}
                onOpenChat={(convId) => {
                  setSelectedConvId(convId);
                  setActiveTab('chat');
                }}
              />
            )}

            {activeTab === 'connect' && (
              <ConnectTab
                onOpenChat={(convId, initialText) => {
                  setSelectedConvId(convId);
                  setInitialDraftText(initialText);
                  setActiveTab('chat');
                }}
                onStartCall={(calleeId, name, avatar, mode) => {
                  handleOpenCallFromMatch(calleeId, name, avatar, mode || 'audio');
                }}
                onOpenStore={() => setActiveTab('rubies')}
                onMutualMatch={handleMutualMatch}
                coinBalance={coinBalance}
                onCoinsDeducted={(newBal) => setCoinBalance(newBal)}
                viewerGender="male"
              />
            )}

            {activeTab === 'chat' && (
              <ChatTab
                selectedConvId={selectedConvId}
                initialDraft={initialDraftText}
                onStartCall={handleOpenCallFromMatch}
                onOpenChat={(convId) => {
                  setSelectedConvId(convId);
                  setActiveTab('chat');
                }}
                onBack={() => setSelectedConvId(undefined)}
                onOpenStore={() => setActiveTab('rubies')}
                onGoToConnect={() => setActiveTab('connect')}
              />
            )}

            {activeTab === 'calls' && (
              <CallsTab
                currentBalance={coinBalance}
                onCoinsDeducted={(newBal) => setCoinBalance(newBal)}
                directCallTarget={directCallTarget}
                onClose={() => {
                  setDirectCallTarget(null);
                  setActiveTab('discovery');
                }}
              />
            )}

            {activeTab === 'profile' && (
              <ProfileWalletTab
                coinBalance={coinBalance}
                onOpenStore={() => setActiveTab('rubies')}
                onOpenWheel={() => setIsWheelOpen(true)}
                view="profile"
                onLogout={handleLogout}
                onTestOnboarding={handleTestOnboarding}
              />
            )}
          </main>

          {/* Interactive Modals */}
          <CoinStoreModal
            isOpen={isStoreOpen}
            onClose={() => setIsStoreOpen(false)}
            currentBalance={coinBalance}
            onCoinsUpdated={(newBal) => setCoinBalance(newBal)}
          />

          <SpinWheelModal
            isOpen={isWheelOpen}
            onClose={() => setIsWheelOpen(false)}
            streakDays={streakDays}
            onCoinsAwarded={(newBal) => {
              setCoinBalance(newBal);
              setStreakDays((prev) => prev + 1);
            }}
          />

          <MatchModal
            isOpen={isMatchOpen}
            onClose={() => setIsMatchOpen(false)}
            matchedProfile={matchedProfile}
            onStartChat={handleOpenChatFromMatch}
            onStartCall={() => handleOpenCallFromMatch()}
          />

          <StreakTrackerModal
            isOpen={isStreakModalOpen}
            onClose={() => setIsStreakModalOpen(false)}
            streakDays={streakDays}
            rubyBalance={coinBalance}
            onCoinsAwarded={(newBal) => setCoinBalance(newBal)}
          />

          {/* Mobile Fixed Bottom Navigation Dock (Strictly 4 tabs, no Android system bar) */}
          {!isSubPage && (
            <BottomNav activeTab={activeTab} setActiveTab={setActiveTab} />
          )}
        </div>
      </div>
    </div>
  );
};

export default App;
