import React, { useEffect, useState } from 'react';
import { ChatProvider, useChat } from '../modules/chat/ChatContext';
import { ChatsPage } from '../modules/chat/ChatsPage';
import { ChatRoom } from '../modules/chat/ChatRoom';
import { ChatDetailsScreen } from '../modules/chat/ChatDetailsScreen';
import { CallModals } from '../modules/chat/CallModals';
import { CallHistoryModal } from '../modules/chat/CallHistoryModal';
import { ChatSettingsModal } from '../modules/chat/ChatSettingsModal';
import { DatePlannerModal } from '../modules/chat/DatePlannerModal';
import { UserProfileModal } from '../modules/chat/UserProfileModal';
import { ReportBlockModal } from '../modules/chat/ReportBlockModal';
import { SafetyModals } from '../modules/chat/SafetyModals';

interface ChatTabProps {
  selectedConvId?: string;
  onStartCall: (calleeId: string, name: string, avatar: string) => void;
  onOpenCalls?: () => void;
  /** Notifies the shell whether a full-screen conversation is currently open. */
  onConversationOpenChange?: (open: boolean) => void;
}

const ChatMainContent: React.FC<{
  initialConvId?: string;
  onOpenCalls?: () => void;
  onConversationOpenChange?: (open: boolean) => void;
}> = ({ initialConvId, onOpenCalls, onConversationOpenChange }) => {
  const {
    selectedConvId,
    setSelectedConvId,
    activeConversation,
    activeMessages,
  } = useChat();

  /** Whether the Chat Details screen is open on top of the conversation */
  const [isDetailsOpen, setIsDetailsOpen] = useState(false);

  // If a deep link / external prop passed selectedConvId, select it
  useEffect(() => {
    if (initialConvId) {
      setSelectedConvId(initialConvId);
    }
  }, [initialConvId, setSelectedConvId]);

  // Close details when conversation changes
  useEffect(() => {
    setIsDetailsOpen(false);
  }, [selectedConvId]);

  // Report open/closed conversation so the app shell can toggle the mobile
  // "full-screen chat" mode (hides the bottom navigation).
  useEffect(() => {
    onConversationOpenChange?.(!!selectedConvId);
  }, [selectedConvId, onConversationOpenChange]);

  useEffect(() => {
    return () => {
      onConversationOpenChange?.(false);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div
      className="chat-tab-shell"
      style={{
        width: '100%',
        height: '100%',
        minHeight: 0,
      }}
    >
      {/* Single full-screen pane: the conversation list OR the open conversation. */}
      <div
        className="chat-panel"
        style={{
          height: '100%',
          overflow: 'hidden',
          display: 'flex',
        }}
      >
        {/* Conversation List (hidden while a conversation is open) */}
        <div
          className={`chat-list-column${selectedConvId && activeConversation ? ' chat-list-hidden' : ''}`}
          style={{
            height: '100%',
            minHeight: 0,
          }}
        >
          <ChatsPage onSelectConversation={(id) => setSelectedConvId(id)} onOpenCalls={onOpenCalls} />
        </div>

        {/* Open Conversation (replaces the list, fills the screen) */}
        {selectedConvId && activeConversation && (
          <div
            className="chat-room-column"
            style={{
              flex: 1,
              height: '100%',
              minWidth: 0,
              minHeight: 0,
              position: 'relative',
            }}
          >
            {/* Chat Details Screen (slides over the ChatRoom) */}
            {isDetailsOpen ? (
              <ChatDetailsScreen
                conversation={activeConversation}
                messages={activeMessages}
                onBack={() => setIsDetailsOpen(false)}
              />
            ) : (
              <ChatRoom
                conversation={activeConversation}
                onBack={() => setSelectedConvId(null)}
                onOpenDetails={() => setIsDetailsOpen(true)}
              />
            )}
          </div>
        )}
      </div>

      {/* Global Interactive Modals for Chat */}
      <CallModals />
      <CallHistoryModal />
      <ChatSettingsModal />
      <DatePlannerModal />
      <UserProfileModal />
      <ReportBlockModal />
      <SafetyModals />
    </div>
  );
};

export const ChatTab: React.FC<ChatTabProps> = ({ selectedConvId, onStartCall, onOpenCalls, onConversationOpenChange }) => {
  return (
    <ChatProvider initialConvId={selectedConvId} onCallRequested={onStartCall}>
      <ChatMainContent
        initialConvId={selectedConvId}
        onOpenCalls={onOpenCalls}
        onConversationOpenChange={onConversationOpenChange}
      />
    </ChatProvider>
  );
};

export default ChatTab;
