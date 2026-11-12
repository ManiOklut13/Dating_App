import React, { createContext, useContext, useState, useMemo, useCallback } from 'react';
import {
  ChatConversation,
  ChatMessage,
  MessageRequest,
  SentRequest,
  CallRecord,
  ChatSettings,
  UserProfile,
} from './types';
import {
  INITIAL_CONVERSATIONS,
  INITIAL_MESSAGES_MAP,
  INITIAL_RECEIVED_REQUESTS,
  INITIAL_SENT_REQUESTS,
  INITIAL_CALL_HISTORY,
  INITIAL_CHAT_SETTINGS,
  PROHIBITED_WORDS,
} from './mockData';

interface ToastData {
  type: 'success' | 'warning' | 'info' | 'error';
  text: string;
  actionText?: string;
  onAction?: () => void;
}

interface ChatContextType {
  conversations: ChatConversation[];
  selectedConvId: string | null;
  setSelectedConvId: (id: string | null) => void;
  activeConversation: ChatConversation | null;
  activeMessages: ChatMessage[];
  activeTab: 'all' | 'requests' | 'sent';
  setActiveTab: (tab: 'all' | 'requests' | 'sent') => void;
  filter: 'all' | 'unread' | 'online' | 'verified';
  setFilter: (f: 'all' | 'unread' | 'online' | 'verified') => void;
  searchQuery: string;
  setSearchQuery: (q: string) => void;
  filteredConversations: ChatConversation[];
  totalUnreadCount: number;
  receivedRequests: MessageRequest[];
  sentRequests: SentRequest[];
  callHistory: CallRecord[];
  settings: ChatSettings;
  updateSettings: (partial: Partial<ChatSettings>) => void;

  // Actions
  sendMessage: (
    convId: string,
    messageData: Partial<ChatMessage>
  ) => { success: boolean; reason?: string; detail?: string };
  markAsRead: (convId: string) => void;
  acceptRequest: (requestId: string) => void;
  declineRequest: (requestId: string) => void;
  cancelSentRequest: (requestId: string) => void;
  reportUser: (user: UserProfile, reason: string, requestId?: string) => void;
  blockUser: (user: UserProfile, requestId?: string) => void;
  unblockUser: (userId: string) => void;
  unrestrictUser: (userId: string) => void;
  togglePinChat: (convId: string) => void;
  toggleMuteChat: (convId: string) => void;
  setChatWallpaper: (convId: string, wallpaperId: string) => void;
  setDisappearingMode: (convId: string, mode: 'off' | '60s' | '24h' | '7d') => void;
  clearChatHistory: (convId: string) => void;
  respondToDateInvite: (convId: string, messageId: string, accept: boolean) => void;

  // Modals & Sheets
  audioCallTarget: ChatConversation | null;
  setAudioCallTarget: (c: ChatConversation | null) => void;
  videoCallTarget: ChatConversation | null;
  setVideoCallTarget: (c: ChatConversation | null) => void;
  callHistoryType: 'audio' | 'video' | null;
  setCallHistoryType: (type: 'audio' | 'video' | null) => void;
  isSettingsOpen: boolean;
  setIsSettingsOpen: (open: boolean) => void;
  datePlannerConv: ChatConversation | null;
  setDatePlannerConv: (c: ChatConversation | null) => void;
  icebreakerConv: ChatConversation | null;
  setIcebreakerConv: (c: ChatConversation | null) => void;
  profilePreviewUser: UserProfile | null;
  setProfilePreviewUser: (u: UserProfile | null) => void;
  reportTarget: { user: UserProfile; requestId?: string } | null;
  setReportTarget: (target: { user: UserProfile; requestId?: string } | null) => void;
  blockTarget: { user: UserProfile; requestId?: string } | null;
  setBlockTarget: (target: { user: UserProfile; requestId?: string } | null) => void;
  isScreenshotModalOpen: boolean;
  setIsScreenshotModalOpen: (open: boolean) => void;
  profanityAlert: { word: string; text: string } | null;
  setProfanityAlert: (alert: { word: string; text: string } | null) => void;

  // Feedback Toast
  toast: ToastData | null;
  showToast: (toast: ToastData) => void;
  clearToast: () => void;
}

const ChatContext = createContext<ChatContextType | undefined>(undefined);

// Regular expressions for Link & Social & Contact detection
const LINK_REGEX = /(https?:\/\/|www\.|\.com|\.org|\.net|\.in|\.co|\.io|\.me|\.app)/i;
const PHONE_REGEX = /(\+?\d{1,4}[-.\s]?)?\(?\d{3,5}\)?[-.\s]?\d{3,5}[-.\s]?\d{3,5}/;
const SOCIAL_REGEX = /(wa\.me|whatsapp|insta(?:gram)?|ig\s*:\s*|snap(?:chat)?|t\.me|telegram|dm\s*me\s*at|call\s*me\s*at|@[\w.-]+)/i;

export const ChatProvider: React.FC<{
  children: React.ReactNode;
  initialConvId?: string;
  onCallRequested?: (calleeId: string, name: string, avatar: string) => void;
}> = ({ children, initialConvId }) => {
  const [conversations, setConversations] = useState<ChatConversation[]>(INITIAL_CONVERSATIONS);
  const [messagesMap, setMessagesMap] = useState<Record<string, ChatMessage[]>>(INITIAL_MESSAGES_MAP);
  const [selectedConvId, setSelectedConvIdState] = useState<string | null>(initialConvId || null);
  const [activeTab, setActiveTab] = useState<'all' | 'requests' | 'sent'>('all');
  const [filter, setFilter] = useState<'all' | 'unread' | 'online' | 'verified'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  const [receivedRequests, setReceivedRequests] = useState<MessageRequest[]>(INITIAL_RECEIVED_REQUESTS);
  const [sentRequests, setSentRequests] = useState<SentRequest[]>(INITIAL_SENT_REQUESTS);
  const [callHistory, setCallHistory] = useState<CallRecord[]>(INITIAL_CALL_HISTORY);
  const [settings, setSettings] = useState<ChatSettings>(INITIAL_CHAT_SETTINGS);

  // Modals state
  const [audioCallTarget, setAudioCallTarget] = useState<ChatConversation | null>(null);
  const [videoCallTarget, setVideoCallTarget] = useState<ChatConversation | null>(null);
  const [callHistoryType, setCallHistoryType] = useState<'audio' | 'video' | null>(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [datePlannerConv, setDatePlannerConv] = useState<ChatConversation | null>(null);
  const [icebreakerConv, setIcebreakerConv] = useState<ChatConversation | null>(null);
  const [profilePreviewUser, setProfilePreviewUser] = useState<UserProfile | null>(null);
  const [reportTarget, setReportTarget] = useState<{ user: UserProfile; requestId?: string } | null>(null);
  const [blockTarget, setBlockTarget] = useState<{ user: UserProfile; requestId?: string } | null>(null);
  const [isScreenshotModalOpen, setIsScreenshotModalOpen] = useState(false);
  const [profanityAlert, setProfanityAlert] = useState<{ word: string; text: string } | null>(null);

  // Toast
  const [toast, setToast] = useState<ToastData | null>(null);

  const showToast = useCallback((t: ToastData) => {
    setToast(t);
    setTimeout(() => {
      setToast((cur) => (cur?.text === t.text ? null : cur));
    }, 4500);
  }, []);

  const clearToast = useCallback(() => setToast(null), []);

  const setSelectedConvId = useCallback((id: string | null) => {
    setSelectedConvIdState(id);
    if (id) {
      // Mark as read
      setConversations((prev) =>
        prev.map((c) => (c.id === id ? { ...c, unread_count: 0 } : c))
      );
    }
  }, []);

  const markAsRead = useCallback((convId: string) => {
    setConversations((prev) =>
      prev.map((c) => (c.id === convId ? { ...c, unread_count: 0 } : c))
    );
  }, []);

  // Update Settings
  const updateSettings = useCallback((partial: Partial<ChatSettings>) => {
    setSettings((prev) => ({ ...prev, ...partial }));
    showToast({ type: 'success', text: 'Chat settings updated successfully' });
  }, [showToast]);

  // Total Unread Count for badges
  const totalUnreadCount = useMemo(() => {
    const chatUnread = conversations.reduce((acc, c) => acc + (c.unread_count > 0 ? 1 : 0), 0);
    const requestsUnread = receivedRequests.length;
    return chatUnread + requestsUnread;
  }, [conversations, receivedRequests]);

  // Active Conversation and Messages
  const activeConversation = useMemo(() => {
    if (!selectedConvId) return null;
    return conversations.find((c) => c.id === selectedConvId) || null;
  }, [conversations, selectedConvId]);

  const activeMessages = useMemo(() => {
    if (!selectedConvId) return [];
    return messagesMap[selectedConvId] || [];
  }, [messagesMap, selectedConvId]);

  // Filtered & Sorted Conversations
  const filteredConversations = useMemo(() => {
    return conversations
      .filter((c) => {
        // Search query
        if (searchQuery.trim()) {
          const q = searchQuery.toLowerCase();
          const matchesName = c.counterpart.nickname.toLowerCase().includes(q);
          const matchesBio = c.counterpart.bio.toLowerCase().includes(q);
          const matchesLast = c.last_message?.body.toLowerCase().includes(q);
          if (!matchesName && !matchesBio && !matchesLast) return false;
        }

        // Pill filters
        if (filter === 'unread') return c.unread_count > 0;
        if (filter === 'online') return c.counterpart.is_online;
        if (filter === 'verified') return c.counterpart.is_verified;

        return true;
      })
      .sort((a, b) => {
        // Pinned first
        if (a.is_pinned && !b.is_pinned) return -1;
        if (!a.is_pinned && b.is_pinned) return 1;

        // Sort by timestamp
        const timeA = new Date(a.last_message?.created_at || 0).getTime();
        const timeB = new Date(b.last_message?.created_at || 0).getTime();
        return timeB - timeA;
      });
  }, [conversations, searchQuery, filter]);

  // Send Message with Safety Guard Detection
  const sendMessage = useCallback(
    (convId: string, messageData: Partial<ChatMessage>) => {
      const text = messageData.body || '';

      // 1. Profanity Detection
      const lower = text.toLowerCase();
      const matchedProfanity = PROHIBITED_WORDS.find((w) => {
        const regex = new RegExp(`\\b${w}\\b`, 'i');
        return regex.test(lower);
      });
      if (matchedProfanity) {
        setProfanityAlert({ word: matchedProfanity, text });
        return {
          success: false,
          reason: 'profanity',
          detail: `Prohibited term "${matchedProfanity}" detected`,
        };
      }

      // 2. Link & Phone & Social Detection (only check if text message)
      if (messageData.type === 'text' || !messageData.type) {
        const hasLink = LINK_REGEX.test(text);
        const hasPhone = PHONE_REGEX.test(text.replace(/\s+/g, '')) && /\d{8,}/.test(text.replace(/\D/g, ''));
        const hasSocial = SOCIAL_REGEX.test(text);

        if (hasLink || hasPhone || hasSocial) {
          const detectedType = hasPhone
            ? 'Phone number'
            : hasLink
            ? 'External link'
            : 'Social media handle';
          showToast({
            type: 'warning',
            text: `⚠️ Link or contact sharing is restricted (${detectedType}).`,
            actionText: 'Keep Editing',
          });
          return {
            success: false,
            reason: 'link_restricted',
            detail: detectedType,
          };
        }
      }

      // 3. Create clean message
      const targetConv = conversations.find((c) => c.id === convId);
      const isVanish = targetConv?.disappearing_mode === '60s';

      const newMsg: ChatMessage = {
        id: `msg-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
        conv_id: convId,
        sender_id: 'me',
        type: messageData.type || 'text',
        body: text,
        media_url: messageData.media_url,
        audio_duration: messageData.audio_duration,
        icebreaker_prompt: messageData.icebreaker_prompt,
        date_invite: messageData.date_invite,
        sticker_id: messageData.sticker_id,
        status: 'sent',
        vanish_seconds: isVanish ? 60 : null,
        created_at: new Date().toISOString(),
      };

      // Append to messagesMap
      setMessagesMap((prev) => ({
        ...prev,
        [convId]: [...(prev[convId] || []), newMsg],
      }));

      // Update conversation last_message
      setConversations((prev) =>
        prev.map((c) =>
          c.id === convId
            ? {
                ...c,
                last_message: newMsg,
              }
            : c
        )
      );

      // Simulate counterpart reply after 1.8 seconds (if applicable)
      if (targetConv && messageData.type !== 'date_invite') {
        const partnerName = targetConv.counterpart.nickname.split(' ')[0];
        const replies = [
          `That sounds amazing! Subko coffee and conversations like this make my week ✨`,
          `Totally agree! We definitely share the exact same aesthetic vibe :)`,
          `Haha you have such a witty sense of humor! Tell me more about that 😊`,
          `That is so cool! Let us definitely make a plan for this weekend.`,
        ];

        setTimeout(() => {
          const replyMsg: ChatMessage = {
            id: `msg-reply-${Date.now()}`,
            conv_id: convId,
            sender_id: targetConv.counterpart.id,
            type: 'text',
            body: replies[Math.floor(Math.random() * replies.length)],
            status: 'read',
            created_at: new Date().toISOString(),
          };

          setMessagesMap((prevMap) => ({
            ...prevMap,
            [convId]: [...(prevMap[convId] || []), replyMsg],
          }));

          setConversations((prevList) =>
            prevList.map((c) =>
              c.id === convId
                ? {
                    ...c,
                    last_message: replyMsg,
                  }
                : c
            )
          );
        }, 1800);
      }

      return { success: true };
    },
    [conversations, showToast]
  );

  // Accept Request -> moves to All Chats
  const acceptRequest = useCallback(
    (requestId: string) => {
      const req = receivedRequests.find((r) => r.id === requestId);
      if (!req) return;

      // Remove from received
      setReceivedRequests((prev) => prev.filter((r) => r.id !== requestId));

      const newConvId = `conv-new-${req.id}`;
      const firstMessage: ChatMessage = {
        id: `msg-first-${Date.now()}`,
        conv_id: newConvId,
        sender_id: req.user_id,
        type: 'text',
        body: req.message,
        status: 'read',
        created_at: new Date().toISOString(),
      };

      const newConversation: ChatConversation = {
        id: newConvId,
        counterpart: {
          id: req.user_id,
          nickname: req.nickname,
          avatar: req.avatar,
          age: req.age,
          city: req.city,
          occupation: req.occupation,
          bio: req.bio,
          interests: ['Travel', 'Art', 'Coffee'],
          is_verified: req.is_verified,
          is_online: true,
          vibe_score: req.vibe_score,
        },
        is_pinned: false,
        is_muted: false,
        is_locked: false,
        unread_count: 0,
        wallpaper: 'cyber-dark',
        disappearing_mode: 'off',
        last_message: firstMessage,
      };

      setConversations((prev) => [newConversation, ...prev]);
      setMessagesMap((prev) => ({
        ...prev,
        [newConvId]: [
          {
            id: `msg-system-${Date.now()}`,
            conv_id: newConvId,
            sender_id: 'system',
            type: 'match_system',
            body: `🎉 You connected with ${req.nickname}! Conversation unlocked.`,
            status: 'read',
            created_at: new Date(Date.now() - 1000).toISOString(),
          },
          firstMessage,
        ],
      }));

      // Switch to All Chats and open this conversation
      setActiveTab('all');
      setSelectedConvId(newConvId);
      showToast({
        type: 'success',
        text: `Connected with ${req.nickname}! Chat is now open.`,
      });
    },
    [receivedRequests, setSelectedConvId, showToast]
  );

  // Decline Request
  const declineRequest = useCallback(
    (requestId: string) => {
      const req = receivedRequests.find((r) => r.id === requestId);
      setReceivedRequests((prev) => prev.filter((r) => r.id !== requestId));
      showToast({
        type: 'info',
        text: `Declined message request from ${req?.nickname || 'user'}.`,
      });
    },
    [receivedRequests, showToast]
  );

  // Cancel Sent Request
  const cancelSentRequest = useCallback(
    (requestId: string) => {
      const req = sentRequests.find((r) => r.id === requestId);
      setSentRequests((prev) => prev.filter((r) => r.id !== requestId));
      showToast({
        type: 'info',
        text: `Cancelled outgoing request to ${req?.nickname || 'user'}.`,
      });
    },
    [sentRequests, showToast]
  );

  // Report User
  const reportUser = useCallback(
    (user: UserProfile, reason: string, requestId?: string) => {
      if (requestId) {
        setReceivedRequests((prev) => prev.filter((r) => r.id !== requestId));
      }
      showToast({
        type: 'success',
        text: `Report against ${user.nickname} submitted (${reason}). Thank you for keeping YoUnMe safe.`,
      });
      setReportTarget(null);
    },
    [showToast]
  );

  // Block User
  const blockUser = useCallback(
    (user: UserProfile, requestId?: string) => {
      // Add to settings.blocked_users
      setSettings((prev) => ({
        ...prev,
        blocked_users: [
          ...prev.blocked_users,
          {
            id: user.id,
            name: user.nickname,
            avatar: user.avatar,
            date: `Blocked on ${new Date().toLocaleDateString()}`,
          },
        ],
      }));

      // Remove from conversations & requests
      setConversations((prev) => prev.filter((c) => c.counterpart.id !== user.id));
      if (requestId) {
        setReceivedRequests((prev) => prev.filter((r) => r.id !== requestId));
      }
      if (selectedConvId && activeConversation?.counterpart.id === user.id) {
        setSelectedConvId(null);
      }

      showToast({
        type: 'warning',
        text: `${user.nickname} has been blocked and removed.`,
      });
      setBlockTarget(null);
    },
    [activeConversation, selectedConvId, setSelectedConvId, showToast]
  );

  // Unblock User
  const unblockUser = useCallback(
    (userId: string) => {
      setSettings((prev) => ({
        ...prev,
        blocked_users: prev.blocked_users.filter((u) => u.id !== userId),
      }));
      showToast({ type: 'success', text: 'User unblocked.' });
    },
    [showToast]
  );

  // Unrestrict User
  const unrestrictUser = useCallback(
    (userId: string) => {
      setSettings((prev) => ({
        ...prev,
        restricted_users: prev.restricted_users.filter((u) => u.id !== userId),
      }));
      showToast({ type: 'success', text: 'Restrictions lifted.' });
    },
    [showToast]
  );

  // Toggle Pin
  const togglePinChat = useCallback(
    (convId: string) => {
      setConversations((prev) =>
        prev.map((c) => {
          if (c.id === convId) {
            const nextPinned = !c.is_pinned;
            showToast({
              type: 'info',
              text: nextPinned ? 'Chat pinned to top 📌' : 'Chat unpinned',
            });
            return { ...c, is_pinned: nextPinned };
          }
          return c;
        })
      );
    },
    [showToast]
  );

  // Toggle Mute
  const toggleMuteChat = useCallback(
    (convId: string) => {
      setConversations((prev) =>
        prev.map((c) => {
          if (c.id === convId) {
            const nextMuted = !c.is_muted;
            showToast({
              type: 'info',
              text: nextMuted ? `Muted notifications for ${c.counterpart.nickname} 🔕` : `Notifications unmuted 🔔`,
            });
            return { ...c, is_muted: nextMuted };
          }
          return c;
        })
      );
    },
    [showToast]
  );

  // Set Wallpaper
  const setChatWallpaper = useCallback(
    (convId: string, wallpaperId: string) => {
      setConversations((prev) =>
        prev.map((c) => (c.id === convId ? { ...c, wallpaper: wallpaperId } : c))
      );
      showToast({ type: 'success', text: 'Chat theme wallpaper updated!' });
    },
    [showToast]
  );

  // Set Disappearing Mode
  const setDisappearingMode = useCallback(
    (convId: string, mode: 'off' | '60s' | '24h' | '7d') => {
      setConversations((prev) =>
        prev.map((c) => (c.id === convId ? { ...c, disappearing_mode: mode } : c))
      );
      const label = mode === 'off' ? 'turned off' : `set to ${mode}`;
      showToast({
        type: 'info',
        text: `🔥 Disappearing messages ${label}`,
      });
    },
    [showToast]
  );

  // Clear Chat History
  const clearChatHistory = useCallback(
    (convId: string) => {
      setMessagesMap((prev) => ({
        ...prev,
        [convId]: [
          {
            id: `msg-cleared-${Date.now()}`,
            conv_id: convId,
            sender_id: 'system',
            type: 'text',
            body: 'Chat history cleared for this conversation.',
            status: 'read',
            created_at: new Date().toISOString(),
          },
        ],
      }));
      setConversations((prev) =>
        prev.map((c) =>
          c.id === convId
            ? {
                ...c,
                last_message: {
                  ...c.last_message,
                  body: 'Chat history cleared.',
                  created_at: new Date().toISOString(),
                },
              }
            : c
        )
      );
      showToast({ type: 'info', text: 'Chat history cleared.' });
    },
    [showToast]
  );

  // Respond to Date Invite
  const respondToDateInvite = useCallback(
    (convId: string, messageId: string, accept: boolean) => {
      setMessagesMap((prev) => {
        const list = prev[convId] || [];
        return {
          ...prev,
          [convId]: list.map((msg) => {
            if (msg.id === messageId && msg.date_invite) {
              return {
                ...msg,
                date_invite: {
                  ...msg.date_invite,
                  status: accept ? 'accepted' : 'declined',
                },
              };
            }
            return msg;
          }),
        };
      });

      showToast({
        type: accept ? 'success' : 'info',
        text: accept ? '🎉 Date invitation accepted! Have a wonderful time!' : 'Date invitation declined.',
      });
    },
    [showToast]
  );

  return (
    <ChatContext.Provider
      value={{
        conversations,
        selectedConvId,
        setSelectedConvId,
        activeConversation,
        activeMessages,
        activeTab,
        setActiveTab,
        filter,
        setFilter,
        searchQuery,
        setSearchQuery,
        filteredConversations,
        totalUnreadCount,
        receivedRequests,
        sentRequests,
        callHistory,
        settings,
        updateSettings,
        sendMessage,
        markAsRead,
        acceptRequest,
        declineRequest,
        cancelSentRequest,
        reportUser,
        blockUser,
        unblockUser,
        unrestrictUser,
        togglePinChat,
        toggleMuteChat,
        setChatWallpaper,
        setDisappearingMode,
        clearChatHistory,
        respondToDateInvite,

        audioCallTarget,
        setAudioCallTarget,
        videoCallTarget,
        setVideoCallTarget,
        callHistoryType,
        setCallHistoryType,
        isSettingsOpen,
        setIsSettingsOpen,
        datePlannerConv,
        setDatePlannerConv,
        icebreakerConv,
        setIcebreakerConv,
        profilePreviewUser,
        setProfilePreviewUser,
        reportTarget,
        setReportTarget,
        blockTarget,
        setBlockTarget,
        isScreenshotModalOpen,
        setIsScreenshotModalOpen,
        profanityAlert,
        setProfanityAlert,

        toast,
        showToast,
        clearToast,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
};

export const useChat = () => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error('useChat must be used within a ChatProvider');
  }
  return context;
};
