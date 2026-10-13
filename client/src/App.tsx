import React, { useState } from 'react';
import { BottomNav } from './components/BottomNav';
import { CoinStoreModal } from './components/CoinStoreModal';
import { SpinWheelModal } from './components/SpinWheelModal';
import { MatchModal } from './components/MatchModal';

import { DiscoveryTab } from './pages/DiscoveryTab';
import { ConnectTab } from './pages/ConnectTab';
import { ChatTab } from './pages/ChatTab';
import { CallsTab } from './pages/CallsTab';
import { ProfileWalletTab } from './pages/ProfileWalletTab';
import { CandidateCard } from './types';

export const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState('discovery');
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

  const handleMutualMatch = (profile: CandidateCard) => {
    setMatchedProfile(profile);
    setIsMatchOpen(true);
  };

  const handleOpenChatFromMatch = () => {
    setIsMatchOpen(false);
    setSelectedConvId('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    setActiveTab('chat');
  };

  const handleOpenCallFromMatch = (calleeId = '22222222-2222-2222-2222-222222222222', name = 'Ananya', avatar = '/ananya.jpg') => {
    setIsMatchOpen(false);
    setDirectCallTarget({ calleeId, name, avatar });
    setActiveTab('calls');
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', minWidth: 0, overflowX: 'hidden' }}>
      
      {/* Main Tab View Container */}
      <main style={{ flex: 1, paddingBottom: '70px', minWidth: 0 }}>
        {activeTab === 'discovery' && (
          <DiscoveryTab
            onMutualMatch={handleMutualMatch}
            onCoinDeducted={(newBal) => setCoinBalance(newBal)}
            coinBalance={coinBalance}
            streakDays={streakDays}
            onOpenStore={() => setIsStoreOpen(true)}
            onOpenWheel={() => setIsWheelOpen(true)}
            onOpenChat={(convId) => {
              setSelectedConvId(convId);
              setActiveTab('chat');
            }}
          />
        )}

        {activeTab === 'connect' && (
          <ConnectTab
            onOpenChat={(convId) => {
              setSelectedConvId(convId);
              setActiveTab('chat');
            }}
            onOpenStore={() => setIsStoreOpen(true)}
            onMutualMatch={handleMutualMatch}
            coinBalance={coinBalance}
            onCoinsDeducted={(newBal) => setCoinBalance(newBal)}
            // TODO(auth): read the authenticated user's gender from the profile API.
            viewerGender="male"
          />
        )}

        {activeTab === 'chat' && (
          <ChatTab
            selectedConvId={selectedConvId}
            onStartCall={handleOpenCallFromMatch}
          />
        )}

        {activeTab === 'calls' && (
          <CallsTab
            currentBalance={coinBalance}
            onCoinsDeducted={(newBal) => setCoinBalance(newBal)}
            directCallTarget={directCallTarget}
          />
        )}

        {activeTab === 'profile' && (
          <ProfileWalletTab
            coinBalance={coinBalance}
            onOpenStore={() => setIsStoreOpen(true)}
            onOpenWheel={() => setIsWheelOpen(true)}
            view="profile"
          />
        )}

        {activeTab === 'ledger' && (
          <ProfileWalletTab
            coinBalance={coinBalance}
            onOpenStore={() => setIsStoreOpen(true)}
            onOpenWheel={() => setIsWheelOpen(true)}
            view="ledger"
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

      {/* Mobile Fixed Bottom Navigation */}
      <BottomNav activeTab={activeTab} setActiveTab={setActiveTab} />

    </div>
  );
};
export default App;
