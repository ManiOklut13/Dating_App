import 'dart:async';
import 'package:flutter/material.dart';
import 'create_password_screen.dart';

class EmailLinkWaitingPage extends StatefulWidget {
  final String email;
  const EmailLinkWaitingPage({super.key, required this.email});

  @override
  State<EmailLinkWaitingPage> createState() => _EmailLinkWaitingPageState();
}

class _EmailLinkWaitingPageState extends State<EmailLinkWaitingPage> {
  StreamSubscription? _authSub;
  int _resendCooldown = 30;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _listenForEmailLinkRedirect();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  void _listenForEmailLinkRedirect() {
    // When using Supabase Auth or app_links deep linking (`younme://auth-callback`):
    // _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    //   if (data.event == AuthChangeEvent.signedIn && mounted) {
    //     _onEmailLinkClicked();
    //   }
    // });
  }

  void _onEmailLinkClicked() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePasswordScreen(verifiedEmail: widget.email),
      ),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
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
            child: Padding(
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
                  const Spacer(),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF2E55).withOpacity(0.15),
                        border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.forward_to_inbox_rounded,
                        color: Color(0xFFFF2E55),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Check Your Inbox',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'We sent a confirmation link to',
                      style: TextStyle(color: Colors.grey[400], fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFF2E55).withOpacity(0.4)),
                      ),
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          color: Color(0xFFFF6B8B),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Tap the link inside the email to verify your account and continue automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Demo / Direct Continue Trigger when testing locally without deep link setup
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF16161D),
                        side: const BorderSide(color: Color(0xFFFF2E55)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded,
                          color: Color(0xFFFF2E55)),
                      label: const Text(
                        'I’ve Clicked the Email Link • Continue',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _onEmailLinkClicked,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: _resendCooldown == 0
                        ? TextButton(
                            onPressed: _startCooldown,
                            child: const Text(
                              'Resend Confirmation Email',
                              style: TextStyle(
                                color: Color(0xFFFF2E55),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            'Resend link in 00:${_resendCooldown.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
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
