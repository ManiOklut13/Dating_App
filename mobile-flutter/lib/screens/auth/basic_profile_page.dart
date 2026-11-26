import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/theme_service.dart';
import 'full_page_avatar_camera.dart';
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
  String? _bitmojiCapturedPath;
  bool _avatarGenerated = false;
  DateTime? _selectedDob;
  String? _ageErrorMessage;
  String? _gender = 'Man';

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
      _bitmojiCapturedPath = widget.initialAvatar;
      _avatarGenerated = true;
    }
  }

  // Opens full-page camera with native aspect ratio for Bitmoji Avatar
  Future<void> _openFullPageBitmojiCamera() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const FullPageAvatarCamera()),
    );

    if (result != null && mounted) {
      final path = result is File ? result.path : result.toString();
      setState(() {
        _bitmojiCapturedPath = path;
        _photoPath = null;
        _avatarGenerated = true;
      });
    }
  }

  // Opens Gallery ONLY when Upload Photo is chosen
  Future<void> _uploadPhotoFromDevice() async {
    final XFile? file = await _galleryPicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() {
        _photoPath = file.path;
        _bitmojiCapturedPath = null;
        _avatarGenerated = false;
      });
    }
  }

  // Opens user-friendly Calendar Modal with quick Year & Month selectors + Calendar Grid
  Future<void> _openAdvancedCalendarModal() async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => _AdvancedCalendarDialog(
        initialDate: _selectedDob ?? DateTime(2000, 1, 1),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
        _ageErrorMessage = null;
      });
    }
  }

  ImageProvider? _resolveAvatarImage(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (kIsWeb ||
        path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:')) {
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
        const SnackBar(content: Text('Please enter your First Name / Nick Name')),
      );
      return;
    }

    if (_selectedDob == null) {
      setState(() => _ageErrorMessage = 'Please select your Date of Birth.');
      return;
    }

    if (_calculateAge(_selectedDob!) < 18) {
      setState(() {
        _ageErrorMessage =
            'Your age is under 18. Minors are not allowed to use this dating app.';
      });
      return;
    }

    if (_photoPath == null && _bitmojiCapturedPath == null) {
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

    final isAvatarSelected = _bitmojiCapturedPath != null;
    final isPhotoSelected = _photoPath != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Step 2 of 5 • Create Your Identity',
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
              'Choose Identity Style',
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use a quick half-screen camera scan for your Bitmoji avatar or upload a photo.',
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // DISTINCT UI: Bitmoji Avatar (Half-Page Camera) vs Upload Photo
            Row(
              children: [
                // 1. Bitmoji Avatar Option (Gradient Card + Full-Page Camera)
                Expanded(
                  child: GestureDetector(
                    onTap: _openFullPageBitmojiCamera,
                    child: Container(
                      height: 148,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAvatarSelected
                              ? [const Color(0xFF8B1E62), const Color(0xFFFF2A6D)]
                              : [Colors.deepPurple.shade500, Colors.indigo.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isAvatarSelected ? AppColors.flamePink : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isAvatarSelected ? AppColors.flamePink : Colors.deepPurple)
                                .withOpacity(0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: _bitmojiCapturedPath != null
                                  ? Image(
                                      image: _resolveAvatarImage(_bitmojiCapturedPath!)!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.face_retouching_natural,
                                        size: 32,
                                        color: Colors.deepPurple.shade700,
                                      ),
                                    )
                                  : Icon(
                                      Icons.face_retouching_natural,
                                      size: 32,
                                      color: Colors.deepPurple.shade700,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _avatarGenerated ? 'Avatar Ready' : 'Bitmoji Avatar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Quick Half-Cam',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Upload Photo Option (Dropzone Card)
                Expanded(
                  child: GestureDetector(
                    onTap: _uploadPhotoFromDevice,
                    child: Container(
                      height: 148,
                      decoration: BoxDecoration(
                        color: isPhotoSelected ? null : inputFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPhotoSelected
                              ? AppColors.flamePink
                              : (isDark ? Colors.white24 : Colors.grey.shade400),
                          width: isPhotoSelected ? 2.2 : 1.4,
                        ),
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
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 28,
                                    color: AppColors.flamePink,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload Photo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'From Device',
                                  style: TextStyle(color: subTextColor, fontSize: 12),
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

            // First Name / Nick Name
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
                hintText: 'Enter first name or nick name',
                hintStyle: TextStyle(color: subTextColor.withOpacity(0.6)),
                filled: true,
                fillColor: inputFill,
                prefixIcon: Icon(Icons.badge_outlined, color: subTextColor),
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

            // SINGLE CALENDAR TAB FOR DATE OF BIRTH (No "18+" text)
            Text(
              'Date of Birth',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus(); // Dismiss keyboard if open
                _openAdvancedCalendarModal();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _ageErrorMessage != null
                        ? Colors.red
                        : (isDark ? Colors.white12 : Colors.grey.shade400),
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDob != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedDob!)
                            : 'Select Date, Month & Year',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              _selectedDob != null ? FontWeight.w600 : FontWeight.normal,
                          color: _selectedDob != null ? textColor : subTextColor,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
                  ],
                ),
              ),
            ),

            // UNDER-18 VALIDATION ERROR BANNER
            if (_ageErrorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(isDark ? 0.15 : 1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
                    const SizedBox(width: 8),
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

/// Advanced Interactive Calendar Dialog (Month Dropdown + Year Dropdown till Today + Day Grid)
class _AdvancedCalendarDialog extends StatefulWidget {
  final DateTime initialDate;

  const _AdvancedCalendarDialog({required this.initialDate});

  @override
  State<_AdvancedCalendarDialog> createState() => _AdvancedCalendarDialogState();
}

class _AdvancedCalendarDialogState extends State<_AdvancedCalendarDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final List<String> _months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final years = List.generate(today.year - 1940 + 1, (i) => today.year - i);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) _selectedDay = daysInMonth;

    final firstWeekday = DateTime(_selectedYear, _selectedMonth, 1).weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF16161D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Date of Birth',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 14),

              // Quick Month & Year Selectors at Top
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: List.generate(12, (idx) {
                        final m = idx + 1;
                        final isFutureMonth = _selectedYear == today.year && m > today.month;
                        return DropdownMenuItem(
                          value: m,
                          enabled: !isFutureMonth,
                          child: Text(
                            _months[idx],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isFutureMonth
                                  ? Colors.grey
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMonth = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: years
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedYear = val;
                            if (_selectedYear == today.year && _selectedMonth > today.month) {
                              _selectedMonth = today.month;
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Weekday Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Explicit Bounded Height for Calendar Grid (Fixes Dialog Render Crash)
              SizedBox(
                height: rowCount * 42.0,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) return const SizedBox.shrink();
                    final day = index - firstWeekday + 1;
                    final candidateDate = DateTime(_selectedYear, _selectedMonth, day);
                    final isFuture = candidateDate.isAfter(today);
                    final isSelected = day == _selectedDay;

                    return GestureDetector(
                      onTap: isFuture ? null : () => setState(() => _selectedDay = day),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isFuture
                                  ? Colors.grey.shade600
                                  : isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 42),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        DateTime(_selectedYear, _selectedMonth, _selectedDay),
                      );
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
