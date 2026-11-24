import 'package:flutter/material.dart';

import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import 'profile_models.dart';

/// Edit Profile sheet modelled on the reference screenshots: a scrollable
/// identity + about-me form with a pinned Cancel / Save Changes footer.
///
/// Nickname and Date of Birth are shown but locked — they are rendered as
/// read-only rows and never bound to a text controller.
class EditProfileModalSheet extends StatefulWidget {
  final UserProfileModel profile;
  final ProfileDetails details;
  final ValueChanged<ProfileDetails>? onDetailsChanged;

  const EditProfileModalSheet({
    super.key,
    required this.profile,
    this.details = ProfileDetails.defaults,
    this.onDetailsChanged,
  });

  @override
  State<EditProfileModalSheet> createState() => _EditProfileModalSheetState();
}

class _EditProfileModalSheetState extends State<EditProfileModalSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _educationController;
  late TextEditingController _cityController;
  late TextEditingController _promptQuestionController;
  late TextEditingController _promptAnswerController;

  late String _gender;
  late String _orientation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio);
    _professionController =
        TextEditingController(text: widget.profile.profession);
    _companyController = TextEditingController(text: widget.profile.company);
    _educationController =
        TextEditingController(text: widget.profile.education);
    _cityController = TextEditingController(text: widget.profile.city);
    _promptQuestionController = TextEditingController(
      text: widget.profile.personalPrompt['question'] ??
          'The key to my heart is...',
    );
    _promptAnswerController = TextEditingController(
      text: widget.profile.personalPrompt['answer'] ?? '',
    );
    _gender = widget.details.gender;
    _orientation = widget.details.sexualOrientation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    _cityController.dispose();
    _promptQuestionController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : widget.profile.name,
      bio: _bioController.text.trim(),
      profession: _professionController.text.trim(),
      company: _companyController.text.trim(),
      education: _educationController.text.trim(),
      city: _cityController.text.trim(),
      personalPrompt: {
        'question': _promptQuestionController.text.trim().isNotEmpty
            ? _promptQuestionController.text.trim()
            : 'The key to my heart is...',
        'answer': _promptAnswerController.text.trim(),
      },
    );

    AppDataService.instance.updateUserProfile(updated);
    widget.onDetailsChanged?.call(
      widget.details.copyWith(gender: _gender, sexualOrientation: _orientation),
    );
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      decoration: BoxDecoration(
        color: theme.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: theme.borderSubtle),
          left: BorderSide(color: theme.borderSubtle),
          right: BorderSide(color: theme.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: ProfilePalette.primaryButton,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ProfilePalette.magenta.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 22,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Update your identity, bio, and dating intro',
                          style: TextStyle(fontSize: 11.5,
                              color: theme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.bgElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.borderSubtle),
                      ),
                      child: Icon(Icons.close, size: 16,
                          color: theme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.borderSubtle),
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                    18, 16, 18, viewInsets.bottom + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Identity', Icons.person_outline,
                        const Color(0xFFB85BF0), theme),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _inputField(
                            label: 'Full Name',
                            controller: _nameController,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _lockedField(
                            label: 'Date of Birth',
                            value: widget.details.dateOfBirth,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _lockedField(
                      label: 'Nickname',
                      value: widget.details.nickname,
                      hint: '(visible to others)',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _dropdownField(
                            label: 'Gender',
                            value: _gender,
                            options: kGenderOptions,
                            theme: theme,
                            onChanged: (value) =>
                                setState(() => _gender = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdownField(
                            label: 'Sexual Orientation',
                            value: _orientation,
                            options: kSexualOrientationOptions,
                            theme: theme,
                            onChanged: (value) =>
                                setState(() => _orientation = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('About Me', Icons.person_outline,
                        ProfilePalette.purple, theme),
                    const SizedBox(height: 12),
                    _inputField(
                      label: 'Personal Bio',
                      controller: _bioController,
                      theme: theme,
                      maxLines: 5,
                      hintText: 'Share what makes you unique...',
                    ),
                    const SizedBox(height: 14),
                    _promptCard(theme),
                    const SizedBox(height: 20),
                    _sectionLabel('More Details', Icons.badge_outlined,
                        ProfilePalette.cyan, theme),
                    const SizedBox(height: 12),
                    _inputField(
                      label: 'Profession',
                      controller: _professionController,
                      theme: theme,
                      prefixIcon: Icons.work_outline,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      label: 'Company',
                      controller: _companyController,
                      theme: theme,
                      prefixIcon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      label: 'Education',
                      controller: _educationController,
                      theme: theme,
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      label: 'City / Location',
                      controller: _cityController,
                      theme: theme,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: theme.borderSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.bgElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.borderSubtle),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: _save,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: ProfilePalette.primaryButton,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ProfilePalette.magenta.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined,
                                size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pieces ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(
    String label,
    IconData icon,
    Color color,
    YoUnMeThemeExtension theme,
  ) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: theme.borderSubtle)),
      ],
    );
  }

  Widget _label(String label, YoUnMeThemeExtension theme, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 5),
            Text(
              hint,
              style: TextStyle(fontSize: 10, color: theme.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldShell(
    YoUnMeThemeExtension theme, {
    required Widget child,
    bool locked = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: locked
              ? theme.borderSubtle
              : theme.borderSubtle.withValues(alpha: 0.9),
        ),
      ),
      child: child,
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required YoUnMeThemeExtension theme,
    IconData? prefixIcon,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, theme),
        _fieldShell(
          theme,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 13.5,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: theme.textMuted, fontSize: 13.5),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: prefixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(prefixIcon, size: 16,
                          color: theme.textMuted),
                    ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lockedField({
    required String label,
    required String value,
    required YoUnMeThemeExtension theme,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, theme, hint: hint),
        _fieldShell(
          theme,
          locked: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.lock_outline, size: 14, color: theme.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> options,
    required YoUnMeThemeExtension theme,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, theme),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              dropdownColor: theme.bgElevated,
              icon: Icon(Icons.keyboard_arrow_down,
                  size: 18, color: theme.textSecondary),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              items: options
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _promptCard(YoUnMeThemeExtension theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: ProfilePalette.promptCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfilePalette.pink.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, size: 13,
                  color: ProfilePalette.pink),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'DATING PROMPT: "${_promptQuestionController.text.isEmpty ? 'THE KEY TO MY HEART IS...' : _promptQuestionController.text.toUpperCase()}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: ProfilePalette.pink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _inputField(
            label: 'Your Answer',
            controller: _promptAnswerController,
            theme: theme,
            maxLines: 2,
            hintText: 'Add an interesting conversation starter...',
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 4),
              iconColor: ProfilePalette.pink,
              collapsedIconColor: theme.textMuted,
              leading: Icon(Icons.edit_note, size: 16, color: theme.textMuted),
              title: Text(
                'Change prompt question',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              children: [
                _inputField(
                  label: 'Prompt Question',
                  controller: _promptQuestionController,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
