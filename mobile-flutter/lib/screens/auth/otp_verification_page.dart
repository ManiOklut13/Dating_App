import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'basic_profile_page.dart';
import 'create_password_screen.dart';

class OtpVerificationPage extends StatefulWidget {
  final String destination;
  final bool isEmailVerification;
  final bool startedWithEmail;

  const OtpVerificationPage({
    super.key,
    required this.destination,
    required this.isEmailVerification,
    this.startedWithEmail = true,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 45;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _secondsRemaining = 45;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _resendOtp() {
    if (!_canResend) return;
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16161D),
        content: Text('New verification code sent to ${widget.destination}'),
      ),
    );
  }

  void _verifyAndContinue() {
    if (_enteredOtp.length < 6) return;

    if (widget.isEmailVerification) {
      // After Email is verified -> Create Password -> Mobile Number
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePasswordScreen(
            verifiedEmail: widget.destination,
          ),
        ),
      );
    } else {
      // After Mobile OTP is verified -> Go directly to Create Your Identity (Step 2 of 5)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BasicProfilePage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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

                  // Glowing Verification Icon Badge
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
                    child: Icon(
                      widget.isEmailVerification
                          ? Icons.mark_email_read_rounded
                          : Icons.phonelink_lock_rounded,
                      color: const Color(0xFFFF2E55),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.isEmailVerification
                        ? 'Verify Your Email'
                        : 'Verify Mobile Number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit verification code sent to',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  // Destination Highlight Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2E55).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.35)),
                    ),
                    child: Text(
                      widget.destination,
                      style: const TextStyle(
                        color: Color(0xFFFF6B8B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Elevated Dark Card Wrapping the 6 OTP Boxes + Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _enteredOtp.length == 6
                            ? const Color(0xFFFF2E55).withOpacity(0.6)
                            : Colors.white10,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final hasDigit = _controllers[index].text.isNotEmpty;
                            return SizedBox(
                              width: 44,
                              height: 56,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFF0B0B0F),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: hasDigit
                                          ? const Color(0xFFFF2E55)
                                          : Colors.white12,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFF2E55),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  setState(() {});
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 22),

                        // Resend Timer Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0B0F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _canResend
                              ? GestureDetector(
                                  onTap: _resendOtp,
                                  child: const Text(
                                    'Resend Verification Code',
                                    style: TextStyle(
                                      color: Color(0xFFFF2E55),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        color: Color(0xFFFF6B8B), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Verify & Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _enteredOtp.length == 6
                            ? const Color(0xFFFF2E55)
                            : Colors.grey[850],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed:
                          _enteredOtp.length == 6 ? _verifyAndContinue : null,
                      child: const Text(
                        'Verify & Continue',
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
}
