import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/discovery_connect_models.dart';
import '../../data/profiles_data.dart';
import '../../services/auth_service.dart';
import 'unified_auth_flow.dart';

class OnboardingWizardScreen extends StatefulWidget {
  final void Function(OnboardingProfileData)? onComplete;
  final VoidCallback? onBack;
  final VoidCallback? onGoToSignIn;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialPassword;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialAvatar;
  final bool isPreVerified;

  const OnboardingWizardScreen({
    super.key,
    this.onComplete,
    this.onBack,
    this.onGoToSignIn,
    this.initialEmail,
    this.initialPhone,
    this.initialPassword,
    this.initialFirstName,
    this.initialLastName,
    this.initialAvatar,
    this.isPreVerified = false,
  });

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 1; // 1 (1A), 1b (1B), 2, 3, 4, 5
  bool _isStep1B = false;

  // Step 1A & 1B State
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final List<TextEditingController> _otpCtrls = [
    TextEditingController(text: '2'),
    TextEditingController(text: '0'),
    TextEditingController(text: '2'),
    TextEditingController(text: '6'),
  ];
  late final TextEditingController _createPwCtrl;
  late final TextEditingController _confirmPwCtrl;
  bool _showCreatePw = false;
  bool _showConfirmPw = false;
  int _otpTimer = 45;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.initialFirstName ?? 'Aarav');
    _lastCtrl = TextEditingController(text: widget.initialLastName ?? 'Kapoor');
    _emailCtrl = TextEditingController(
      text: widget.initialEmail ?? 'aarav.kapoor@younme.love',
    );
    _phoneCtrl = TextEditingController(
      text: widget.initialPhone ?? '98765 43210',
    );
    final pw = widget.initialPassword ?? 'password123';
    _createPwCtrl = TextEditingController(text: pw);
    _confirmPwCtrl = TextEditingController(text: pw);
    if (widget.initialAvatar != null) {
      _primaryPhoto = widget.initialAvatar!;
    }
    if (widget.isPreVerified) {
      _currentStep = 2;
    }
  }

  // Step 2 State
  DateTime _selectedDob = DateTime(2000, 6, 15);
  String _birthDay = '15';
  String _birthMonth = '06';
  String _birthYear = '2000';
  String _gender = 'Male';
  String _orientation = 'Straight';
  String _primaryPhoto = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80';
  bool _autoEnhanced = true;
  bool _bitmojiGenerated = true;

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF43F5E),
            onPrimary: Colors.white,
            surface: Color(0xFF191C24),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _birthDay = picked.day.toString().padLeft(2, '0');
        _birthMonth = picked.month.toString().padLeft(2, '0');
        _birthYear = picked.year.toString();
      });
    }
  }

  String _formatDob() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[_selectedDob.month - 1];
    return '${_selectedDob.day} $m ${_selectedDob.year}';
  }

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - _selectedDob.year;
    if (now.month < _selectedDob.month || (now.month == _selectedDob.month && now.day < _selectedDob.day)) {
      age--;
    }
    return age;
  }

  void _openCitySearch() {
    final cities = [
      'Hyderabad',
      'Bhimavaram',
      'Visakhapatnam',
      'Bengaluru',
      'Chennai',
      'Mumbai',
      'Vijayawada',
      'Delhi',
      'Pune',
      'Kolkata',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131620),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = cities
                .where((c) => c.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Present City',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 18),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search city...',
                          hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                        ),
                        onChanged: (val) => setSheetState(() => query = val),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final c = filtered[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: Color(0xFFFF8DA1), size: 18),
                            title: Text(c, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            onTap: () {
                              setState(() => _cityCtrl.text = c);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final List<String> _demoAvatars = [
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=800&q=80',
  ];

  // Step 3 State
  String _intent = 'long-term';
  final Set<String> _selectedInterests = {'Music 🎵', 'Coffee ☕', 'Travel ✈️', 'Photography 📸'};
  final TextEditingController _customInterestCtrl = TextEditingController();

  final List<Map<String, String>> _intentOptions = [
    {'id': 'long-term', 'icon': '💍', 'title': 'Long-term relationship', 'desc': 'Seeking deep connection, loyalty & life partnership.'},
    {'id': 'short-term', 'icon': '🍷', 'title': 'Short-term dating', 'desc': 'Open to romance, fun dates & seeing where things lead.'},
    {'id': 'casual', 'icon': '🥂', 'title': 'Casual dating', 'desc': 'Lighthearted conversations & weekend spontaneous hangouts.'},
    {'id': 'friendship', 'icon': '✨', 'title': 'Friendship', 'desc': 'Meaningful platonic connections & shared passions.'},
    {'id': 'new-connections', 'icon': '🤝', 'title': 'New connections', 'desc': 'Expanding my circle and meeting interesting people.'},
    {'id': 'not-sure', 'icon': '💫', 'title': 'Not sure yet', 'desc': 'Open-minded and exploring what life brings.'},
    {'id': 'something-else', 'icon': '🌈', 'title': 'Something else', 'desc': 'Unique romantic or personal connection on my own terms.'},
  ];

  final List<String> _defaultInterests = [
    'Music 🎵',
    'Coffee ☕',
    'Travel ✈️',
    'Fitness 💪',
    'Photography 📸',
    'Foodie 🍕',
    'Movies 🎬',
    'Gaming 🎮',
    'Modern Art 🎨',
    'Reading 📚',
    'Hiking 🌿',
    'Tech & AI 💻',
  ];

  // Step 4 State
  final TextEditingController _professionCtrl = TextEditingController(text: 'UI/UX Architect');
  final TextEditingController _educationCtrl = TextEditingController(text: 'IIT Bombay');
  final TextEditingController _bioCtrl = TextEditingController(
    text: 'Passionate about clean design, acoustic sunsets, and cozy weekend cafes ✨',
  );
  final TextEditingController _cityCtrl = TextEditingController(text: 'Mumbai, Bandra West');
  RangeValues _ageRange = const RangeValues(21, 32);
  double _maxDistance = 25;

  // Step 5 State
  final bool _faceVerified = true;
  final bool _voiceVerified = true;
  String _whoCanMessage = 'matches'; // 'everyone' | 'matches' | 'verified'
  bool _pushNotif = true;
  bool _liveGps = true;
  bool _contactsSync = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    _createPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _customInterestCtrl.dispose();
    _professionCtrl.dispose();
    _educationCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  bool _isRegistering = false;

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191C24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33FF4D88)),
        ),
        title: const Row(
          children: [
            Icon(Icons.mark_email_unread_outlined, color: Color(0xFFFF8DA1), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Verify Your Email',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification email sent to:\n$email',
              style: const TextStyle(color: Color(0xFFFF8DA1), fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your inbox (and spam folder) and click the confirmation link to activate your account before signing in.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onGoToSignIn != null) {
                widget.onGoToSignIn!();
              } else {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0x26FF4D88),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(color: Color(0xFFFF8DA1), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignupStep() async {
    final email = _emailCtrl.text.trim();
    final password = _createPwCtrl.text;
    final confirmPassword = _confirmPwCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackBar('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Passwords do not match.');
      return;
    }

    if (_isRegistering) return; // Prevent duplicate requests
    setState(() => _isRegistering = true);

    try {
      final result = await AuthService.instance.signUp(
        email: email,
        password: password,
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isRegistering = false);

      if (!result.success) {
        final errorMsg = result.error ?? result.message;
        _showErrorSnackBar(errorMsg.isNotEmpty ? errorMsg : 'Registration failed. Please check your information.');
        return;
      }

      // If email confirmation is required:
      if (result.requiresEmailConfirmation || result.session == null) {
        _showEmailConfirmationDialog(email);
        return;
      }

      // If user is already confirmed (e.g. session returned)
      setState(() {
        _currentStep = 2;
        _isStep1B = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegistering = false);
      _showErrorSnackBar('Network error: ${e.toString()}');
    }
  }

  void _handleNext() {
    if (_currentStep == 1 && !_isStep1B) {
      if (widget.isPreVerified) {
        setState(() => _currentStep = 2);
        return;
      }
      final email = _emailCtrl.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _showErrorSnackBar('Please enter a valid email address.');
        return;
      }
      setState(() => _isStep1B = true);
      return;
    }
    if (_currentStep == 1 && _isStep1B) {
      _handleSignupStep();
      return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _handleBack() {
    if (_currentStep == 1 && _isStep1B) {
      setState(() => _isStep1B = false);
      return;
    }
    if (_currentStep > 1) {
      if (_currentStep == 2 && widget.isPreVerified) {
        setState(() => _currentStep = 1);
        return;
      }
      setState(() => _currentStep--);
    } else {
      widget.onBack?.call();
    }
  }

  void _finishOnboarding() {
    final profile = OnboardingProfileData(
      email: _emailCtrl.text.trim(),
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _createPwCtrl.text,
      birthDate: '$_birthYear-$_birthMonth-$_birthDay',
      gender: _gender,
      orientation: _orientation,
      primaryPhoto: _primaryPhoto,
      autoEnhanced: _autoEnhanced,
      intent: _intent,
      interests: _selectedInterests.toList(),
      profession: _professionCtrl.text.trim(),
      education: _educationCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      height: '5\'10"',
      languages: const ['English', 'Hindi'],
      bio: _bioCtrl.text.trim(),
      galleryPhotos: [_primaryPhoto],
      location: _cityCtrl.text.trim(),
      maxDistance: _maxDistance.round(),
      ageRangeMax: _ageRange.end.round(),
      allowNotifications: _pushNotif,
      allowLocation: _liveGps,
      whoCanMessage: _whoCanMessage,
      isVoiceVerified: _voiceVerified,
      isFaceVerified: _faceVerified,
      allowContactsSync: _contactsSync,
    );
    widget.onComplete?.call(profile);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainShellScreen(showStreakOnEntry: true),
      ),
      (route) => false,
    );
  }

  String _getStepTitle() {
    if (_currentStep == 1 && !_isStep1B) return "LET'S GET STARTED";
    if (_currentStep == 1 && _isStep1B) return "VERIFY & SECURITY";
    if (_currentStep == 2) return "PROFILE DETAILS";
    if (_currentStep == 3) return "INTENT & VIBE";
    if (_currentStep == 4) return "ENRICH STORY";
    return "SAFETY & VERIFY";
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _currentStep == 1
        ? (_isStep1B ? 0.25 : 0.15)
        : (_currentStep / 5.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Header on every step
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF131620),
                border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF8DA1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x40FF8DA1)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Color(0xFFFF8DA1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STEP $_currentStep OF 5',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8DA1),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _getStepTitle(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0x26FFFFFF),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4D88)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Sticky Bottom Nav on Steps 2-5 (and Step 1B)
            if (_currentStep > 1 || _isStep1B)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF131620),
                  border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
                ),
                child: Row(
                  children: [
                    if (_currentStep != 5) ...[
                      GestureDetector(
                        onTap: _handleBack,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0x1FFFFFFF)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: GestureDetector(
                        onTap: _isRegistering ? null : _handleNext,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x59F43F5E),
                                blurRadius: 18,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _isRegistering
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep == 5
                                          ? 'Enter YoUnMe'
                                          : _currentStep == 3
                                              ? 'Continue to Story'
                                              : (_currentStep == 1 && _isStep1B ? 'Create Account' : 'Continue'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
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

  Widget _buildCurrentStepContent() {
    if (_currentStep == 1 && !_isStep1B) return _buildStep1A();
    if (_currentStep == 1 && _isStep1B) return _buildStep1B();
    if (_currentStep == 2) return _buildStep2();
    if (_currentStep == 3) return _buildStep3();
    if (_currentStep == 4) return _buildStep4();
    return _buildStep5();
  }

  // STEP 1A: Name, Email, Phone, Socials
  Widget _buildStep1A() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Let's get started 👋",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your legal name & contact details to begin matching.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 20),

        // 2-column First & Last Name
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('👤 First Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _firstCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _lastCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ✉️ Email Address
        const Text('✉️ Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _emailCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 16),

        // 📱 Phone Number
        const Text('📱 Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF191C24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              ),
              alignment: Alignment.center,
              child: const Text('🇮🇳 +91', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF191C24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _phoneCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Continue Button ABOVE OR Divider
        GestureDetector(
          onTap: _handleNext,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59FF4D88),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 17, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // OR CONTINUE WITH divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: const Color(0x26FFFFFF))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              ),
            ),
            Expanded(child: Container(height: 1, color: const Color(0x26FFFFFF))),
          ],
        ),
        const SizedBox(height: 16),

        // 3 Full-width Social Cards
        _socialButton(
          Icons.g_mobiledata,
          'Continue with Google',
          onTap: () => showSystemAccountPicker(
            context,
            provider: 'google',
            onAccountSelected: _onSocialPicked,
          ),
        ),
        const SizedBox(height: 10),
        _socialButton(
          Icons.apple,
          'Continue with Apple',
          onTap: () => showSystemAccountPicker(
            context,
            provider: 'apple',
            onAccountSelected: _onSocialPicked,
          ),
        ),
        const SizedBox(height: 10),
        _socialButton(
          Icons.facebook,
          'Continue with Facebook',
          onTap: () {
            _onSocialPicked(
              const SystemAccount(
                email: 'aarav.fb@example.com',
                firstName: 'Aarav',
                lastName: 'Kapoor',
                provider: 'facebook',
                avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: widget.onGoToSignIn,
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Already have an account? ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  TextSpan(text: 'Sign in', style: TextStyle(color: Color(0xFFFF8DA1), fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSocialPicked(SystemAccount acc) {
    setState(() {
      _firstCtrl.text = acc.firstName;
      _lastCtrl.text = acc.lastName;
      _emailCtrl.text = acc.email;
      if (acc.avatarUrl != null) {
        _primaryPhoto = acc.avatarUrl!;
      }
      _currentStep = 2;
    });
  }

  Widget _socialButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191C24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: icon == Icons.g_mobiledata ? 28 : 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // STEP 1B: Verify & Secure Account (OTP + Password creation)
  Widget _buildStep1B() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x590F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verify & Secure Account 🛡️',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify your mobile number and set a secure password.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 18),

          // Inner OTP Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x66191C24),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🛡️ Verification Code (OTP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                    Text('Resend in 0:$_otpTimer', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Code sent to +91 ${_phoneCtrl.text}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                // 4 OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    return Container(
                      width: 52,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF131620),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF4D88)),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _otpCtrls[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _otpTimer = 45),
                    child: const Text("Didn't receive code? Resend Code", style: TextStyle(fontSize: 11.5, color: Color(0xFFFF8DA1))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 🔒 Create Password
          const Text('🔒 Create Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF191C24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _createPwCtrl,
                    obscureText: !_showCreatePw,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showCreatePw = !_showCreatePw),
                  child: Icon(_showCreatePw ? Icons.visibility : Icons.visibility_off, size: 18, color: const Color(0xFFFF8DA1)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 🔒 Confirm Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🔒 Confirm Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
              if (_createPwCtrl.text.isNotEmpty && _createPwCtrl.text == _confirmPwCtrl.text)
                const Text('✓ Passwords match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF191C24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _confirmPwCtrl,
                    obscureText: !_showConfirmPw,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showConfirmPw = !_showConfirmPw),
                  child: Icon(_showConfirmPw ? Icons.visibility : Icons.visibility_off, size: 18, color: const Color(0xFFFF8DA1)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: _isRegistering
                  ? null
                  : () {
                      if (widget.onGoToSignIn != null) {
                        widget.onGoToSignIn!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF8DA1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Basic Profile Details 💖
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Basic Profile Details 💖',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'Scan your face or upload a photo to generate your custom Bitmoji avatar.',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 18),

        // Bitmoji Avatar Generator Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x33FF4D88)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26FF4D88),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar Preview (Bitmoji style)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF4D88), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FF4D88),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(55),
                      child: SafeProfileImage(
                        imageUrl: _primaryPhoto,
                        width: 110,
                        height: 110,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Green Confirmation Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x264ADE80),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x804ADE80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Color(0xFF4ADE80)),
                    SizedBox(width: 5),
                    Text(
                      'Bitmoji avatar generated from your photo',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons: Scan Face & Upload Photo
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _primaryPhoto = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';
                          _bitmojiGenerated = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📸 Face scanned! Bitmoji avatar updated.')),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x26FF4D88),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x80FF4D88)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFFFF8DA1)),
                            SizedBox(width: 6),
                            Text(
                              'Scan Face',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _primaryPhoto = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80';
                          _bitmojiGenerated = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📁 Photo uploaded! Bitmoji avatar created.')),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x26FFFFFF)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Upload Photo',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Demo Avatar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _demoAvatars.map((url) {
                  final active = _primaryPhoto == url;
                  return GestureDetector(
                    onTap: () => setState(() => _primaryPhoto = url),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active ? const Color(0xFFFF4D88) : const Color(0x26FFFFFF),
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SafeProfileImage(imageUrl: url),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Below that: First Name and Last Name
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _firstCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'First Name'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _lastCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Last Name'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Below that: Date of Birth with Calendar Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📅 Date of Birth', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            Text('${_calculateAge()} yrs old • 18+ Verified ✓', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDateOfBirth,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF191C24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x26FFFFFF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDob(),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0x26FF4D88),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFFFF8DA1)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Below that: Gender selection (Male, Female, Non-Binary)
        const Text('Gender Selection', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 8),
        Row(
          children: [
            _genderPill('Male', '👨 Male'),
            const SizedBox(width: 8),
            _genderPill('Female', '👩 Female'),
            const SizedBox(width: 8),
            _genderPill('Non-Binary', '✨ Non-Binary'),
          ],
        ),
        const SizedBox(height: 18),

        // Sexual Orientation Dropdown
        const Text('Sexual Orientation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _orientation,
              dropdownColor: const Color(0xFF191C24),
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF8DA1)),
              items: ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Queer']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _orientation = v ?? 'Straight'),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dobBox(String label, String val, Function(String) onChanged) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191C24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: TextEditingController(text: val),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _genderPill(String key, String label) {
    final active = _gender == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0x33FF4D88) : const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? const Color(0xFFFF4D88) : const Color(0x1FFFFFFF),
              width: active ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? const Color(0xFFFF8DA1) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // STEP 3: Intentions & Interests 💫
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Intentions & Interests 💫', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('What brings you to YoUnMe? Select your relationship goal and interests.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 18),

        const Text('❤️ What are you looking for?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 10),

        // 2-column grid of all 7 intent cards
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _intentOptions.map((opt) {
            final active = _intent == opt['id'];
            return GestureDetector(
              onTap: () => setState(() => _intent = opt['id']!),
              child: Container(
                width: (MediaQuery.of(context).size.width - 50) / 2,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active ? const Color(0x2BFF4D88) : const Color(0xFF191C24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? const Color(0xFFFF4D88) : const Color(0x1FFFFFFF),
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opt['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                      opt['title']!,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opt['desc']!,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), height: 1.3),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // Interests Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🎨 Your Interests (${_selectedInterests.length} selected)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            const Text('Min 3 recommended', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 10),

        // Default & custom interests list
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._defaultInterests,
            ..._selectedInterests.where((i) => !_defaultInterests.contains(i)),
          ].map((interest) {
            final active = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (active) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? const Color(0x33FF4D88) : const Color(0xFF191C24),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? const Color(0xFFFF4D88) : const Color(0x1FFFFFFF),
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? const Color(0xFFFF8DA1) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Custom interest input + Add button
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF191C24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _customInterestCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type custom interest (e.g. Singing, Anime)',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final txt = _customInterestCtrl.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _selectedInterests.add(txt);
                    _customInterestCtrl.clear();
                  });
                }
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 4: Enrich Your Story 📖
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enrich Your Story 📖', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Add context about your career, location, and matching criteria.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 18),

        // Profession & Education 2-column (Optional)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('Profession ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                      Text('(Optional)', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _professionCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Profession (Optional)',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('Education ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                      Text('(Optional)', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _educationCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Education (Optional)',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // About Me (Bio)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('About Me (Bio)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            Text('${_bioCtrl.text.length}/300', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: TextField(
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 300,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),

        // City / Location + Auto-detect GPS + Modal City Search
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📍 City / Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _cityCtrl.text = 'Hyderabad (GPS Active)'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2638BDF8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x6638BDF8)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.my_location, size: 12, color: Color(0xFF38BDF8)),
                        SizedBox(width: 4),
                        Text('Auto GPS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _openCitySearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x26EC4899),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x66EC4899)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 12, color: Color(0xFFFF8DA1)),
                        SizedBox(width: 4),
                        Text('Search', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _openCitySearch,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF191C24),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tap to select or search city',
                      hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFFFF8DA1)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Discovery Sliders Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Maximum Match Age', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(
                    '${_ageRange.start.round()} - ${_ageRange.end.round()} yrs',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFF8DA1)),
                  ),
                ],
              ),
              RangeSlider(
                values: _ageRange,
                min: 18,
                max: 65,
                activeColor: const Color(0xFFFF4D88),
                inactiveColor: const Color(0x26FFFFFF),
                onChanged: (vals) => setState(() => _ageRange = vals),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Maximum Distance (km)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(
                    'Up to ${_maxDistance.round()} km',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFF8DA1)),
                  ),
                ],
              ),
              Slider(
                value: _maxDistance,
                min: 5,
                max: 100,
                activeColor: const Color(0xFFFF4D88),
                inactiveColor: const Color(0x26FFFFFF),
                onChanged: (v) => setState(() => _maxDistance = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 5: Safety & Verification 🛡️
  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Safety & Verification 🛡️',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'Protect yourself & gain high trust matching with biometric verification.',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 18),

        // Hero Card: Expanded Blink Face Liveness (takes roughly half screen height ~340px)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x40FF4D88), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FF4D88),
                blurRadius: 28,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row: Biometric shield + Title & verified status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0x26FF4D88),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x66FF4D88)),
                        ),
                        child: const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFFFF8DA1)),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blink Face Liveness',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '3D Anti-Spoofing Camera',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x2622C55E),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x8022C55E)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF4ADE80)),
                        SizedBox(width: 4),
                        Text(
                          'Verified Biometric',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF4ADE80)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Large Center Liveness Preview Container with Glowing Oval Halo Reticle
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Halo
                  Container(
                    width: 156,
                    height: 196,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(78),
                      gradient: const RadialGradient(
                        colors: [Color(0x59FF4D88), Colors.transparent],
                      ),
                    ),
                  ),
                  // Reticle Frame
                  Container(
                    width: 144,
                    height: 184,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(72),
                      border: Border.all(color: const Color(0xFFFF8DA1), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FF4D88),
                          blurRadius: 24,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: SafeProfileImage(
                        imageUrl: _primaryPhoto,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Corner target guides overlay
                  Positioned(
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x40FFFFFF)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility, size: 11, color: Color(0xFFFF8DA1)),
                          SizedBox(width: 4),
                          Text('Blink Detected', style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Pass Pill Overlay
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xE610131B),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x8022C55E)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, size: 12, color: Color(0xFF4ADE80)),
                          SizedBox(width: 5),
                          Text(
                            '100% Liveness Confirmed',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4ADE80)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Trigger Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Blink face liveness re-scan complete and verified!')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x26FF4D88),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x80FF4D88)),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFFFF8DA1)),
                      SizedBox(width: 8),
                      Text(
                        'Face Verified ✓ (Tap to Re-verify)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Voice Verification Card (Renamed from Voice PIN Verification)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x2638BDF8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0x1A38BDF8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mic_none_rounded, size: 17, color: Color(0xFF38BDF8)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voice Verification', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Anti-spoofing voiceprint analysis active & verified', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2622C55E),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x8022C55E)),
                    ),
                    child: const Text('Voice Verified ✓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0.3, 0.7, 0.9, 0.4, 0.8, 0.5, 0.3, 0.6, 0.8, 0.4, 0.9, 0.6, 0.3, 0.7]
                    .map(
                      (h) => Container(
                        width: 4,
                        height: 24 * h,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Who Can Message Me
        const Text('Who Can Message Me', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
        const SizedBox(height: 8),
        Row(
          children: [
            _messagePrefPill('everyone', 'Everyone'),
            const SizedBox(width: 8),
            _messagePrefPill('matches', 'Matches Only'),
            const SizedBox(width: 8),
            _messagePrefPill('verified', 'Verified Only 🛡️'),
          ],
        ),
        const SizedBox(height: 16),

        // Remaining discreet contacts switch
        _permissionTile('Add Friends by Contacts', 'Discover mutual acquaintances discreetly', _contactsSync, (v) => setState(() => _contactsSync = v)),
      ],
    );
  }

  Widget _messagePrefPill(String key, String label) {
    final active = _whoCanMessage == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _whoCanMessage = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0x33FF4D88) : const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFFFF4D88) : const Color(0x1FFFFFFF),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? const Color(0xFFFF8DA1) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionTile(String title, String subtitle, bool val, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191C24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Switch(
            value: val,
            activeColor: const Color(0xFFFF4D88),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
