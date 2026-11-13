import 'package:flutter/material.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';

class EditProfileModalSheet extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileModalSheet({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileModalSheet> createState() => _EditProfileModalSheetState();
}

class _EditProfileModalSheetState extends State<EditProfileModalSheet> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _educationController;
  late TextEditingController _cityController;
  late TextEditingController _promptQuestionController;
  late TextEditingController _promptAnswerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(text: '${widget.profile.age}');
    _bioController = TextEditingController(text: widget.profile.bio);
    _professionController = TextEditingController(text: widget.profile.profession);
    _companyController = TextEditingController(text: widget.profile.company);
    _educationController = TextEditingController(text: widget.profile.education);
    _cityController = TextEditingController(text: widget.profile.city);
    _promptQuestionController = TextEditingController(
      text: widget.profile.personalPrompt['question'] ?? 'The key to my heart is...',
    );
    _promptAnswerController = TextEditingController(
      text: widget.profile.personalPrompt['answer'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
    final parsedAge = int.tryParse(_ageController.text.trim()) ?? widget.profile.age;

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : widget.profile.name,
      age: parsedAge,
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
    final isDark = context.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final maxHeight = MediaQuery.of(context).size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Pinned Header: Title & Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.borderSubtle, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: theme.textSecondary, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.flamePink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form Fields
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInputField(
                            label: 'Display Name',
                            controller: _nameController,
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildInputField(
                            label: 'Age',
                            controller: _ageController,
                            theme: theme,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      label: 'About Me (Bio)',
                      controller: _bioController,
                      theme: theme,
                      isDark: isDark,
                      maxLines: 4,
                      hintText: 'Share what makes you unique...',
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      label: 'Profession / Job Title',
                      controller: _professionController,
                      theme: theme,
                      isDark: isDark,
                      prefixIcon: Icons.work_outline,
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      label: 'Company / Workplace',
                      controller: _companyController,
                      theme: theme,
                      isDark: isDark,
                      prefixIcon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      label: 'Education / College',
                      controller: _educationController,
                      theme: theme,
                      isDark: isDark,
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      label: 'Location / City',
                      controller: _cityController,
                      theme: theme,
                      isDark: isDark,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    Divider(color: theme.borderSubtle),
                    const SizedBox(height: 12),

                    Text(
                      'Personal Prompt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildInputField(
                      label: 'Prompt Question',
                      controller: _promptQuestionController,
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),

                    _buildInputField(
                      label: 'Your Answer',
                      controller: _promptAnswerController,
                      theme: theme,
                      isDark: isDark,
                      maxLines: 2,
                      hintText: 'Add an interesting conversation starter...',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required YoUnMeThemeExtension theme,
    required bool isDark,
    IconData? prefixIcon,
    int maxLines = 1,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: maxLines > 1 ? 8 : 0, right: 8),
                  child: Icon(prefixIcon, size: 18, color: theme.textMuted),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: theme.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
