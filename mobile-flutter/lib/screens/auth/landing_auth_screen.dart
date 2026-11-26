import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingAuthScreen extends StatefulWidget {
  const LandingAuthScreen({super.key});

  @override
  State<LandingAuthScreen> createState() => _LandingAuthScreenState();
}

class _LandingAuthScreenState extends State<LandingAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();

    if (email.isEmpty && mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16161D),
          content: Text('Please enter either an email or mobile number'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        '/onboarding-step-2',
        arguments: {
          'email': email,
          'mobile': mobile.isNotEmpty ? '+91$mobile' : '',
        },
      );
    }
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Glowing Auth Header Badge
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
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
                        child: const Icon(Icons.lock_person_rounded,
                            color: Color(0xFFFF2E55), size: 30),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Welcome to YoUnMe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email and mobile number to start building your profile.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // 1. Email Field Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMAIL ADDRESS',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'name@example.com',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Color(0xFFFF2E55)),
                              filled: true,
                              fillColor: const Color(0xFF0B0B0F),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: const TextStyle(
                                  color: Color(0xFFFF6B8B), fontSize: 12),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return null;
                              }
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(text)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Mobile Number Field Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MOBILE NUMBER',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            decoration: InputDecoration(
                              hintText: '9876543210',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                letterSpacing: 1.2,
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: const Text(
                                  '+91',
                                  style: TextStyle(
                                    color: Color(0xFFFF2E55),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFF0B0B0F),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: const TextStyle(
                                  color: Color(0xFFFF6B8B), fontSize: 12),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return null;
                              }
                              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
                                return 'Enter a valid 10-digit Indian mobile number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Continue Button -> Moves directly to next page
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onContinuePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2E55),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFFF2E55).withOpacity(0.4),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
