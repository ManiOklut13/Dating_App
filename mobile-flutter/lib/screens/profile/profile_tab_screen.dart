import 'package:flutter/material.dart';

import '../../data/profiles_data.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import '../chat/individual_chat_screen.dart';
import 'edit_profile_modal.dart';
import 'profile_models.dart';
import 'profile_settings_screen.dart';

/// Theme-aware Profile tab rebuilt from the reference screenshots: gradient
/// banner, identity block, progress card, photo grid, about me, prompt,
/// interests and discovery preferences.
class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  ProfileDetails _details = ProfileDetails.defaults;
  bool _progressExpanded = false;

  // ── Actions ────────────────────────────────────────────────────────────
  void _openEditProfile(BuildContext context, UserProfileModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileModalSheet(
        profile: profile,
        details: _details,
        onDetailsChanged: (next) => setState(() => _details = next),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
    );
  }

  void _addPhoto(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Choose a photo from your gallery to add it here'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMatches(BuildContext context, YoUnMeThemeExtension theme) {
    final matches = AppDataService.instance.conversations.take(8).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
        ),
        decoration: BoxDecoration(
          color: theme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.borderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Matches (${matches.length})',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: theme.textMuted),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: theme.borderSubtle),
                  itemBuilder: (_, i) {
                    final match = matches[i];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.flameGradient,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: match.avatarAsset != null
                              ? SafeProfileImage(
                                  imageUrl: match.avatarAsset!,
                                  width: 42,
                                  height: 42,
                                )
                              : Container(
                                  color: theme.bgElevated,
                                  alignment: Alignment.center,
                                  child: Text(
                                    match.name.substring(0, 1),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        '${match.name}, ${match.age}',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${match.city} · ${match.occupation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: theme.textMuted),
                      ),
                      trailing: Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: ProfilePalette.pink,
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                IndividualChatScreen(conversation: match),
                          ),
                        );
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

  void _showInterestsSheet(BuildContext context, UserProfileModel profile) {
    final theme = context.appTheme;
    final options = <String>{
      ...profile.interests,
      ...kExtraInterests,
    }.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: theme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.borderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: AppDataService.instance,
            builder: (context, _) {
              final selected = AppDataService.instance.userProfile.interests;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 10, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Interests & Passions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: theme.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: options.map((interest) {
                          final isSelected = selected.contains(interest);
                          return GestureDetector(
                            onTap: () =>
                                AppDataService.instance.toggleInterest(interest),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ProfilePalette.pink.withValues(alpha: 0.16)
                                    : theme.bgElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? ProfilePalette.pink
                                      : theme.borderSubtle,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _interestIcon(interest),
                                    size: 13,
                                    color: isSelected
                                        ? ProfilePalette.pink
                                        : theme.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? ProfilePalette.pink
                                          : theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPreferencesSheet(BuildContext context) {
    final theme = context.appTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          void update(ProfileDetails next) {
            setSheetState(() => _details = next);
            setState(() {});
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: theme.borderSubtle),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.textMuted.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Dating & Discovery',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: theme.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _sheetLabel('Looking for', theme),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kLookingForOptions
                          .map((option) => _optionPill(
                                label: option,
                                selected: _details.lookingFor == option,
                                color: ProfilePalette.pink,
                                theme: theme,
                                onTap: () =>
                                    update(_details.copyWith(lookingFor: option)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _sheetLabel('Interested in', theme),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kInterestedInOptions
                          .map((option) => _optionPill(
                                label: option,
                                selected: _details.interestedIn == option,
                                color: ProfilePalette.cyan,
                                theme: theme,
                                onTap: () => update(
                                    _details.copyWith(interestedIn: option)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sheetLabel('Age range', theme),
                        Text(
                          _details.ageRangeLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: ProfilePalette.gold,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(
                        _details.minAge.toDouble(),
                        _details.maxAge.toDouble(),
                      ),
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: ProfilePalette.gold,
                      inactiveColor: theme.borderSubtle,
                      labels: RangeLabels('${_details.minAge}', '${_details.maxAge}'),
                      onChanged: (values) => update(
                        _details.copyWith(
                          minAge: values.start.round(),
                          maxAge: values.end.round(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sheetLabel('Maximum distance', theme),
                        Text(
                          _details.maxDistanceLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: ProfilePalette.green,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _details.maxDistanceKm.toDouble(),
                      min: 1,
                      max: 100,
                      activeColor: ProfilePalette.green,
                      inactiveColor: theme.borderSubtle,
                      onChanged: (value) => update(
                        _details.copyWith(maxDistanceKm: value.round()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProfilePalette.pink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Preferences',
                          style: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showActivitiesSheet(BuildContext context) {
    final theme = context.appTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.62,
            ),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: theme.borderSubtle),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.textMuted.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Activities To Do Together',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: theme.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kActivityOptions.map((activity) {
                        final selected = _details.activities.contains(activity);
                        return _optionPill(
                          label: activity,
                          selected: selected,
                          color: ProfilePalette.purple,
                          theme: theme,
                          onTap: () {
                            final next = List<String>.from(_details.activities);
                            if (selected) {
                              next.remove(activity);
                            } else {
                              next.add(activity);
                            }
                            setSheetState(
                                () => _details = _details.copyWith(activities: next));
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final profile = AppDataService.instance.userProfile;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(context, profile, theme),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 52),
                      _buildIdentity(profile, theme),
                      const SizedBox(height: 14),
                      _buildActionButtons(context, profile),
                      const SizedBox(height: 20),
                      _buildProgressCard(profile, theme),
                      const SizedBox(height: 14),
                      _buildPhotosCard(context, profile, theme),
                      const SizedBox(height: 14),
                      _buildAboutCard(context, profile, theme),
                      const SizedBox(height: 14),
                      _buildPromptCard(profile, theme),
                      const SizedBox(height: 14),
                      _buildInterestsCard(context, profile, theme),
                      const SizedBox(height: 14),
                      _buildPreferencesCard(context, theme),
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

  // ── Banner & identity ──────────────────────────────────────────────────
  Widget _buildBanner(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
  ) {
    final photo = profile.photos.isNotEmpty ? profile.photos.first : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              gradient: ProfilePalette.banner,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ProfilePalette.magenta.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _openSettings(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -46,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFFF9BC0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: photo != null
                      ? SafeProfileImage(imageUrl: photo, fit: BoxFit.cover)
                      : Container(
                          color: theme.bgElevated,
                          alignment: Alignment.center,
                          child: Text(
                            profile.name.substring(0, 1),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity(UserProfileModel profile, YoUnMeThemeExtension theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              '${profile.name}, ${profile.age}',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: theme.textPrimary,
              ),
            ),
            if (profile.isVerified) _verifiedPill(),
            if (profile.isOnline)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: ProfilePalette.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Active now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ProfilePalette.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 4,
          children: [
            Icon(Icons.location_on, size: 14, color: theme.textMuted),
            Text(
              profile.city,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            Text('•', style: TextStyle(fontSize: 12.5, color: theme.textMuted)),
            Text(
              _details.area,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: ProfilePalette.blue,
              ),
            ),
            Text('•', style: TextStyle(fontSize: 12.5, color: theme.textMuted)),
            Text(
              _details.distanceLabel,
              style: TextStyle(fontSize: 12.5, color: theme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          '${profile.profession} at ${profile.company}',
          style: TextStyle(fontSize: 13, color: theme.textSecondary),
        ),
      ],
    );
  }

  Widget _verifiedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3FA0).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5C8CFF).withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 13, color: Color(0xFF9CC0FF)),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDCE8FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserProfileModel profile) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _openEditProfile(context, profile),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: ProfilePalette.primaryButton,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: ProfilePalette.magenta.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 15, color: Colors.white),
                  SizedBox(width: 7),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _showMatches(context, context.appTheme),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: context.appTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.appTheme.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: ProfilePalette.pink,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Matches',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: context.appTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Progress ───────────────────────────────────────────────────────────
  List<_ProgressCheck> _progressChecks(UserProfileModel profile) {
    final promptAnswer = profile.personalPrompt['answer']?.trim() ?? '';
    return [
      _ProgressCheck(
        title: 'Add at least 3 profile photos',
        done: profile.photos.length >= 3,
        icon: Icons.photo_library_outlined,
        onTap: () => _openEditProfile(context, profile),
      ),
      _ProgressCheck(
        title: 'Complete your personal bio',
        done: profile.bio.trim().length >= 20,
        icon: Icons.article_outlined,
        onTap: () => _openEditProfile(context, profile),
      ),
      _ProgressCheck(
        title: 'Select at least 4 interests or hobbies',
        done: profile.interests.length >= 4,
        icon: Icons.favorite_border,
        onTap: () => _showInterestsSheet(context, profile),
      ),
      _ProgressCheck(
        title: 'Set your dating & discovery preferences',
        done: _details.lookingFor.isNotEmpty && _details.interestedIn.isNotEmpty,
        icon: Icons.tune,
        onTap: () => _showPreferencesSheet(context),
      ),
      _ProgressCheck(
        title: 'Verify your profile with face & voice scan',
        done: profile.isVerified && promptAnswer.isNotEmpty,
        icon: Icons.verified_user_outlined,
        onTap: () => _showVerificationInfo(context),
      ),
    ];
  }

  void _showVerificationInfo(BuildContext context) {
    final theme = context.appTheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.borderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: ProfilePalette.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Verified profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Your face and voice scan is complete. Your profile shows the blue '
          'verified badge to matches.',
          style: TextStyle(fontSize: 13, height: 1.5, color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: ProfilePalette.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(_ProgressCheck check, YoUnMeThemeExtension theme) {
    final color = check.done ? ProfilePalette.green : theme.textMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: check.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          gradient: check.done ? ProfilePalette.completedChecklistItem : null,
          color: check.done ? null : theme.bgElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: check.done
                ? ProfilePalette.green.withValues(alpha: 0.38)
                : theme.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: check.done ? 0.16 : 0.08),
                border: Border.all(color: color.withValues(alpha: 0.6)),
              ),
              child: Icon(
                check.done ? Icons.check_circle : check.icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: check.done ? Colors.white : theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    check.done ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: check.done ? ProfilePalette.green : theme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!check.done)
              Icon(Icons.chevron_right, size: 16, color: theme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(UserProfileModel profile, YoUnMeThemeExtension theme) {
    final checks = _progressChecks(profile);
    final completed = checks.where((c) => c.done).length;
    final percent = (completed / checks.length * 100).round();
    final filledSegments = (percent / 100 * 8).round().clamp(0, 8);

    return GestureDetector(
      onTap: () => setState(() => _progressExpanded = !_progressExpanded),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 16),
        decoration: BoxDecoration(
          gradient: ProfilePalette.progressCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ProfilePalette.cyan.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ProfilePalette.cyan.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ProfilePalette.cyan.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 20,
                    color: ProfilePalette.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Complete your profile to improve connection matches & visibility',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ProfilePalette.cyan,
                  ),
                ),
                AnimatedRotation(
                  turns: _progressExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    size: 20,
                    color: ProfilePalette.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(8, (i) {
                final active = i < filledSegments;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 7 ? 0 : 5),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFF2BC4F3), Color(0xFF3BE0C9)],
                              )
                            : null,
                        color: active
                            ? null
                            : ProfilePalette.cyan.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                );
              }),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _progressExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 14),
                        for (var i = 0; i < checks.length; i++) ...[
                          _buildChecklistItem(checks[i], theme),
                          if (i != checks.length - 1) const SizedBox(height: 9),
                        ],
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  // ── Photos ─────────────────────────────────────────────────────────────
  Widget _buildPhotosCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
  ) {
    final photos = profile.photos;
    final canAdd = photos.length < _details.photoLimit;

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ProfilePalette.pink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ProfilePalette.pink.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 17,
                  color: ProfilePalette.pink,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photos (${photos.length}/${_details.photoLimit})',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload up to ${_details.photoLimit} high-resolution photos',
                      style: TextStyle(fontSize: 11, color: theme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.74,
            children: [
              for (var i = 0; i < photos.length; i++)
                _buildPhotoTile(photos[i], i == 0, theme),
              if (canAdd) _buildAddPhotoTile(context, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(String path, bool isPrimary, YoUnMeThemeExtension theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: theme.bgElevated,
            child: SafeProfileImage(imageUrl: path, fit: BoxFit.cover),
          ),
          Positioned(
            right: 5,
            bottom: 5,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.edit, size: 11, color: Colors.white),
            ),
          ),
          if (isPrimary)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: ProfilePalette.primaryButton,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 9, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'Primary',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoTile(BuildContext context, YoUnMeThemeExtension theme) {
    return GestureDetector(
      onTap: () => _addPhoto(context),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: ProfilePalette.pink.withValues(alpha: 0.45),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ProfilePalette.pink.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ProfilePalette.pink.withValues(alpha: 0.75),
                  ),
                ),
                child: const Icon(Icons.add, size: 16, color: ProfilePalette.pink),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Photo',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── About me ───────────────────────────────────────────────────────────
  Widget _buildAboutCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
  ) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.person_outline,
            color: ProfilePalette.purple,
            title: 'About Me',
            subtitle: 'Tell people about you',
            theme: theme,
            onEdit: () => _openEditProfile(context, profile),
          ),
          const SizedBox(height: 14),
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: theme.textPrimary.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.work_outline,
            color: ProfilePalette.magenta,
            label: 'PROFESSION',
            value: '${profile.profession} • ${profile.company}',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _infoTile(
            icon: Icons.school_outlined,
            color: ProfilePalette.cyan,
            label: 'EDUCATION',
            value: profile.education,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _infoTile(
            icon: Icons.location_on_outlined,
            color: ProfilePalette.gold,
            label: 'CITY / LOCATION',
            value: '${profile.city} (${_details.area})',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _infoTile(
            icon: Icons.language,
            color: ProfilePalette.green,
            label: 'LANGUAGES',
            value: _details.languages.join(', '),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required YoUnMeThemeExtension theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: theme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: theme.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Prompt ─────────────────────────────────────────────────────────────
  Widget _buildPromptCard(UserProfileModel profile, YoUnMeThemeExtension theme) {
    final question = profile.personalPrompt['question'] ?? 'Personal Prompt';
    final answer = profile.personalPrompt['answer'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ProfilePalette.promptCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfilePalette.pink.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.format_quote, size: 14, color: ProfilePalette.pink),
              SizedBox(width: 6),
              Text(
                'PERSONAL DATING PROMPT',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: ProfilePalette.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Interests ──────────────────────────────────────────────────────────
  Widget _buildInterestsCard(
    BuildContext context,
    UserProfileModel profile,
    YoUnMeThemeExtension theme,
  ) {
    final interests = profile.interests;

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.favorite_border,
            color: ProfilePalette.pink,
            title: 'Interests & Passions (${interests.length})',
            subtitle: 'Selected topics match finds you',
            theme: theme,
            onEdit: () => _showInterestsSheet(context, profile),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < interests.length; i++)
                _interestChip(
                  interests[i],
                  i < 6 ? ProfilePalette.pink : ProfilePalette.cyan,
                  theme,
                  onTap: () =>
                      AppDataService.instance.toggleInterest(interests[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _interestChip(
    String label,
    Color color,
    YoUnMeThemeExtension theme, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_interestIcon(label), size: 12, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _interestIcon(String interest) {
    final key = interest.toLowerCase();
    if (key.contains('music')) return Icons.music_note;
    if (key.contains('travel')) return Icons.flight_takeoff;
    if (key.contains('photo')) return Icons.camera_alt_outlined;
    if (key.contains('art')) return Icons.palette_outlined;
    if (key.contains('fit') || key.contains('run')) return Icons.fitness_center;
    if (key.contains('coffee') || key.contains('espresso')) {
      return Icons.local_cafe_outlined;
    }
    if (key.contains('read')) return Icons.menu_book_outlined;
    if (key.contains('gam')) return Icons.sports_esports_outlined;
    if (key.contains('cook')) return Icons.restaurant_outlined;
    if (key.contains('keyboard')) return Icons.keyboard_outlined;
    return Icons.tag;
  }

  // ── Discovery preferences ──────────────────────────────────────────────
  Widget _buildPreferencesCard(BuildContext context, YoUnMeThemeExtension theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.shield_outlined,
            color: ProfilePalette.purple,
            title: 'Dating & Discovery Preferences',
            subtitle: 'Who you want to meet',
            theme: theme,
            onEdit: () => _showPreferencesSheet(context),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _prefTile(
                  'LOOKING FOR',
                  _details.lookingFor,
                  ProfilePalette.pink,
                  theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _prefTile(
                  'INTERESTED IN',
                  _details.interestedIn,
                  ProfilePalette.cyan,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _prefTile(
            'AGE RANGE',
            _details.ageRangeLabel,
            ProfilePalette.gold,
            theme,
          ),
          const SizedBox(height: 8),
          _prefTile(
            'MAX DISTANCE',
            _details.maxDistanceLabel,
            ProfilePalette.green,
            theme,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Activities To Do Together',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showActivitiesSheet(context),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: ProfilePalette.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _details.activities
                .map((activity) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.bgElevated,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: theme.borderSubtle),
                      ),
                      child: Text(
                        activity,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _prefTile(
    String label,
    String value,
    Color color,
    YoUnMeThemeExtension theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared bits ────────────────────────────────────────────────────────
  Widget _card(YoUnMeThemeExtension theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required YoUnMeThemeExtension theme,
    VoidCallback? onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.42)),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: theme.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: theme.bgElevated,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: theme.borderSubtle),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 14,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sheetLabel(String text, YoUnMeThemeExtension theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  Widget _optionPill({
    required String label,
    required bool selected,
    required Color color,
    required YoUnMeThemeExtension theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : theme.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : theme.borderSubtle,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Hand-drawn dashed rounded border used by the "Add Photo" tile.
class _ProgressCheck {
  final String title;
  final bool done;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProgressCheck({
    required this.title,
    required this.done,
    required this.icon,
    this.onTap,
  });
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(12),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
