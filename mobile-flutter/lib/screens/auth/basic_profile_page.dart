import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/theme_service.dart';
import '../../services/theme_provider.dart';
import 'in_app_camera_screen.dart';
import 'intentions_orientation_page.dart';

class BasicProfilePage extends StatefulWidget {
  final String? initialEmail;
  final String? initialPhone;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialAvatar;

  const BasicProfilePage({
    super.key,
    this.initialEmail,
    this.initialPhone,
    this.initialFirstName,
    this.initialLastName,
    this.initialAvatar,
  });

  @override
  State<BasicProfilePage> createState() => _BasicProfilePageState();
}

class _BasicProfilePageState extends State<BasicProfilePage> {
  late final TextEditingController _nameController;
  final ImagePicker _galleryPicker = ImagePicker();

  String _selectedOption = 'Bitmoji Avatar'; // 'Bitmoji Avatar' or 'Upload Photo'
  String? _photoPath;
  bool _avatarGenerated = false;
  DateTime? _dob;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final nameInit = [
      if (widget.initialFirstName != null && widget.initialFirstName!.isNotEmpty)
        widget.initialFirstName,
      if (widget.initialLastName != null && widget.initialLastName!.isNotEmpty)
        widget.initialLastName,
    ].join(' ');
    _nameController = TextEditingController(text: nameInit);
    if (widget.initialAvatar != null) {
      _photoPath = widget.initialAvatar;
      _avatarGenerated = true;
    }
  }

  // Opens ONLY Live Camera when clicking Scan Face
  Future<void> _scanFaceWithCamera() async {
    final resultPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const InAppCameraScreen(
          title: 'Scan Face',
          subtitle: 'Center your face in the frame to generate your Bitmoji avatar',
          actionLabel: 'Capture & Create Avatar',
        ),
      ),
    );

    if (resultPath != null && mounted) {
      setState(() {
        _photoPath = resultPath;
        _avatarGenerated = true;
      });
    }
  }

  // Opens Gallery ONLY when Upload Photo is chosen
  Future<void> _uploadPhotoFromDevice() async {
    final XFile? file = await _galleryPicker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() {
        _photoPath = file.path;
        _avatarGenerated = false;
      });
    }
  }

  Future<void> _pickDob(bool isDark) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22),
      firstDate: DateTime(1965),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) => Theme(
        data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
          colorScheme: (isDark
                  ? const ColorScheme.dark(primary: AppColors.flamePink)
                  : const ColorScheme.light(primary: AppColors.flamePink))
              .copyWith(
            surface: isDark ? AppColors.darkCard : Colors.white,
            onSurface: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  bool get _canProceed =>
      _nameController.text.trim().isNotEmpty &&
      _dob != null &&
      _gender != null &&
      _photoPath != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ImageProvider? _resolveAvatarImage(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (kIsWeb || path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = YoUnMeThemeScope.of(context);
    final currentThemeMode = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputFill = isDark ? const Color(0xFF16161D) : const Color(0xFFFDE8EE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Step 2 of 5 • Basic Profile',
          style: TextStyle(color: subTextColor, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your Identity',
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Personalize your avatar, details, and preferred visual theme.',
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // Mode Selector: Bitmoji Avatar vs Upload Photo
            Row(
              children: [
                Expanded(
                  child: _modeSelector(
                    'Bitmoji Avatar',
                    Icons.face_retouching_natural,
                    isDark,
                    inputFill,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _modeSelector(
                    'Upload Photo',
                    Icons.photo_library_rounded,
                    isDark,
                    inputFill,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Dynamic Card: Shows "Scan Face" button under Bitmoji Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.flamePink.withOpacity(0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.flamePink.withOpacity(isDark ? 0.08 : 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF23232E) : const Color(0xFFFCE4EC),
                      border: Border.all(
                        color: AppColors.flamePink.withOpacity(0.35),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _photoPath != null
                          ? Image(
                              image: _resolveAvatarImage(_photoPath!)!,
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.face_rounded,
                                  color: AppColors.flamePink,
                                  size: 42,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                _selectedOption == 'Bitmoji Avatar'
                                    ? Icons.face_rounded
                                    : Icons.add_a_photo_rounded,
                                color: AppColors.flamePink,
                                size: 42,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_selectedOption == 'Bitmoji Avatar') ...[
                    Text(
                      _avatarGenerated
                          ? 'Bitmoji Avatar Created!'
                          : 'Scan your face to generate your Bitmoji avatar',
                      style: TextStyle(
                        color: _avatarGenerated
                            ? (isDark ? Colors.greenAccent : Colors.green[700])
                            : subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.flamePink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.camera_front_rounded),
                      label: Text(
                          _avatarGenerated ? 'Scan Face Again' : 'Scan Face'),
                      onPressed: _scanFaceWithCamera,
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.flamePink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.upload_rounded),
                      label: const Text('Select Photo'),
                      onPressed: _uploadPhotoFromDevice,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),

            // First Name / Avatar Name
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'First Name / Avatar Name',
                labelStyle: TextStyle(color: subTextColor),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.flamePink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date of Birth
            GestureDetector(
              onTap: () => _pickDob(isDark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dob == null
                          ? 'Date of Birth (18+)'
                          : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                      style: TextStyle(
                        color: _dob == null ? subTextColor : textColor,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_month_rounded, color: AppColors.flamePink),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gender
            Text(
              'Gender',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: ['Man', 'Woman', 'Other'].map((g) {
                final selected = _gender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.flamePink : inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        g,
                        style: TextStyle(
                          color: selected ? Colors.white : subTextColor,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Theme Selection (Dark, Light, System Default) ───
            Row(
              children: [
                const Icon(Icons.palette_rounded, color: AppColors.flamePink, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Theme Appearance',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose Dark, Light, or follow your System settings',
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _themeOptionCard(
                  title: 'Dark',
                  subtitle: 'Midnight Luxe',
                  icon: Icons.dark_mode_rounded,
                  active: currentThemeMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(width: 10),
                _themeOptionCard(
                  title: 'Light',
                  subtitle: 'Blush Warm',
                  icon: Icons.light_mode_rounded,
                  active: currentThemeMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 10),
                _themeOptionCard(
                  title: 'System',
                  subtitle: 'Device Auto',
                  icon: Icons.brightness_auto_rounded,
                  active: currentThemeMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed ? AppColors.flamePink : (isDark ? Colors.grey[850] : Colors.grey[300]),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _canProceed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IntentionsOrientationPage()),
                        );
                      }
                    : null,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _canProceed ? Colors.white : (isDark ? Colors.white38 : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeSelector(String title, IconData icon, bool isDark, Color inputFill) {
    final active = _selectedOption == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.flamePink : inputFill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextSecondary), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool active,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? const Color(0xFF261430) : const Color(0xFFFDE8EE))
                : (isDark ? const Color(0xFF16161D) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.flamePink : (isDark ? Colors.white12 : const Color(0xFFFCD0DF)),
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.flamePink.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? AppColors.flamePink : (isDark ? Colors.white60 : AppColors.lightTextSecondary),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: active
                      ? (isDark ? Colors.white : AppColors.flamePink)
                      : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: active
                      ? (isDark ? AppColors.flameSunset : AppColors.flamePink)
                      : (isDark ? Colors.grey[500] : AppColors.lightTextMuted),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
