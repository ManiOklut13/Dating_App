import React from 'react';
import { useCalls } from './CallsContext';
import { CallsPage } from './CallsPage';
import { CallHistoryPage } from './CallHistoryPage';
import { CallDetailsPage } from './CallDetailsPage';

/* ==========================================================================
   Calls route map — the same shape as modules/settings/SettingsRouter.tsx.

   Rendered as a full-screen overlay from App.tsx, so opening the Calls
   screens does not unmount the Chat tab underneath: returning back to chat
   preserves the conversation and every message already loaded.
   ========================================================================== */
export const CallsRouter: React.FC = () => {
  const { route } = useCalls();

  if (!route) return null;

  switch (route.name) {
    case 'audio':
      return <CallHistoryPage type="audio" />;
    case 'video':
      return <CallHistoryPage type="video" />;
    case 'audio-detail':
      return <CallDetailsPage type="audio" />;
    case 'video-detail':
      return <CallDetailsPage type="video" />;
    case 'calls':
    default:
      return <CallsPage />;
  }
};