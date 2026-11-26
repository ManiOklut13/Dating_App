import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailMode = true;
  bool _obscurePassword = true;

  bool get _canSignIn =>
      _identifierController.text.trim().isNotEmpty &&
      _passwordController.text.length >= 6;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordSheet() {
    final resetCtrl = TextEditingController(text: _identifierController.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16161D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your ${_isEmailMode ? "email address" : "mobile number"} to receive a password reset code.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: resetCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _isEmailMode ? 'Email' : 'Mobile Number',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF0B0B0F),
                  prefixIcon: Icon(
                    _isEmailMode ? Icons.email_outlined : Icons.phone_android_rounded,
                    color: const Color(0xFFFF2E55),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E55),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset instructions sent to ${resetCtrl.text.trim().isEmpty ? "your account" : resetCtrl.text.trim()}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Send Reset Link / Code',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
          // Top-Right Ambient Red-Pink Glow
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2E55).withOpacity(0.16),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF16161D),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Glowing Header Badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2E55).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.lock_open_rounded,
                        color: Color(0xFFFF2E55), size: 30),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your YoUnMe journey',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 28),

                  // Email vs Mobile Mode Switcher Pill
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _toggleTab('Email', _isEmailMode, () {
                            setState(() {
                              _isEmailMode = true;
                              _identifierController.clear();
                            });
                          }),
                        ),
                        Expanded(
                          child: _toggleTab('Mobile Number', !_isEmailMode, () {
                            setState(() {
                              _isEmailMode = false;
                              _identifierController.clear();
                            });
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Styled Card Container for Inputs
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _identifierController,
                          keyboardType: _isEmailMode
                              ? TextInputType.emailAddress
                              : TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText:
                                _isEmailMode ? 'Email Address' : 'Mobile Number',
                            hintText: _isEmailMode
                                ? 'you@example.com'
                                : '+91 98765 43210',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              _isEmailMode
                                  ? Icons.email_outlined
                                  : Icons.phone_android_rounded,
                              color: const Color(0xFFFF2E55),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0B0B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFFF2E55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFFFF2E55)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0B0B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFFF2E55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordSheet,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFFFF6B8B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign In Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSignIn
                            ? const Color(0xFFFF2E55)
                            : Colors.grey[850],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _canSignIn
                          ? () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            }
                          : null,
                      child: const Text(
                        'Sign In',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF2E55) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
