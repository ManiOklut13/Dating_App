import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BasicProfileStep extends StatefulWidget {
  final VoidCallback onContinue;

  const BasicProfileStep({super.key, required this.onContinue});

  @override
  State<BasicProfileStep> createState() => _BasicProfileStepState();
}

class _BasicProfileStepState extends State<BasicProfileStep> {
  final TextEditingController _nameController = TextEditingController();
  String? _photoPath;
  String? _selectedAvatarAsset;

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  String? _ageErrorMessage;

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

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
        _selectedAvatarAsset = null; // Clear avatar if photo is chosen
      });
    }
  }

  void _selectBitmojiAvatar() {
    setState(() {
      _selectedAvatarAsset = 'assets/avatars/default_bitmoji.png';
      _photoPath = null;
    });
  }

  ImageProvider? _resolveImage(String path) {
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

    // Valid profile -> proceed to next step
    widget.onContinue();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2 of 5 • Basic Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Picture or Avatar',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // DISTINCT UI FOR BITMOJI AVATAR VS UPLOAD PHOTO
            Row(
              children: [
                // 1. Bitmoji Avatar Option (Pill / Gradient Badge Style)
                Expanded(
                  child: GestureDetector(
                    onTap: _selectBitmojiAvatar,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedAvatarAsset != null
                              ? [Colors.purple.shade400, Colors.deepPurple.shade700]
                              : [Colors.purple.shade50, Colors.deepPurple.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedAvatarAsset != null
                              ? Colors.deepPurple
                              : Colors.purple.shade200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.face_retouching_natural,
                              size: 32,
                              color: Colors.deepPurple.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Bitmoji Avatar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedAvatarAsset != null
                                  ? Colors.white
                                  : Colors.deepPurple.shade900,
                            ),
                          ),
                          Text(
                            'Create / Pick',
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedAvatarAsset != null
                                  ? Colors.white70
                                  : Colors.deepPurple.shade400,
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
                    onTap: _pickPhoto,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _photoPath != null
                              ? theme.primaryColor
                              : Colors.grey.shade400,
                          width: 1.5,
                        ),
                        image: _photoPath != null
                            ? DecorationImage(
                                image: _resolveImage(_photoPath!)!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _photoPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 28,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Upload Photo',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'From Gallery',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your first name or nick name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 24),

            // DATE OF BIRTH (Removed "18+" text next to label)
            Text(
              'Date of Birth',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // ADVANCED SELECTOR: Separate Day, Month & Year Pickers (No endless scrolling)
            Row(
              children: [
                // Day Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDay != null && _days.contains(_selectedDay)
                        ? _selectedDay
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index]),
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

                // Year Dropdown (Lists all years down to 1940)
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ageErrorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // NOTE: Theme Appearance section removed from Step 2 and moved to Step 5

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
