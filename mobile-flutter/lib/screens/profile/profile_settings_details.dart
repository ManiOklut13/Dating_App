import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/profiles_data.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import 'profile_models.dart';

// ─────────────────────────────────────────────────────────────────────────
// Shared settings chrome
// ─────────────────────────────────────────────────────────────────────────

/// Dark settings page with a back arrow and a bold title, matching the
/// reference Settings screenshot.
class SettingsPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary, size: 21),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
        children: children,
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String text;

  const SettingsSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: theme.textMuted,
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.bgCard.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.appTheme.borderSubtle,
      indent: 60,
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.32)),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 11, color: theme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, size: 18, color: theme.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Simple switch row used by the notification, privacy and security pages.
class SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        activeThumbColor: ProfilePalette.pink,
        activeTrackColor: ProfilePalette.pink.withValues(alpha: 0.45),
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsInfoNote extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const SettingsInfoNote({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Preview Public Card
// ─────────────────────────────────────────────────────────────────────────

class PublicProfilePreviewScreen extends StatelessWidget {
  const PublicProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final profile = AppDataService.instance.userProfile;
    final photo = profile.photos.isNotEmpty ? profile.photos.first : null;

    return SettingsPageScaffold(
      title: 'Preview Public Card',
      children: [
        const SettingsInfoNote(
          icon: Icons.visibility_outlined,
          color: ProfilePalette.cyan,
          text: 'This is how your card appears in discovery and to your matches.',
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: theme.bgCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: ProfilePalette.pink.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: ProfilePalette.magenta.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: AspectRatio(
                  aspectRatio: 1.05,
                  child: photo != null
                      ? SafeProfileImage(imageUrl: photo, fit: BoxFit.cover)
                      : Container(color: theme.bgElevated),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${profile.name}, ${profile.age}',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (profile.isVerified)
                          const Icon(Icons.verified,
                              size: 17, color: Color(0xFF5C8CFF)),
                        const Spacer(),
                        if (profile.isOnline)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.circle,
                                  size: 7, color: ProfilePalette.green),
                              SizedBox(width: 5),
                              Text(
                                'Active now',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ProfilePalette.green,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13, color: theme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          profile.city,
                          style: TextStyle(
                              fontSize: 12, color: theme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.profession} at ${profile.company}',
                      style: TextStyle(fontSize: 12, color: theme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.bio,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: theme.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: profile.interests
                          .map((interest) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: ProfilePalette.pink
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: ProfilePalette.pink
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: ProfilePalette.pink,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Photo Visibility
// ─────────────────────────────────────────────────────────────────────────

class PhotoVisibilityScreen extends StatefulWidget {
  const PhotoVisibilityScreen({super.key});

  @override
  State<PhotoVisibilityScreen> createState() => _PhotoVisibilityScreenState();
}

class _PhotoVisibilityScreenState extends State<PhotoVisibilityScreen> {
  String _visibility = 'Matches only';

  static const _options = <String, String>{
    'Everyone': 'Anyone browsing discovery can see your photos',
    'Matches only': 'Only people you match with can see your photos',
    'Hidden': 'Your photos stay private until you start a chat',
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SettingsPageScaffold(
      title: 'Photo Visibility',
      children: [
        const SettingsInfoNote(
          icon: Icons.lock_outline,
          color: ProfilePalette.pink,
          text: 'Choose who can see the photos on your profile card.',
        ),
        const SizedBox(height: 14),
        SettingsGroup(
          children: _options.entries
              .map(
                (entry) => InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    setState(() => _visibility = entry.key);
                    notify(context, 'Photo visibility set to ${entry.key}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value,
                                style: TextStyle(
                                    fontSize: 11, color: theme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          _visibility == entry.key
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: _visibility == entry.key
                              ? ProfilePalette.pink
                              : theme.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Privacy & Safety
// ─────────────────────────────────────────────────────────────────────────

class PrivacySafetyScreen extends StatefulWidget {
  const PrivacySafetyScreen({super.key});

  @override
  State<PrivacySafetyScreen> createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState extends State<PrivacySafetyScreen> {
  bool _showLocation = true;
  bool _incognito = false;
  bool _readReceipts = true;

  void _reportUser() {
    final matches = AppDataService.instance.conversations.take(6).toList();
    final theme = context.appTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: theme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: theme.borderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                'Report a user',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the profile you want to report',
                style: TextStyle(fontSize: 11.5, color: theme.textMuted),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: matches.length,
                  itemBuilder: (_, i) {
                    final match = matches[i];
                    return ListTile(
                      title: Text(
                        match.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        match.occupation,
                        style: TextStyle(fontSize: 11,
                            color: theme.textMuted),
                      ),
                      trailing: Icon(Icons.flag_outlined,
                          size: 17, color: ProfilePalette.pink),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        notify(context, '${match.name} reported for review');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Privacy & Safety',
      children: [
        SettingsSectionLabel('Safety'),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.flag_outlined,
              color: ProfilePalette.pink,
              title: 'Report a user',
              subtitle: 'Flag inappropriate behaviour to our team',
              onTap: _reportUser,
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.block,
              color: ProfilePalette.danger,
              title: 'Blocked users',
              subtitle: 'Manage people who cannot contact you',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionLabel('Privacy controls'),
        SettingsGroup(
          children: [
            SettingsToggleRow(
              icon: Icons.my_location,
              color: ProfilePalette.cyan,
              title: 'Show my location',
              subtitle: 'Display area and distance on your card',
              value: _showLocation,
              onChanged: (value) => setState(() => _showLocation = value),
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.visibility_off_outlined,
              color: ProfilePalette.purple,
              title: 'Incognito browsing',
              subtitle: 'Browse discovery without appearing in their likes',
              value: _incognito,
              onChanged: (value) => setState(() => _incognito = value),
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.done_all,
              color: ProfilePalette.green,
              title: 'Read receipts',
              subtitle: 'Let matches know when you have read a message',
              value: _readReceipts,
              onChanged: (value) => setState(() => _readReceipts = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SettingsInfoNote(
          icon: Icons.verified_user_outlined,
          color: ProfilePalette.green,
          text: 'Your location is only ever shown as a neighbourhood and a '
              'rounded distance. Exact coordinates are never shared.',
        ),
      ],
    );
  }
}

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final List<String> _blocked = ['Arjun Malhotra', 'Priya Raghavan'];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SettingsPageScaffold(
      title: 'Blocked Users',
      children: [
        if (_blocked.isEmpty)
          const SettingsInfoNote(
            icon: Icons.block,
            color: ProfilePalette.green,
            text: 'You have not blocked anyone. Blocked profiles can never see '
                'your card or message you again.',
          )
        else
          SettingsGroup(
            children: [
              for (var i = 0; i < _blocked.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.bgElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.borderSubtle),
                        ),
                        child: Text(
                          _blocked[i].substring(0, 1),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _blocked[i],
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final name = _blocked[i];
                          setState(() => _blocked.removeAt(i));
                          notify(context, '$name unblocked');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ProfilePalette.pink.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  ProfilePalette.pink.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Text(
                            'Unblock',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ProfilePalette.pink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != _blocked.length - 1) const SettingsDivider(),
              ],
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────────────────

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _matches = true;
  bool _messages = true;
  bool _dateReminders = true;
  bool _likes = false;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Notifications',
      children: [
        SettingsSectionLabel('Activity'),
        SettingsGroup(
          children: [
            SettingsToggleRow(
              icon: Icons.favorite_border,
              color: ProfilePalette.pink,
              title: 'Match notifications',
              subtitle: 'Get told the moment it is a mutual match',
              value: _matches,
              onChanged: (v) => setState(() => _matches = v),
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.chat_bubble_outline,
              color: ProfilePalette.cyan,
              title: 'Message notifications',
              subtitle: 'New chats and unread message reminders',
              value: _messages,
              onChanged: (v) => setState(() => _messages = v),
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.calendar_month_outlined,
              color: ProfilePalette.purple,
              title: 'Date reminders',
              subtitle: 'A nudge before a planned date starts',
              value: _dateReminders,
              onChanged: (v) => setState(() => _dateReminders = v),
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.thumb_up_alt_outlined,
              color: ProfilePalette.gold,
              title: 'Likes and profile views',
              subtitle: 'Know when someone likes or views your card',
              value: _likes,
              onChanged: (v) => setState(() => _likes = v),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionLabel('From YoUnMe'),
        SettingsGroup(
          children: [
            SettingsToggleRow(
              icon: Icons.campaign_outlined,
              color: ProfilePalette.green,
              title: 'Tips & offers',
              subtitle: 'Occasional product news and local date ideas',
              value: _marketing,
              onChanged: (v) => setState(() => _marketing = v),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Security & Account
// ─────────────────────────────────────────────────────────────────────────

class SecurityAccountScreen extends StatefulWidget {
  const SecurityAccountScreen({super.key});

  @override
  State<SecurityAccountScreen> createState() => _SecurityAccountScreenState();
}

class _SecurityAccountScreenState extends State<SecurityAccountScreen> {
  bool _twoFactor = false;

  void _changePassword() {
    final theme = context.appTheme;
    final current = TextEditingController();
    final next = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.borderSubtle),
        ),
        title: const Text(
          'Change password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              style: TextStyle(color: theme.textPrimary, fontSize: 13.5),
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: next,
              obscureText: true,
              style: TextStyle(color: theme.textPrimary, fontSize: 13.5),
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel',
                style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              current.dispose();
              next.dispose();
              notify(context, 'Password updated');
            },
            child: const Text(
              'Update',
              style: TextStyle(
                color: ProfilePalette.pink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyIdentity() {
    notify(context, 'Face & voice verification is already complete');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    const devices = <(String, String, bool)>[
      ('iPhone 15 Pro', 'Hyderabad, IN · This device', true),
      ('MacBook Air', 'Hyderabad, IN · Last active 2h ago', false),
      ('Pixel 8', 'Mumbai, IN · Last active 4d ago', false),
    ];

    return SettingsPageScaffold(
      title: 'Security & Account',
      children: [
        SettingsSectionLabel('Login'),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.password,
              color: ProfilePalette.pink,
              title: 'Change password',
              subtitle: 'Update the password used to sign in',
              onTap: _changePassword,
            ),
            const SettingsDivider(),
            SettingsToggleRow(
              icon: Icons.shield_outlined,
              color: ProfilePalette.cyan,
              title: 'Two-factor authentication',
              subtitle: 'Require a code when signing in on a new device',
              value: _twoFactor,
              onChanged: (v) => setState(() => _twoFactor = v),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionLabel('Verification'),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.verified_user_outlined,
              color: ProfilePalette.green,
              title: 'Face & voice verification',
              subtitle: 'Profile verified',
              trailing: const Icon(Icons.verified,
                  size: 18, color: ProfilePalette.green),
              onTap: _verifyIdentity,
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionLabel('Active devices'),
        SettingsGroup(
          children: [
            for (var i = 0; i < devices.length; i++) ...[
              SettingsRow(
                icon: devices[i].$3
                    ? Icons.phone_iphone
                    : Icons.devices_other,
                color: devices[i].$3
                    ? ProfilePalette.green
                    : ProfilePalette.purple,
                title: devices[i].$1,
                subtitle: devices[i].$2,
                trailing: devices[i].$3
                    ? null
                    : Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.textMuted,
                        ),
                      ),
                onTap: devices[i].$3
                    ? null
                    : () => notify(
                        context, '${devices[i].$1} signed out remotely'),
              ),
              if (i != devices.length - 1) const SettingsDivider(),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const SettingsInfoNote(
          icon: Icons.info_outline,
          color: ProfilePalette.cyan,
          text: 'Device activity is simulated for this build. Signing out of '
              'another device does not end your current session.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Help & Support
// ─────────────────────────────────────────────────────────────────────────

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'How do I plan a date?',
      'Open the Chat tab, tap the calendar icon in the header, then pick the '
          'chat you want to plan a date with.'
    ),
    (
      'What does profile verification mean?',
      'A face and voice scan confirms you are the person in your photos. '
          'Verified profiles get a blue badge.'
    ),
    (
      'How is my distance shown?',
      'We round the distance to your area so matches see a neighbourhood and '
          'an approximate figure, never an exact location.'
    ),
    (
      'Can I hide my photos?',
      'Yes. Settings → Photo Visibility lets you limit photos to matches only '
          'or hide them entirely.'
    ),
  ];

  void _contactSupport(BuildContext context) {
    final theme = context.appTheme;
    final subject = TextEditingController();
    final message = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.borderSubtle),
        ),
        title: const Text(
          'Contact support',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subject,
              style: TextStyle(color: theme.textPrimary, fontSize: 13.5),
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: message,
              maxLines: 3,
              style: TextStyle(color: theme.textPrimary, fontSize: 13.5),
              decoration: const InputDecoration(
                  labelText: 'How can we help?'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel',
                style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              subject.dispose();
              message.dispose();
              notify(context, 'Message sent to the YoUnMe team');
            },
            child: const Text(
              'Send',
              style: TextStyle(
                color: ProfilePalette.pink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SettingsPageScaffold(
      title: 'Help & Support',
      children: [
        SettingsSectionLabel('Help Center'),
        SettingsGroup(
          children: [
            for (var i = 0; i < _faqs.length; i++) ...[
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  iconColor: ProfilePalette.pink,
                  collapsedIconColor: theme.textMuted,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(13, 0, 13, 12),
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: ProfilePalette.cyan.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ProfilePalette.cyan.withValues(alpha: 0.32),
                      ),
                    ),
                    child: const Icon(Icons.help_outline,
                        size: 17, color: ProfilePalette.cyan),
                  ),
                  title: Text(
                    _faqs[i].$1,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _faqs[i].$2,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: theme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (i != _faqs.length - 1) const SettingsDivider(),
            ],
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionLabel('Contact us'),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.mail_outline,
              color: ProfilePalette.pink,
              title: 'Contact Support',
              subtitle: 'Send a message to the YoUnMe team',
              onTap: () => _contactSupport(context),
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.bug_report_outlined,
              color: ProfilePalette.gold,
              title: 'Report a problem',
              subtitle: 'Tell us about a bug or a broken screen',
              onTap: () {
                Clipboard.setData(
                  const ClipboardData(text: 'support@younme.app'),
                );
                notify(context, 'Support email copied: support@younme.app');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SettingsInfoNote(
          icon: Icons.schedule,
          color: ProfilePalette.purple,
          text: 'Support replies within 24 hours on weekdays. For safety '
              'emergencies, contact your local authorities first.',
        ),
      ],
    );
  }
}
