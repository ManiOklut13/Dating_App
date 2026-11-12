import React, { useState } from 'react';
import {
  LifeBuoy,
  Flag,
  Inbox,
  BookOpen,
  FileCheck,
  Eye,
  HelpCircle,
  MessageSquare,
  ChevronDown,
  Mail,
} from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  SettingsNavRow,
  SettingsDivider,
  EmptyState,
} from './SettingsUI';
import { useSettings } from './SettingsContext';
import { useProfile, SettingsInfoModalKey } from '../profile/ProfileContext';

/* ==========================================================================
   F. Help and Support — every row opens real content:
   either a dedicated page or the existing info modal.
   ========================================================================== */

export const HelpSupportPage: React.FC = () => {
  const { navigate } = useSettings();
  const { setSettingsInfoModal, showToast } = useProfile();

  const openInfo = (key: SettingsInfoModalKey) => () => setSettingsInfoModal(key);

  const rows: Array<{
    icon: React.ReactNode;
    label: string;
    hint: string;
    onClick: () => void;
  }> = [
    {
      icon: <LifeBuoy size={17} color="#00e5ff" />,
      label: 'Help Center',
      hint: 'Browse answers to common questions',
      onClick: openInfo('help'),
    },
    {
      icon: <Flag size={17} color="#ff4757" />,
      label: 'Report a Problem',
      hint: 'Send a bug report or safety concern',
      onClick: openInfo('report'),
    },
    {
      icon: <Inbox size={17} color="#9b51e0" />,
      label: 'Support Requests',
      hint: 'Track conversations with our support team',
      onClick: () => navigate('settings/help/support-requests'),
    },
    {
      icon: <BookOpen size={17} color="#ffd700" />,
      label: 'Community Guidelines',
      hint: 'What is and is not allowed here',
      onClick: openInfo('guidelines'),
    },
    {
      icon: <FileCheck size={17} color="#00e676" />,
      label: 'Terms and Policies',
      hint: 'The agreement you accepted when joining',
      onClick: openInfo('terms'),
    },
    {
      icon: <Eye size={17} color="#00e5ff" />,
      label: 'Privacy Policy',
      hint: 'How your data is collected and used',
      onClick: openInfo('privacy'),
    },
    {
      icon: <HelpCircle size={17} color="#ffa502" />,
      label: 'Frequently Asked Questions',
      hint: 'Quick answers, written short',
      onClick: () => navigate('settings/help/faq'),
    },
    {
      icon: <MessageSquare size={17} color="#00e676" />,
      label: 'Contact Support',
      hint: 'Chat with a human on the support team',
      onClick: openInfo('contact'),
    },
  ];

  return (
    <SettingsPage title="Help and Support" subtitle="Guidance, reports and policies">
      <SettingsSection label="Get help">
        {rows.map((row, index) => (
          <React.Fragment key={row.label}>
            {index > 0 && <SettingsDivider />}
            <SettingsNavRow icon={row.icon} label={row.label} hint={row.hint} onClick={row.onClick} />
          </React.Fragment>
        ))}
      </SettingsSection>

      <SettingsSection label="Still stuck?">
        <SettingsNavRow
          icon={<Mail size={17} color="#ff2d55" />}
          label="Copy safety team email"
          hint="safety@younme.app · answered within 24h"
          showChevron={false}
          onClick={() => {
            const address = 'safety@younme.app';
            if (navigator.clipboard?.writeText) {
              navigator.clipboard
                .writeText(address)
                .then(() => showToast(`${address} copied to clipboard.`, 'success'))
                .catch(() => showToast(`Reach us at ${address}`, 'info'));
            } else {
              showToast(`Reach us at ${address}`, 'info');
            }
          }}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

/* ==========================================================================
   Support Requests — list with a proper empty state
   ========================================================================== */

interface SupportRequest {
  id: string;
  subject: string;
  status: 'Open' | 'Answered';
  updated: string;
}

export const SupportRequestsPage: React.FC = () => {
  const { setSettingsInfoModal } = useProfile();
  const [requests] = useState<SupportRequest[]>([]);

  return (
    <SettingsPage title="Support Requests" subtitle="Your conversations with support">
      <SettingsSection
        label="Requests"
        note="Replies from the support team appear here so nothing gets lost in your inbox."
      >
        {requests.length === 0 ? (
          <EmptyState
            icon={<Inbox size={26} />}
            title="No support requests yet"
            description="When you contact support, your requests and replies will show up here."
            action={
              <button
                type="button"
                className="btn-primary"
                onClick={() => setSettingsInfoModal('contact')}
              >
                <MessageSquare size={15} />
                Contact Support
              </button>
            }
          />
        ) : (
          requests.map((request, index) => (
            <React.Fragment key={request.id}>
              {index > 0 && <SettingsDivider />}
              <div className="settings-user-row">
                <div className="settings-row-text">
                  <span className="settings-row-label">{request.subject}</span>
                  <span className="settings-row-hint">Updated {request.updated}</span>
                </div>
                <span className={`settings-status-tag ${request.status.toLowerCase()}`}>
                  {request.status}
                </span>
              </div>
            </React.Fragment>
          ))
        )}
      </SettingsSection>
    </SettingsPage>
  );
};

/* ==========================================================================
   Frequently Asked Questions — expandable accordion
   ========================================================================== */

const FAQ_ITEMS = [
  {
    q: 'How do matches work?',
    a: 'You and another member must like each other before a chat unlocks. Head to Discovery to start swiping.',
  },
  {
    q: 'What are YoUnMe Coins?',
    a: 'Coins power boosts, the daily spin wheel and profile highlights. They live in your wallet ledger and have no cash value.',
  },
  {
    q: 'How do I verify my profile?',
    a: 'Open Profile → Verification Center and complete the face and voice scan to earn the blue tick.',
  },
  {
    q: 'Why is contact sharing locked?',
    a: 'Trust Guard masks numbers and emails until you exchange 20 messages across 3 active days.',
  },
  {
    q: 'How do I stop someone from messaging me?',
    a: 'Either block or restrict them from Privacy and Safety, or narrow “Who Can Message Me” to matches only or nobody.',
  },
  {
    q: 'Where are my settings stored?',
    a: 'Your preferences are stored in your browser’s local storage. Clearing site data resets them.',
  },
];

export const FaqPage: React.FC = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <SettingsPage title="Frequently Asked Questions" subtitle="Short answers to common questions">
      <SettingsSection label="Popular questions">
        {FAQ_ITEMS.map((item, index) => (
          <React.Fragment key={item.q}>
            {index > 0 && <SettingsDivider />}
            <div className="settings-faq">
              <button
                type="button"
                className="settings-faq-question"
                aria-expanded={openIndex === index}
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
              >
                <span>{item.q}</span>
                <ChevronDown
                  size={16}
                  className={`settings-faq-chevron${openIndex === index ? ' open' : ''}`}
                  aria-hidden="true"
                />
              </button>
              {openIndex === index && <p className="settings-faq-answer">{item.a}</p>}
            </div>
          </React.Fragment>
        ))}
      </SettingsSection>
    </SettingsPage>
  );
};
