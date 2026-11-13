import 'package:flutter/material.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import '../../services/theme_provider.dart';
import 'edit_profile_modal.dart';

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  void _openEditProfile(BuildContext context, UserProfileModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileModalSheet(profile: profile),
    );
  }

  void _showProfileOptionsMenu(BuildContext context, YoUnMeThemeExtension theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Settings & Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.visibility_outlined, color: AppColors.cyanAccent),
                  title: Text('Preview Public Card', style: TextStyle(color: theme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Previewing public card as others see it'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.share_outlined, color: AppColors.goldAccent),
                  title: Text('Share Profile Link', style: TextStyle(color: theme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile link copied to clipboard'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline, color: AppColors.flamePink),
                  title: Text('Privacy & Safety', style: TextStyle(color: theme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined, color: AppColors.flamePurple),
                  title: Text('Notifications', style: TextStyle(color: theme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.security, color: AppColors.onlineGreen),
                  title: Text('Security & Account', style: TextStyle(color: theme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDarkMode;

    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final profile = AppDataService.instance.userProfile;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar with Back button, Profile Avatar, Title & Single Settings Icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.bgSurface,
                    border: Border(
                      bottom: BorderSide(color: theme.borderSubtle, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Use bottom bar to navigate to Discovery'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.bgElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.borderSubtle),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // User profile avatar thumbnail in top-left
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.flameGradient,
                            ),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: theme.bgElevated,
                              backgroundImage: profile.photos.isNotEmpty
                                  ? AssetImage(profile.photos.first)
                                  : null,
                              child: profile.photos.isEmpty
                                  ? Text(
                                      profile.name.substring(0, 1),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: theme.textPrimary,
                                ),
                              ),
                              Text(
                                '${profile.name} · ${profile.city}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Single Settings Icon (⚙️) — No duplicate 3-dot menu icon
                      InkWell(
                        onTap: () => _showProfileOptionsMenu(context, theme),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.bgElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.borderSubtle),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 19,
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Header Card with primary photo and stats
                _buildHeaderCard(context, profile, theme, isDark),

                const SizedBox(height: 16),

                // Main Sections Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Photo Gallery Grid
                      _buildPhotosSection(profile, theme, isDark),
                      const SizedBox(height: 16),

                      // About Me Card
                      _buildAboutMeCard(context, profile, theme, isDark),
                      const SizedBox(height: 16),

                      // Interests & Hobbies Card
                      _buildInterestsCard(context, profile, theme, isDark),
                      const SizedBox(height: 16),

                      // Personal Prompt Card
                      _buildPersonalPromptCard(profile, theme, isDark),
                      const SizedBox(height: 16),

                      // App Settings & Theme Control Card
                      _buildAppSettingsCard(context, theme, isDark),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    final primaryPhoto = profile.photos.isNotEmpty ? profile.photos.first : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.bgSurface,
        border: Border(bottom: BorderSide(color: theme.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with gradient border & status dot
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.flameGradient,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.bgElevated,
                      backgroundImage: primaryPhoto != null
                          ? AssetImage(primaryPhoto)
                          : null,
                      child: primaryPhoto == null
                          ? Text(
                              profile.name.substring(0, 1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: profile.isOnline ? theme.onlineDot : theme.offlineDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.bgSurface, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Details & Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${profile.name}, ${profile.age}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            size: 20,
                            color: AppColors.cyanAccent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: theme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile.city,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Edit Profile Action Button
                    ElevatedButton.icon(
                      onPressed: () => _openEditProfile(context, profile),
                      icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.flamePink,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Verification Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.cyanAccent.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cyanAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 17,
                  color: AppColors.cyanAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Identity & Liveness Verified with Blue Tick badge.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF80F0FF) : const Color(0xFF007A8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    return _buildCardWrapper(
      title: 'Profile Photos',
      icon: Icons.photo_library_outlined,
      iconColor: AppColors.flamePink,
      theme: theme,
      isDark: isDark,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: profile.photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final photo = profile.photos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: theme.bgElevated,
              child: Image.asset(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image, color: theme.textMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutMeCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    return _buildCardWrapper(
      title: 'About Me',
      icon: Icons.person_outline,
      iconColor: AppColors.cyanAccent,
      theme: theme,
      isDark: isDark,
      onEdit: () => _openEditProfile(context, profile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: theme.borderSubtle, height: 1),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.work_outline,
            '${profile.profession} at ${profile.company}',
            theme,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.school_outlined, profile.education, theme),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.place_outlined, profile.city, theme),
        ],
      ),
    );
  }

  Widget _buildInterestsCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    const available = [
      'Music',
      'Travel',
      'Photography',
      'Art',
      'Fitness',
      'Coffee',
      'Reading',
      'Gaming',
      'Cooking',
    ];

    return _buildCardWrapper(
      title: 'Interests & Vibe',
      icon: Icons.local_fire_department_outlined,
      iconColor: AppColors.goldAccent,
      theme: theme,
      isDark: isDark,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: available.map((interest) {
          final isSelected = profile.interests.contains(interest);
          return GestureDetector(
            onTap: () => AppDataService.instance.toggleInterest(interest),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.flamePink.withValues(alpha: 0.16)
                    : theme.bgElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.flamePink : theme.borderSubtle,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    interest,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.flamePink : theme.textSecondary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check, size: 14, color: AppColors.flamePink),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonalPromptCard(
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    final question = profile.personalPrompt['question'] ?? 'Personal Prompt';
    final answer = profile.personalPrompt['answer'] ?? '';

    return _buildCardWrapper(
      title: question,
      icon: Icons.chat_outlined,
      iconColor: AppColors.flamePurple,
      theme: theme,
      isDark: isDark,
      child: Text(
        answer,
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          height: 1.45,
          color: theme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard(
    BuildContext context,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    final themeProvider = YoUnMeThemeScope.of(context);

    return _buildCardWrapper(
      title: 'App Theme & Appearance',
      icon: Icons.palette_outlined,
      iconColor: AppColors.flamePurple,
      theme: theme,
      isDark: isDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark
                      ? 'Cyber Luxe dark theme active'
                      : 'Clean warm cream light theme active',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            activeThumbColor: AppColors.flamePink,
            onChanged: (val) {
              themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Color iconColor,
    required YoUnMeThemeExtension theme,
    required bool isDark,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.flamePink,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, YoUnMeThemeExtension theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: theme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
