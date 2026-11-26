import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String identifier, String password)? onLogin;
  final VoidCallback? onGoToSignUp;

  const SignInScreen({
    super.key,
    this.onBack,
    this.onLogin,
    this.onGoToSignUp,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _idCtrl = TextEditingController(text: 'aarav.kapoor@younme.love');
  final TextEditingController _pwCtrl = TextEditingController(text: 'password123');
  bool _showPw = false;
  bool _remember = true;
  String _errorMessage = '';
  bool _isSubmitting = false;

  // 3-Step Forgot Password Flow (0 = Login, 1 = Identifier, 2 = 6-digit OTP, 3 = New Password)
  int _recoveryStep = 0;
  final TextEditingController _recIdCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final TextEditingController _newPwCtrl = TextEditingController();
  final TextEditingController _confirmPwCtrl = TextEditingController();
  final FocusNode _newPwFocusNode = FocusNode();
  bool _showNewPw = false;
  bool _showConfirmPw = false;
  // int _otpCountdown = 45;

  @override
  void initState() {
    super.initState();
    _newPwFocusNode.addListener(_onNewPwStateChanged);
    _newPwCtrl.addListener(_onNewPwStateChanged);
    _confirmPwCtrl.addListener(_onNewPwStateChanged);
  }

  void _onNewPwStateChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasMinLength => _newPwCtrl.text.length >= 8;
  bool get _hasUppercase => _newPwCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _newPwCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPwCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _newPwCtrl.text
      .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\];~`+=]'));

  int get _metPasswordRulesCount {
    int count = 0;
    if (_hasMinLength) count++;
    if (_hasUppercase) count++;
    if (_hasLowercase) count++;
    if (_hasNumber) count++;
    if (_hasSpecialChar) count++;
    return count;
  }

  bool get _shouldShowRecoveryRules =>
      _newPwFocusNode.hasFocus || _newPwCtrl.text.isNotEmpty;

  bool get _isNewPwStrong => _metPasswordRulesCount == 5;

  bool get _recoveryPasswordsMatch =>
      _confirmPwCtrl.text.isNotEmpty &&
      _confirmPwCtrl.text == _newPwCtrl.text;

  bool get _canSaveRecoveryPassword =>
      _isNewPwStrong && _recoveryPasswordsMatch;

  @override
  void dispose() {
    _newPwFocusNode.removeListener(_onNewPwStateChanged);
    _newPwCtrl.removeListener(_onNewPwStateChanged);
    _confirmPwCtrl.removeListener(_onNewPwStateChanged);
    _newPwFocusNode.dispose();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _recIdCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _errorMessage = '');
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (id.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Email or Phone Number.');
      return;
    }
    if (pw.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onLogin?.call(id, pw);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Subtle ambient top-right accent highlight
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(isDark ? 0.14 : 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar: < Back Button + Header Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_recoveryStep > 0) {
                            setState(() => _recoveryStep = 0);
                          } else {
                            widget.onBack?.call();
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _recoveryStep == 0 ? 'YOUNME SIGN IN' : 'PASSWORD RECOVERY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: _recoveryStep == 0
                        ? _buildLoginForm(theme, isDark)
                        : _buildRecoveryFlow(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, bool isDark) {
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Subtle Brand Pill Highlight
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'YoUnMe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'Welcome back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue your matches and conversations.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Email or Phone Field
        Text(
          'Email or Phone',
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _idCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 18),

        // Password Field
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pwCtrl,
          obscureText: !_showPw,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _showPw
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _showPw = !_showPw),
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() {
              _recoveryStep = 1;
              _recIdCtrl.text = _idCtrl.text;
            }),
            child: Text(
              'Forgot password?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Remember me row
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _remember,
                activeColor: theme.colorScheme.primary,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (v) => setState(() => _remember = v ?? true),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me on this device',
              style: TextStyle(fontSize: 12.5, color: subTextColor),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Primary Sign-In Button
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleLogin,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text('Sign In'),
        ),
        const SizedBox(height: 28),

        // Don't have an account? Create Account
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: subTextColor),
            ),
            GestureDetector(
              onTap: widget.onGoToSignUp,
              child: Text(
                'Create Account',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 3-Step Password Recovery UI
  Widget _buildRecoveryFlow() {
    if (_recoveryStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Reset Password 🔑',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Step 1 of 3: Enter your registered Email or Phone number to receive a 6-digit recovery OTP.',
            style: TextStyle(fontSize: 13, color: Color(0xFFE2C0CE), height: 1.4),
          ),
          const SizedBox(height: 24),

          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0x8C2B091C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x38FF8DA1)),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _recIdCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Email or Phone Number',
                hintStyle: TextStyle(color: Color(0x66FF8DA1), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              if (_recIdCtrl.text.trim().isEmpty) return;
              setState(() => _recoveryStep = 2);
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Send Verification Code →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else if (_recoveryStep == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Enter 6-Digit OTP 🛡️',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 2 of 3: Code sent to ${_recIdCtrl.text}. Enter the 6 digits below.',
            style: const TextStyle(fontSize: 13, color: Color(0xFFE2C0CE), height: 1.4),
          ),
          const SizedBox(height: 24),

          // 6 OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (idx) {
              return Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x8C2B091C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x66FF8DA1)),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _otpCtrls[idx],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && idx < 5) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => setState(() => _recoveryStep = 3),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Verify & Proceed →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final headingColor = isDark ? Colors.white : Colors.black87;
      final subColor = isDark ? const Color(0xFFE2C0CE) : Colors.grey.shade700;
      final fieldBg =
          isDark ? const Color(0x8C2B091C) : Colors.grey.shade100;
      final fieldBorder =
          isDark ? const Color(0x38FF8DA1) : Colors.grey.shade300;
      final fieldTextColor = isDark ? Colors.white : Colors.black87;
      final metCount = _metPasswordRulesCount;
      final strengthColor = metCount <= 2
          ? Colors.orangeAccent
          : (metCount < 5 ? Colors.amber : Colors.green);
      final strengthLabel = metCount <= 2
          ? 'Weak'
          : (metCount < 5 ? 'Getting Stronger' : 'Strong Password');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'Create New Password 🔒',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 3 of 3: Create a strong password meeting all 5 combinations.',
            style: TextStyle(fontSize: 13, color: subColor, height: 1.4),
          ),
          const SizedBox(height: 20),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fieldBorder),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _newPwCtrl,
              focusNode: _newPwFocusNode,
              obscureText: !_showNewPw,
              style: TextStyle(color: fieldTextColor, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'New Password',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0x66FF8DA1)
                      : Colors.grey.shade500,
                  fontSize: 13,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPw ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFFF4D88),
                    size: 18,
                  ),
                  onPressed: () => setState(() => _showNewPw = !_showNewPw),
                ),
              ),
            ),
          ),

          // Password combinations & reached strength counter (visible only while entering password)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _shouldShowRecoveryRules
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16161D)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: fieldBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              strengthLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: strengthColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: strengthColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$metCount / 5 reached',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: strengthColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (index) {
                            final active = index < metCount;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                height: 5,
                                margin:
                                    EdgeInsets.only(right: index < 4 ? 5 : 0),
                                decoration: BoxDecoration(
                                  color: active
                                      ? strengthColor
                                      : (isDark
                                          ? Colors.white12
                                          : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        _RecoveryRequirementRow(
                          label: 'At least 8 characters',
                          isMet: _hasMinLength,
                          isDark: isDark,
                        ),
                        _RecoveryRequirementRow(
                          label: 'One uppercase letter (A-Z)',
                          isMet: _hasUppercase,
                          isDark: isDark,
                        ),
                        _RecoveryRequirementRow(
                          label: 'One lowercase letter (a-z)',
                          isMet: _hasLowercase,
                          isDark: isDark,
                        ),
                        _RecoveryRequirementRow(
                          label: 'One number (0-9)',
                          isMet: _hasNumber,
                          isDark: isDark,
                        ),
                        _RecoveryRequirementRow(
                          label: 'One special character (!@#\$%^&*)',
                          isMet: _hasSpecialChar,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fieldBorder),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _confirmPwCtrl,
              obscureText: !_showConfirmPw,
              style: TextStyle(color: fieldTextColor, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Confirm New Password',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0x66FF8DA1)
                      : Colors.grey.shade500,
                  fontSize: 13,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPw ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFFF4D88),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _showConfirmPw = !_showConfirmPw),
                ),
              ),
            ),
          ),
          if (_confirmPwCtrl.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6),
              child: Text(
                _recoveryPasswordsMatch
                    ? '✓ Passwords match'
                    : 'Passwords do not match',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _recoveryPasswordsMatch
                      ? Colors.green
                      : Colors.redAccent,
                ),
              ),
            ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _canSaveRecoveryPassword
                ? () {
                    setState(() => _recoveryStep = 0);
                    widget.onLogin?.call(_recIdCtrl.text, _newPwCtrl.text);
                  }
                : null,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _canSaveRecoveryPassword
                    ? const LinearGradient(
                        colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                      )
                    : null,
                color: _canSaveRecoveryPassword
                    ? null
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(
                'Save Password & Sign In →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _canSaveRecoveryPassword
                      ? Colors.white
                      : (isDark ? Colors.white38 : Colors.grey.shade600),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class _RecoveryRequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;
  final bool isDark;

  const _RecoveryRequirementRow({
    required this.label,
    required this.isMet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 16,
            color: isMet
                ? Colors.green
                : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isMet
                  ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
