import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import '../../data/profiles_data.dart';

class OnboardingWizardScreen extends StatefulWidget {
  final void Function(OnboardingProfileData)? onComplete;
  final VoidCallback? onBack;
  final VoidCallback? onGoToSignIn;

  const OnboardingWizardScreen({
    super.key,
    this.onComplete,
    this.onBack,
    this.onGoToSignIn,
  });

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 1; // 1 (1A), 1b (1B), 2, 3, 4, 5
  bool _isStep1B = false;

  // Step 1A & 1B State
  final TextEditingController _firstCtrl = TextEditingController(text: 'Aarav');
  final TextEditingController _lastCtrl = TextEditingController(text: 'Kapoor');
  final TextEditingController _emailCtrl = TextEditingController(text: 'aarav.kapoor@younme.love');
  final TextEditingController _phoneCtrl = TextEditingController(text: '98765 43210');
  final List<TextEditingController> _otpCtrls = [
    TextEditingController(text: '2'),
    TextEditingController(text: '0'),
    TextEditingController(text: '2'),
    TextEditingController(text: '6'),
  ];
  final TextEditingController _createPwCtrl = TextEditingController(text: 'password123');
  final TextEditingController _confirmPwCtrl = TextEditingController(text: 'password123');
  bool _showCreatePw = false;
  bool _showConfirmPw = false;
  int _otpTimer = 45;

  // Step 2 State
  String _birthDay = '15';
  String _birthMonth = '06';
  String _birthYear = '2000';
  String _gender = 'Male';
  String _orientation = 'Straight';
  String _primaryPhoto = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80';
  bool _autoEnhanced = true;

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

  void _handleNext() {
    if (_currentStep == 1 && !_isStep1B) {
      setState(() => _isStep1B = true);
      return;
    }
    if (_currentStep == 1 && _isStep1B) {
      setState(() {
        _currentStep = 2;
        _isStep1B = false;
      });
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
                    GestureDetector(
                      onTap: _handleBack,
                      child: Container(
                        height: 48,
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
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleNext,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x59FF4D88),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _currentStep == 5
                                ? 'Complete Setup & Start Swiping →'
                                : 'Continue →',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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
        _socialButton(Icons.g_mobiledata, 'Continue with Google'),
        const SizedBox(height: 10),
        _socialButton(Icons.apple, 'Continue with Apple'),
        const SizedBox(height: 10),
        _socialButton(Icons.facebook, 'Continue with Facebook'),
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

  Widget _socialButton(IconData icon, String label) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF191C24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
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
        ],
      ),
    );
  }

  // STEP 2: Basic Profile Details 💖
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Basic Profile Details 💖', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Introduce yourself with your birthdate, orientation, and primary photo.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 18),

        // Date of Birth
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📅 Date of Birth', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            const Text('24 yrs old • 18+ Verified ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _dobBox('Day', _birthDay, (v) => setState(() => _birthDay = v)),
            const SizedBox(width: 8),
            _dobBox('Month', _birthMonth, (v) => setState(() => _birthMonth = v)),
            const SizedBox(width: 8),
            _dobBox('Year', _birthYear, (v) => setState(() => _birthYear = v)),
          ],
        ),
        const SizedBox(height: 18),

        // I am a: Male | Female | Non-Binary
        const Text('I am a:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
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
        const SizedBox(height: 20),

        // Primary Profile Photo Box (180px height, rounded-20)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📷 Primary Profile Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x264ADE80),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Face Centered', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeProfileImage(
                  imageUrl: _primaryPhoto,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xD9000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tap to Change Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('✨ AI Enhanced', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFFFD700))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Demo Avatar Row
        const Text('Or select a demo avatar:', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _demoAvatars.map((url) {
            final active = _primaryPhoto == url;
            return GestureDetector(
              onTap: () => setState(() => _primaryPhoto = url),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? const Color(0xFFFF4D88) : const Color(0x26FFFFFF),
                    width: active ? 2 : 1,
                  ),
                ),
                child: SafeProfileImage(
                  imageUrl: url,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Auto-Enhance Photo Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Enhance Photo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Optimizes skin glow & lighting automatically', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Checkbox(
                value: _autoEnhanced,
                activeColor: const Color(0xFFFF4D88),
                onChanged: (v) => setState(() => _autoEnhanced = v ?? true),
              ),
            ],
          ),
        ),
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

        // Profession & Education 2-column
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profession', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
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
                      decoration: const InputDecoration(border: InputBorder.none),
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
                  const Text('Education', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
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
                      decoration: const InputDecoration(border: InputBorder.none),
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

        // City / Location + Auto-detect
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📍 City / Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
            GestureDetector(
              onTap: () => setState(() => _cityCtrl.text = 'Mumbai, Bandra West (GPS Active)'),
              child: const Text('☑️ Auto-detect GPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
            ),
          ],
        ),
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
            controller: _cityCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(border: InputBorder.none),
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
        const Text('Safety & Verification 🛡️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Protect yourself & gain high trust matching with biometric verification.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 18),

        // Blink Face Liveness Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x334ADE80)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.face, size: 18, color: Color(0xFFFF8DA1)),
                      SizedBox(width: 8),
                      Text('Blink Face Liveness', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x264ADE80),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x804ADE80)),
                    ),
                    child: const Text('✓ Verified ✓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4ADE80))),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Centered 110x140 oval photo reticle with #FF8DA1 border & glow
              Container(
                width: 110,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(55),
                  border: Border.all(color: const Color(0xFFFF8DA1), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4DFF8DA1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: SafeProfileImage(
                    imageUrl: _primaryPhoto,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x1AFF8DA1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4DFF8DA1)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Face Verified ✓ (Re-verify)',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Voice Prompt Verification Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF191C24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.mic, size: 16, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text('🎙️ Voice PIN Verification', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  Spacer(),
                  Text('Voice Verified ✓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0.3, 0.7, 0.9, 0.4, 0.8, 0.5, 0.3, 0.6, 0.8, 0.4]
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

        // Permissions Switches
        _permissionTile('Push Notifications', 'Real-time alerts for mutual matches & calls', _pushNotif, (v) => setState(() => _pushNotif = v)),
        const SizedBox(height: 8),
        _permissionTile('Live GPS Location', 'Precise distance matching within Bandra/Jubilee Hills', _liveGps, (v) => setState(() => _liveGps = v)),
        const SizedBox(height: 8),
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
