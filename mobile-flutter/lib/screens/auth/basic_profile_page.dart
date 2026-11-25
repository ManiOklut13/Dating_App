import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/theme_service.dart';
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

  String? _photoPath;
  String? _selectedAvatarAsset;
  bool _avatarGenerated = false;

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  String? _ageErrorMessage;
  String? _gender = 'Man';

  final List<String> _months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Generates years from current year down to 1940
  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1940 + 1, (index) => currentYear - index);
  }

  // Dynamically calculates valid days for the selected month & year
  List<int> get _days {
    if (_selectedYear == null || _selectedMonth == null) {
      return List.generate(31, (index) => index + 1);
    }
    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear!, _selectedMonth!);
    return List.generate(daysInMonth, (index) => index + 1);
  }

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

  // Opens Live Camera to generate Bitmoji avatar
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
        _selectedAvatarAsset = 'bitmoji';
        _avatarGenerated = true;
      });
    } else if (mounted) {
      setState(() {
        _selectedAvatarAsset = 'assets/avatars/default_bitmoji.png';
        _avatarGenerated = true;
      });
    }
  }

  // Opens Gallery ONLY when Upload Photo is chosen
  Future<void> _uploadPhotoFromDevice() async {
    final XFile? file = await _galleryPicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null && mounted) {
      setState(() {
        _photoPath = file.path;
        _selectedAvatarAsset = null;
        _avatarGenerated = false;
      });
    }
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

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _handleContinue() {
    setState(() => _ageErrorMessage = null);

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your First Name or Nick Name')),
      );
      return;
    }

    if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) {
      setState(() {
        _ageErrorMessage = 'Please select your complete Date of Birth.';
      });
      return;
    }

    final dob = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
    if (dob.isAfter(DateTime.now())) {
      setState(() {
        _ageErrorMessage = 'Date of birth cannot be in the future.';
      });
      return;
    }

    final age = _calculateAge(dob);
    if (age < 18) {
      setState(() {
        _ageErrorMessage =
            'Age requirement not met. You must be 18 or older to join this dating app.';
      });
      return;
    }

    if (_photoPath == null && _selectedAvatarAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a Bitmoji avatar or upload a photo')),
      );
      return;
    }

    // Valid -> proceed to Step 3 (Intentions & Orientation)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IntentionsOrientationPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputFill = isDark ? const Color(0xFF16161D) : const Color(0xFFFDE8EE);

    final isAvatarSelected = _selectedAvatarAsset != null;
    final isPhotoSelected = _photoPath != null && _selectedAvatarAsset == null;

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
              'Personalize your avatar, details, and birth date.',
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Text(
              'Profile Picture or Avatar',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // DISTINCT UI FOR BITMOJI AVATAR VS UPLOAD PHOTO
            Row(
              children: [
                // 1. Bitmoji Avatar Option (Pill / Gradient Badge Style)
                Expanded(
                  child: GestureDetector(
                    onTap: _scanFaceWithCamera,
                    child: Container(
                      height: 145,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAvatarSelected
                              ? [const Color(0xFF8B1E62), const Color(0xFFFF2A6D)]
                              : (isDark
                                  ? [const Color(0xFF2B1238), const Color(0xFF1E1026)]
                                  : [Colors.purple.shade50, Colors.pink.shade50]),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAvatarSelected
                              ? AppColors.flamePink
                              : (isDark ? Colors.white12 : Colors.purple.shade200),
                          width: isAvatarSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: isAvatarSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.flamePink.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvatarSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF331742) : Colors.white),
                              border: Border.all(
                                color: isAvatarSelected
                                    ? AppColors.flamePink
                                    : (isDark ? Colors.white24 : Colors.purple.shade200),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.face_retouching_natural,
                              size: 32,
                              color: isAvatarSelected
                                  ? AppColors.flamePink
                                  : (isDark ? Colors.white : AppColors.flamePurple),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _avatarGenerated ? 'Bitmoji Created!' : 'Bitmoji Avatar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isAvatarSelected
                                  ? Colors.white
                                  : textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _avatarGenerated ? 'Tap to Retake' : 'Create / Scan',
                            style: TextStyle(
                              fontSize: 12,
                              color: isAvatarSelected
                                  ? Colors.white70
                                  : subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Upload Photo Option (Camera / Gallery Frame Style)
                Expanded(
                  child: GestureDetector(
                    onTap: _uploadPhotoFromDevice,
                    child: Container(
                      height: 145,
                      decoration: BoxDecoration(
                        color: isPhotoSelected ? null : inputFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPhotoSelected
                              ? AppColors.flamePink
                              : (isDark ? Colors.white12 : Colors.grey.shade400),
                          width: isPhotoSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: isPhotoSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.flamePink.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                        image: isPhotoSelected
                            ? DecorationImage(
                                image: _resolveAvatarImage(_photoPath!)!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: !isPhotoSelected
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? cardColor : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 26,
                                    color: AppColors.flamePink,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload Photo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'From Gallery',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // REPLACED LABEL: First Name / Nick Name
            Text(
              'First Name / Nick Name',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Enter your first name or nick name',
                hintStyle: TextStyle(color: subTextColor.withOpacity(0.6)),
                filled: true,
                fillColor: inputFill,
                prefixIcon: Icon(Icons.person_outline, color: subTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.flamePink, width: 1.8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // DATE OF BIRTH (Removed "18+" helper text next to label)
            Text(
              'Date of Birth',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // ADVANCED 3-COLUMN DROPDOWN SELECTOR (Day, Month, Year)
            Row(
              children: [
                // Day Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDay != null && _days.contains(_selectedDay)
                        ? _selectedDay
                        : null,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Day',
                      labelStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.flamePink, width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: _days
                        .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text(day.toString().padLeft(2, '0')),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDay = val),
                  ),
                ),
                const SizedBox(width: 8),

                // Month Dropdown
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Month',
                      labelStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.flamePink, width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index], overflow: TextOverflow.ellipsis),
                      );
                    }),
                    onChanged: (val) {
                      setState(() {
                        _selectedMonth = val;
                        if (_selectedDay != null && _selectedDay! > _days.length) {
                          _selectedDay = _days.length;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Year Dropdown (all years down to 1940)
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Year',
                      labelStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.flamePink, width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: _years
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedYear = val;
                        if (_selectedDay != null && _selectedDay! > _days.length) {
                          _selectedDay = _days.length;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            // UNDER-18 VALIDATION ERROR BANNER
            if (_ageErrorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(isDark ? 0.15 : 1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ageErrorMessage!,
                        style: TextStyle(
                          color: isDark ? Colors.red.shade300 : Colors.red.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Gender Selector
            Text(
              'Gender',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
                        border: Border.all(
                          color: selected
                              ? AppColors.flamePink
                              : (isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
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

            // NOTE: Theme Appearance removed from Step 2 and placed on Step 5 (FinalOnboardingStep)

            const SizedBox(height: 36),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flamePink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _handleContinue,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
