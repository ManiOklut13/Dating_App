import React, { useState } from 'react';
import { BottomNav } from './components/BottomNav';
import { CoinStoreModal } from './components/CoinStoreModal';
import { SpinWheelModal } from './components/SpinWheelModal';
import { MatchModal } from './components/MatchModal';

import { DiscoveryTab } from './pages/DiscoveryTab';
import { ConnectTab } from './pages/ConnectTab';
import { ChatTab } from './pages/ChatTab';

import { ProfileTab } from './pages/ProfileTab';
import { CandidateCard } from './types';

import { ProfileProvider } from './modules/profile/ProfileContext';
import { SettingsMenu } from './modules/profile/components/SettingsMenu';
import { SettingsModals } from './modules/profile/components/SettingsModals';
import { AccountModals } from './modules/profile/components/AccountModals';
import { SettingsProvider } from './modules/settings/SettingsContext';
import { SettingsRouter } from './modules/settings/SettingsRouter';
import { CallsProvider } from './modules/calls/CallsContext';
import { CallsRouter } from './modules/calls/CallsRouter';
import { ChatProvider } from './modules/chat/ChatContext';
import { CallModals } from './modules/chat/CallModals';
import { PresenceProvider } from './modules/presence/PresenceContext';

const AppShell: React.FC = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const [coinBalance, setCoinBalance] = useState(250);
  const [streakDays, setStreakDays] = useState(4);

  // Modals
  const [isStoreOpen, setIsStoreOpen] = useState(false);
  const [isWheelOpen, setIsWheelOpen] = useState(false);
  const [isMatchOpen, setIsMatchOpen] = useState(false);
  const [matchedProfile, setMatchedProfile] = useState<CandidateCard | null>(null);

  // Deep Link States
  const [selectedConvId, setSelectedConvId] = useState<string | undefined>(undefined);
  const [directCallTarget, setDirectCallTarget] = useState<{ calleeId: string; name: string; avatar: string } | null>(null);

  // True while a full-screen conversation is open inside the Chats tab. Used on
  // mobile to hide the bottom navigation and give the chat the whole viewport.
  const [isConversationOpen, setIsConversationOpen] = useState(false);

  const handleMutualMatch = (profile: CandidateCard) => {
    setMatchedProfile(profile);
    setIsMatchOpen(true);
  };

  const handleOpenChatFromMatch = () => {
    setIsMatchOpen(false);
    setSelectedConvId('conv-ananya-1');
    setActiveTab('chat');
  };

  const handleOpenCallFromMatch = () => {
    setIsMatchOpen(false);
  };

  return (
    <div className={`app-shell${activeTab === 'chat' && isConversationOpen ? ' app-shell--immersive' : ''}`}>

      {/* Main Tab View Container */}
      <main className={`app-main${activeTab === 'chat' ? ' app-main--fixed' : ''}`}>
        {activeTab === 'discovery' && (
          <DiscoveryTab
            onMutualMatch={handleMutualMatch}
            onCoinDeducted={(newBal) => setCoinBalance(newBal)}
          />
        )}

        {activeTab === 'connect' && (
          <ConnectTab
            onOpenChat={(convId) => {
              setSelectedConvId(convId);
              setActiveTab('chat');
            }}
            onOpenCall={handleOpenCallFromMatch}
            onOpenStore={() => setIsStoreOpen(true)}
          />
        )}

        {activeTab === 'chat' && (
          <ChatTab
            selectedConvId={selectedConvId}
            onStartCall={handleOpenCallFromMatch}
            onOpenCalls={() => setActiveTab('chat')}
            onConversationOpenChange={setIsConversationOpen}
          />
        )}


        {activeTab === 'profile' && (
          <ProfileTab
            coinBalance={coinBalance}
            onOpenStore={() => setIsStoreOpen(true)}
            onOpenWheel={() => setIsWheelOpen(true)}
            onOpenMatches={() => setActiveTab('connect')}
            onBack={() => setActiveTab('discovery')}
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

      {/* Instagram-style Settings & Activity pages (hash-routed, browser back works) */}
      <SettingsRouter />

      {/* Calls pages: #/calls -> /calls/audio | /calls/video -> /calls/:type/:callId.
          Rendered as an overlay so the Chat tab underneath keeps its state.
          A scoped ChatProvider + CallModals makes "Start call" in the call logs
          launch the same simulated audio/video overlay screens as the chat. */}
      <ChatProvider>
        <CallsRouter />
        <CallModals />
      </ChatProvider>

      {/* Global 3-Dot quick menu + its settings screens (frontend only) */}
      <SettingsMenu />
      <SettingsModals />
      <AccountModals />

      {/* Fixed Bottom Navigation Bar */}
      <BottomNav
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        unreadCount={4}
      />

    </div>
  );
};

export const App: React.FC = () => (
  <ProfileProvider>
    <SettingsProvider>
      {/* Presence sits above Calls and Chat so every presence indicator reads
          from one WebSocket-backed source of truth. */}
      <PresenceProvider>
        <CallsProvider>
          <AppShell />
        </CallsProvider>
      </PresenceProvider>
    </SettingsProvider>
  </ProfileProvider>
);
export default App;
