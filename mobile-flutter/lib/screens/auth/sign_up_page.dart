import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'email_link_waiting_page.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _countryCode = '+91';
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
      .hasMatch(_emailController.text.trim());

  bool get _isValidPhone => _phoneController.text.trim().length == 10;

  bool get _isStrongPassword {
    final p = _passwordController.text;
    return p.length >= 8 &&
        p.contains(RegExp(r'[A-Z]')) &&
        p.contains(RegExp(r'[0-9]'));
  }

  bool get _canSignUp =>
      _nameController.text.trim().isNotEmpty &&
      _isValidEmail &&
      _isValidPhone &&
      _isStrongPassword;

  Future<void> _handleSignUp() async {
    if (!_canSignUp || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Proceeds to Email Link Confirmation -> Create Your Identity (no OTP)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailLinkWaitingPage(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool isValid,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFFF2E55), size: 20),
      suffixIcon: isValid
          ? const Icon(Icons.check_circle_rounded,
              color: Colors.greenAccent, size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFF0B0B0F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF2E55), width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
          // Top-Right Ambient Red-Pink Glow (Matches SignIn & Entry Pages)
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
                  // Styled Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF16161D),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Glowing Header Icon Badge
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF2E55).withOpacity(0.25),
                          const Color(0xFFFF6B8B).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.45)),
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded,
                        color: Color(0xFFFF2E55), size: 32),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join YoUnMe and start meeting real people near you',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  // Elevated Dark Card Container (#16161D)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _canSignUp
                            ? const Color(0xFFFF2E55).withOpacity(0.6)
                            : Colors.white10,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        TextField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: _inputDecoration(
                            label: 'Full Name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline_rounded,
                            isValid: _nameController.text.trim().isNotEmpty,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Address
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: _inputDecoration(
                            label: 'Email Address',
                            hint: 'name@example.com',
                            icon: Icons.alternate_email_rounded,
                            isValid: _isValidEmail,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number with Country Code Dropdown
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0B0F),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _countryCode,
                                  dropdownColor: const Color(0xFF16161D),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: ['+91', '+1', '+44', '+971']
                                      .map((code) => DropdownMenuItem(
                                            value: code,
                                            child: Text(code),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _countryCode = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  label: 'Mobile Number',
                                  hint: '98765 43210',
                                  icon: Icons.phone_android_rounded,
                                  isValid: _isValidPhone,
                                ).copyWith(counterText: ''),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: _inputDecoration(
                            label: 'Password',
                            hint: 'Min 8 chars, 1 uppercase & 1 number',
                            icon: Icons.lock_outline_rounded,
                            isValid: _isStrongPassword,
                          ).copyWith(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Gradient Primary CTA Button
                  GestureDetector(
                    onTap: _canSignUp ? _handleSignUp : null,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _canSignUp
                            ? const LinearGradient(
                                colors: [Color(0xFFFF2E55), Color(0xFFFF5E7E)],
                              )
                            : null,
                        color: _canSignUp ? null : Colors.grey[850],
                        boxShadow: _canSignUp
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF2E55).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? Sign In link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFFFF2E55),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}
