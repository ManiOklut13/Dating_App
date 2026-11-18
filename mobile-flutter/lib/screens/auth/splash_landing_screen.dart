import 'package:flutter/material.dart';

class SplashLandingScreen extends StatefulWidget {
  final VoidCallback? onCreateAccount;
  final VoidCallback? onSignIn;

  const SplashLandingScreen({
    super.key,
    this.onCreateAccount,
    this.onSignIn,
  });

  @override
  State<SplashLandingScreen> createState() => _SplashLandingScreenState();
}

class _SplashLandingScreenState extends State<SplashLandingScreen> {
  bool _isRecoveryOpen = false;
  String _recoveryMethod = 'phone'; // 'phone' | 'email' | 'support'
  final TextEditingController _recoveryInputCtrl = TextEditingController();
  bool _recoverySent = false;

  @override
  void dispose() {
    _recoveryInputCtrl.dispose();
    super.dispose();
  }

  void _handleSendRecovery() {
    if (_recoveryInputCtrl.text.trim().isEmpty) return;
    setState(() => _recoverySent = true);
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _recoverySent = false;
          _isRecoveryOpen = false;
          _recoveryInputCtrl.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      body: Stack(
        children: [
          // Ambient neon glow top-right
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2EF43F5E), Colors.transparent],
                ),
              ),
            ),
          ),
          // Ambient neon glow bottom-left
          Positioned(
            bottom: 120,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2638BDF8), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Header / Branding Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x0AFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: Color(0xFFF43F5E)),
                        SizedBox(width: 6),
                        Text(
                          'YOUNME DATING APP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Hero Visual & Branding
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon 110x110
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0x1FFFFFFF), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x8C000000),
                              blurRadius: 36,
                              offset: Offset(0, 16),
                            ),
                            BoxShadow(
                              color: Color(0x40F43F5E),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            'assets/images/younme-logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 52,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // RichText YoUnMe
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Yo',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Un',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF43F5E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'M',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF43F5E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'e',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        'Where Real Stories Begin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Inline row: 100% Verified • Privacy First
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0x1AFFFFFF)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 13, color: Color(0xFFF43F5E)),
                                SizedBox(width: 5),
                                Text(
                                  '100% Verified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Color(0x40FFFFFF))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0x1AFFFFFF)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock_outline, size: 13, color: Color(0xFF38BDF8)),
                                SizedBox(width: 5),
                                Text(
                                  'Privacy First',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons & Legal Footer
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'By continuing, you agree to our Terms of Service & Privacy Policy.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Create account button (rose gradient)
                      GestureDetector(
                        onTap: widget.onCreateAccount,
                        child: Container(
                          width: double.infinity,
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sign in button (frosted glass outline)
                      GestureDetector(
                        onTap: widget.onSignIn,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0x0AFFFFFF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x1FFFFFFF)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Trouble signing in? button
                      TextButton(
                        onPressed: () => setState(() => _isRecoveryOpen = true),
                        child: const Text(
                          'Trouble signing in?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Account Recovery Bottom Sheet Overlay
          if (_isRecoveryOpen)
            Container(
              color: const Color(0xD906080E),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF151822),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(color: Color(0x1FFFFFFF)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 40,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.help_outline, color: Color(0xFFF43F5E), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Account Recovery',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isRecoveryOpen = false),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0x14FFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 15, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how you want to receive your sign-in verification link.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),

                    // Segmented Method Selector: Phone | Email | Support
                    Row(
                      children: [
                        _recoveryTab('phone', 'Phone 📱'),
                        const SizedBox(width: 8),
                        _recoveryTab('email', 'Email ✉️'),
                        const SizedBox(width: 8),
                        _recoveryTab('support', 'Support 💬'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_recoveryMethod == 'support') ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direct Priority Support',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Reach our safety team directly at support@younme.love or call our 24/7 hotline at +91 1800-YOUNME.',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C24),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x26FFFFFF)),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _recoveryInputCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _recoveryMethod == 'phone'
                                ? 'Enter phone number (+91)'
                                : 'Enter your registered email address',
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: _handleSendRecovery,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _recoverySent ? '✓ Reset Link Sent!' : 'Send Recovery Link',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _recoveryTab(String key, String label) {
    final active = _recoveryMethod == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _recoveryMethod = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF43F5E) : const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFFF43F5E) : const Color(0x1AFFFFFF),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
