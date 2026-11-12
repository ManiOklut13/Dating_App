import React from 'react';
import {
  SettingsPage,
  SettingsSection,
  RadioGroup,
} from './SettingsUI';
import { useProfile } from '../profile/ProfileContext';
import { LANGUAGES } from '../profile/mockProfile';

/* ==========================================================================
   Themes and Languages — appearance (light / dark) and app language.
   Both preferences live on the profile account settings, so every change is
   applied immediately and remembered on this device.
   ========================================================================== */

export const ThemeLanguagePage: React.FC = () => {
  const { profile, updateAccountSettings, showToast } = useProfile();
  const settings = profile.settings;

  return (
    <SettingsPage title="Themes and Languages" subtitle="Look and language of the app">
      <SettingsSection
        label="Appearance"
        note="The theme is applied the moment you pick it — there is nothing to save."
      >
        <RadioGroup
          label="App theme"
          value={settings.appTheme}
          onChange={(value) => {
            if (value === settings.appTheme) return;
            updateAccountSettings({ appTheme: value as 'dark' | 'light' });
            showToast(`Switched to ${value === 'dark' ? 'Dark' : 'Light'} theme`, 'info');
          }}
          options={[
            {
              value: 'dark',
              label: 'Dark',
              description: 'Cyber Luxe dark theme — easier on the eyes at night',
            },
            {
              value: 'light',
              label: 'Light',
              description: 'Clean light mode — best in bright surroundings',
            },
          ]}
        />
      </SettingsSection>

      <SettingsSection
        label="Language"
        note="Applies to menus, buttons and system messages on this device."
      >
        <RadioGroup
          label="App language"
          value={settings.language}
          onChange={(value) => {
            if (value === settings.language) return;
            updateAccountSettings({ language: value });
            showToast(`Language set to ${value}`, 'info');
          }}
          options={LANGUAGES.map((lang) => ({ value: lang, label: lang }))}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

export default ThemeLanguagePage;
