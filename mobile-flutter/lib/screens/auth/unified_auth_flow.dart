import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import 'onboarding_wizard_screen.dart';

/// ============================================================================
/// SYSTEM / DEVICE MAIL ACCOUNTS MODEL & DATA
/// ============================================================================
class SystemAccount {
  final String email;
  final String firstName;
  final String lastName;
  final String provider; // 'google' | 'apple'
  final String? avatarUrl;

  const SystemAccount({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.provider,
    this.avatarUrl,
  });

  String get displayName => '$firstName $lastName';
}

final List<SystemAccount> kSystemGoogleAccounts = [
  const SystemAccount(
    email: 'satyateja.dev@gmail.com',
    firstName: 'Satya Teja',
    lastName: 'Dev',
    provider: 'google',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
  ),
  const SystemAccount(
    email: 'younme.team@gmail.com',
    firstName: 'YoUnMe',
    lastName: 'Official',
    provider: 'google',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
  ),
  const SystemAccount(
    email: 'aarav.kapoor@gmail.com',
    firstName: 'Aarav',
    lastName: 'Kapoor',
    provider: 'google',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
  ),
];

final List<SystemAccount> kSystemAppleAccounts = [
  const SystemAccount(
    email: 'satyateja.apple@icloud.com',
    firstName: 'Satya Teja',
    lastName: 'V',
    provider: 'apple',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
  ),
  const SystemAccount(
    email: 'teja.creative@icloud.com',
    firstName: 'Teja',
    lastName: 'Verma',
    provider: 'apple',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
  ),
];

/// ============================================================================
/// THEMED SYSTEM ACCOUNT PICKER FOR GOOGLE & APPLE
/// ============================================================================
void showSystemAccountPicker(
  BuildContext context, {
  required String provider, // 'google' | 'apple'
  required void Function(SystemAccount account) onAccountSelected,
}) {
  final isApple = provider.toLowerCase() == 'apple';
  final accounts = isApple ? kSystemAppleAccounts : kSystemGoogleAccounts;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF131620),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x26FFFFFF)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isApple ? Icons.apple : Icons.g_mobiledata,
                      size: isApple ? 20 : 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isApple ? 'Sign in with Apple' : 'Choose a Google Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'to continue to YoUnMe Dating',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Account Items
              ...accounts.map(
                (acc) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191C24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0x33FF4D88),
                      backgroundImage: acc.avatarUrl != null ? NetworkImage(acc.avatarUrl!) : null,
                      child: acc.avatarUrl == null
                          ? Text(
                              acc.firstName[0].toUpperCase(),
                              style: const TextStyle(color: Color(0xFFFF8DA1), fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(
                      acc.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      acc.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFFF8DA1)),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onAccountSelected(acc);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Security reassurance pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 12, color: Color(0xFF38BDF8)),
                    SizedBox(width: 6),
                    Text(
                      'Safe & verified account login via YoUnMe Shield',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
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

/// Backwards compatible helper for existing callers
void showSystemGoogleAccounts(
  BuildContext context, {
  required void Function(String selectedEmail) onAccountSelected,
}) {
  showSystemAccountPicker(
    context,
    provider: 'google',
    onAccountSelected: (acc) => onAccountSelected(acc.email),
  );
}

/// ============================================================================
/// 1. UNIFIED IDENTIFIER ENTRY (MOBILE NUMBER OR EMAIL)
/// ============================================================================
class EnterIdentifierScreen extends StatefulWidget {
  final bool isPhone;
  final String? initialValue;
  final String? firstName;
  final String? lastName;
  final void Function(OnboardingProfileData)? onCompleteOnboarding;
  final VoidCallback? onGoToSignIn;

  const EnterIdentifierScreen({
    super.key,
    required this.isPhone,
    this.initialValue,
    this.firstName,
    this.lastName,
    this.onCompleteOnboarding,
    this.onGoToSignIn,
  });

  @override
  State<EnterIdentifierScreen> createState() => _EnterIdentifierScreenState();
}

class _EnterIdentifierScreenState extends State<EnterIdentifierScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue ?? (widget.isPhone ? '9876543210' : 'satyateja.dev@gmail.com'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    String val = _controller.text.trim();
    if (val.isEmpty) {
      val = widget.isPhone ? '9876543210' : 'satyateja.dev@gmail.com';
      _controller.text = val;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifyOtpAuthScreen(
          identifier: val,
          isPhone: widget.isPhone,
          firstName: widget.firstName,
          lastName: widget.lastName,
          onCompleteOnboarding: widget.onCompleteOnboarding,
          onGoToSignIn: widget.onGoToSignIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF8DA1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x40FF8DA1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFFF8DA1)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.isPhone ? 'STEP 1 OF 3 • MOBILE VERIFICATION' : 'STEP 1 OF 3 • EMAIL VERIFICATION',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFFFF8DA1),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      widget.isPhone ? 'Enter your mobile number 📱' : 'Enter your email address ✉️',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isPhone
                          ? "We'll send a 6-digit OTP code to verify your mobile number."
                          : "We'll send a 6-digit OTP code to your inbox to verify your email.",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // Input Field
                    Text(
                      widget.isPhone ? '📱 Mobile Number' : '✉️ Email Address',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                    ),
                    const SizedBox(height: 8),

                    if (widget.isPhone)
                      Row(
                        children: [
                          Container(
                            height: 50,
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
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF191C24),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0x1FFFFFFF)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter 10-digit number',
                                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x1FFFFFFF)),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'name@example.com',
                                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    // "Send OTP" Button
                    GestureDetector(
                      onTap: _handleSendOtp,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x52F43F5E),
                              blurRadius: 22,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Send OTP',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have an account? Sign in
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onGoToSignIn?.call();
                        },
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 2. UNIFIED OTP VERIFICATION SCREEN
/// ============================================================================
class VerifyOtpAuthScreen extends StatefulWidget {
  final String identifier;
  final bool isPhone;
  final String? firstName;
  final String? lastName;
  final void Function(OnboardingProfileData)? onCompleteOnboarding;
  final VoidCallback? onGoToSignIn;

  const VerifyOtpAuthScreen({
    super.key,
    required this.identifier,
    required this.isPhone,
    this.firstName,
    this.lastName,
    this.onCompleteOnboarding,
    this.onGoToSignIn,
  });

  @override
  State<VerifyOtpAuthScreen> createState() => _VerifyOtpAuthScreenState();
}

class _VerifyOtpAuthScreenState extends State<VerifyOtpAuthScreen> {
  final List<TextEditingController> _otpCtrls = List.generate(
    4,
    (i) => TextEditingController(text: ['2', '0', '2', '6'][i]),
  );
  int _timerSeconds = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _fillDemoCode() {
    final demo = ['2', '0', '2', '6'];
    for (int i = 0; i < 4; i++) {
      _otpCtrls[i].text = demo[i];
    }
    setState(() {});
  }

  void _handleVerify() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePasswordAuthScreen(
          identifier: widget.identifier,
          isPhone: widget.isPhone,
          firstName: widget.firstName,
          lastName: widget.lastName,
          onCompleteOnboarding: widget.onCompleteOnboarding,
          onGoToSignIn: widget.onGoToSignIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF8DA1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x40FF8DA1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFFF8DA1)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'STEP 2 OF 3 • VERIFICATION CODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFFFF8DA1),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Verify Verification Code 🛡️',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isPhone
                          ? 'Enter the 4-digit code sent to +91 ${widget.identifier}'
                          : 'Enter the 4-digit code sent to ${widget.identifier}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // 4 OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        return Container(
                          width: 58,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFF191C24),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _otpCtrls[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                            decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                            onChanged: (v) {
                              if (v.isNotEmpty && i < 3) FocusScope.of(context).nextFocus();
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Demo Auto-fill Button
                    Center(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF8DA1),
                          side: const BorderSide(color: Color(0x59FF8DA1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text('Auto-fill Demo Code (2026)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        onPressed: _fillDemoCode,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Countdown & Resend
                    Center(
                      child: Text(
                        _timerSeconds > 0 ? 'Resend code in 0:$_timerSeconds' : 'Resend code available now',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Verify Button
                    GestureDetector(
                      onTap: _handleVerify,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x52F43F5E),
                              blurRadius: 22,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verify & Continue',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 3. UNIFIED CREATE & CONFIRM PASSWORD SCREEN
/// ============================================================================
class CreatePasswordAuthScreen extends StatefulWidget {
  final String identifier;
  final bool isPhone;
  final String? firstName;
  final String? lastName;
  final void Function(OnboardingProfileData)? onCompleteOnboarding;
  final VoidCallback? onGoToSignIn;

  const CreatePasswordAuthScreen({
    super.key,
    required this.identifier,
    required this.isPhone,
    this.firstName,
    this.lastName,
    this.onCompleteOnboarding,
    this.onGoToSignIn,
  });

  @override
  State<CreatePasswordAuthScreen> createState() => _CreatePasswordAuthScreenState();
}

class _CreatePasswordAuthScreenState extends State<CreatePasswordAuthScreen> {
  final TextEditingController _passCtrl = TextEditingController(text: 'Secret@2026');
  final TextEditingController _confirmCtrl = TextEditingController(text: 'Secret@2026');
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final pass = _passCtrl.text.isNotEmpty ? _passCtrl.text : 'Secret@2026';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingWizardScreen(
          initialEmail: widget.isPhone ? null : widget.identifier,
          initialPhone: widget.isPhone ? widget.identifier : null,
          initialFirstName: widget.firstName,
          initialLastName: widget.lastName,
          initialPassword: pass,
          isPreVerified: true,
          onComplete: widget.onCompleteOnboarding,
          onGoToSignIn: widget.onGoToSignIn,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = _passCtrl.text.isNotEmpty && _passCtrl.text == _confirmCtrl.text;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF8DA1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x40FF8DA1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFFF8DA1)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'STEP 3 OF 3 • CREATE PASSWORD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFFFF8DA1),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Create Password 🔒',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set a strong password to secure your YoUnMe account (${widget.identifier}).',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // Password Label & Field
                    const Text('🔒 Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              controller: _passCtrl,
                              obscureText: !_showPass,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Create password'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showPass = !_showPass),
                            child: Icon(_showPass ? Icons.visibility : Icons.visibility_off, size: 18, color: const Color(0xFFFF8DA1)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Confirm Password Label & Field
                    const Text('🔒 Confirm Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1))),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              controller: _confirmCtrl,
                              obscureText: !_showConfirm,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Confirm password'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showConfirm = !_showConfirm),
                            child: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off, size: 18, color: const Color(0xFFFF8DA1)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Live Match Badge
                    Row(
                      children: [
                        Icon(
                          match ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 15,
                          color: match ? Colors.greenAccent : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          match ? '✓ Passwords match securely' : 'Enter matching passwords',
                          style: TextStyle(
                            fontSize: 12,
                            color: match ? Colors.greenAccent : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Continue to Onboarding Button
                    GestureDetector(
                      onTap: _handleContinue,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x52F43F5E),
                              blurRadius: 22,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Profile Setup',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
