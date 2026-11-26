import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'full_page_avatar_camera.dart';

class BasicProfileStep extends StatefulWidget {
  final VoidCallback onContinue;

  const BasicProfileStep({super.key, required this.onContinue});

  @override
  State<BasicProfileStep> createState() => _BasicProfileStepState();
}

class _BasicProfileStepState extends State<BasicProfileStep> {
  final TextEditingController _nameController = TextEditingController();
  String? _uploadedPhotoPath;
  String? _bitmojiCapturedPath;
  DateTime? _selectedDob;
  String? _ageErrorMessage;

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
        _uploadedPhotoPath = null;
      });
    }
  }

  Future<void> _pickGalleryPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _uploadedPhotoPath = picked.path;
        _bitmojiCapturedPath = null;
      });
    }
  }

  ImageProvider? _resolveImage(String path) {
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
      appBar: AppBar(title: const Text('Step 2 of 5 • Create Your Identity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Identity Style',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // DISTINCT UI: Bitmoji Avatar (Half-Page Camera) vs Upload Photo
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openFullPageBitmojiCamera,
                    child: Container(
                      height: 145,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple.shade500, Colors.indigo.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.25),
                            blurRadius: 8,
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
                                      image: _resolveImage(_bitmojiCapturedPath!)!,
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
                          const Text(
                            'Bitmoji Avatar',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                Expanded(
                  child: GestureDetector(
                    onTap: _pickGalleryPhoto,
                    child: Container(
                      height: 145,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        image: _uploadedPhotoPath != null
                            ? DecorationImage(
                                image: _resolveImage(_uploadedPhotoPath!)!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _uploadedPhotoPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add_photo_alternate_outlined,
                                      size: 28, color: theme.primaryColor),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Upload Photo',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'From Device',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // First Name / Nick Name
            Text(
              'First Name / Nick Name',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter first name or nick name',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // SINGLE CALENDAR TAB FOR DATE OF BIRTH (No "18+" text)
            Text(
              'Date of Birth',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _ageErrorMessage != null ? Colors.red : Colors.grey.shade400,
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
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
                          color: _selectedDob != null
                              ? theme.textTheme.bodyLarge?.color
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),

            if (_ageErrorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _ageErrorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
    final today = DateTime.now();
    final years = List.generate(today.year - 1940 + 1, (i) => today.year - i);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) _selectedDay = daysInMonth;

    final firstWeekday = DateTime(_selectedYear, _selectedMonth, 1).weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Date of Birth',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            style: TextStyle(color: isFutureMonth ? Colors.grey : null),
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
                            child: Text(d,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                                  ? Colors.grey.shade400
                                  : isSelected
                                      ? Colors.white
                                      : null,
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
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
