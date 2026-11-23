import 'package:flutter/material.dart';
import 'unified_auth_flow.dart';

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
  bool _showNewPw = false;
  bool _showConfirmPw = false;
  // int _otpCountdown = 45;

  @override
  void dispose() {
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.75),
            radius: 1.2,
            colors: [
              Color(0xFF380D25),
              Color(0xFF200816),
              Color(0xFF14040E),
            ],
          ),
        ),
        child: SafeArea(
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
                    const SizedBox(width: 12),
                    Text(
                      _recoveryStep == 0 ? 'YOUNME SIGN IN' : 'PASSWORD RECOVERY',
                      style: const TextStyle(
                        fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: _recoveryStep == 0
                      ? _buildLoginForm()
                      : _buildRecoveryFlow(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Welcome Back 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in with your credentials to check admirer stack & live calls.',
          style: TextStyle(fontSize: 13, color: Color(0xFFE2C0CE), height: 1.4),
        ),
        const SizedBox(height: 24),

        if (_errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0x33EF4444),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x80EF4444)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Color(0xFFF87171)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFCA5A5)),
                  ),
                ),
              ],
            ),
          ),

        // ✉️ Email or Phone Number Label & Input
        const Row(
          children: [
            Icon(Icons.mail_outline, size: 14, color: Color(0xFFFF8DA1)),
            SizedBox(width: 6),
            Text(
              'Email or Phone Number',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
            controller: _idCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. aarav.kapoor@younme.love',
              hintStyle: TextStyle(color: Color(0x66FF8DA1), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 🔒 Password Label & Input
        const Row(
          children: [
            Icon(Icons.lock_outline, size: 14, color: Color(0xFFFF8DA1)),
            SizedBox(width: 6),
            Text(
              'Password',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0x8C2B091C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x38FF8DA1)),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pwCtrl,
                  obscureText: !_showPw,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Color(0x66FF8DA1), fontSize: 13),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showPw = !_showPw),
                child: Icon(
                  _showPw ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: const Color(0xFFFF8DA1),
                ),
              ),
            ],
          ),
        ),

        // Forgot password button (right-aligned)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() {
              _recoveryStep = 1;
              _recIdCtrl.text = _idCtrl.text;
            }),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF8DA1),
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
                activeColor: const Color(0xFFFF4D88),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0x80FF8DA1)),
                onChanged: (v) => setState(() => _remember = v ?? true),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me on this device',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFE2C0CE)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Sign in button
        GestureDetector(
          onTap: _isSubmitting ? null : _handleLogin,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FF4D88),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign in to YoUnMe',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // OR CONTINUE WITH divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: const Color(0x26FF8DA1))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE2C0CE)),
              ),
            ),
            Expanded(child: Container(height: 1, color: const Color(0x26FF8DA1))),
          ],
        ),
        const SizedBox(height: 18),

        // Google & Apple buttons side by side
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => showSystemGoogleAccounts(
                  context,
                  onAccountSelected: (selectedEmail) {
                    setState(() => _idCtrl.text = selectedEmail);
                    _handleLogin();
                  },
                ),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x3D2B091C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x38FF8DA1)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Google',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _idCtrl.text = 'apple.id@icloud.com');
                  _handleLogin();
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x3D2B091C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x38FF8DA1)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Apple',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Don't have an account? Create Account
        Center(
          child: GestureDetector(
            onTap: widget.onGoToSignUp,
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(fontSize: 13, color: Color(0xFFE2C0CE)),
                  ),
                  TextSpan(
                    text: 'Create Account',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF8DA1),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Create New Password 🔒',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Step 3 of 3: Choose a strong password with at least 6 characters.',
            style: TextStyle(fontSize: 13, color: Color(0xFFE2C0CE), height: 1.4),
          ),
          const SizedBox(height: 20),

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
              controller: _newPwCtrl,
              obscureText: !_showNewPw,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'New Password',
                hintStyle: const TextStyle(color: Color(0x66FF8DA1), fontSize: 13),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPw ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFFF8DA1), size: 18),
                  onPressed: () => setState(() => _showNewPw = !_showNewPw),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

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
              controller: _confirmPwCtrl,
              obscureText: !_showConfirmPw,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Confirm New Password',
                hintStyle: const TextStyle(color: Color(0x66FF8DA1), fontSize: 13),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPw ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFFF8DA1), size: 18),
                  onPressed: () => setState(() => _showConfirmPw = !_showConfirmPw),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              setState(() => _recoveryStep = 0);
              widget.onLogin?.call(_recIdCtrl.text, _newPwCtrl.text);
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
                'Save Password & Sign In →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }
  }
}
