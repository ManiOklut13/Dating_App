import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import 'email_entry_page.dart';
import 'sign_in_page.dart';
import 'sign_in_screen.dart';
import 'onboarding_wizard_screen.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback? onCreateAccount;
  final VoidCallback? onSignIn;
  final void Function(OnboardingProfileData)? onComplete;

  const LandingPage({
    super.key,
    this.onCreateAccount,
    this.onSignIn,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.35),
                    radius: 1.2,
                    colors: [Color(0xFF4A0E22), Color(0xFF0B0B0F)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    const Color(0xFF0B0B0F).withOpacity(0.86),
                    const Color(0xFF0B0B0F),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2E55), Color(0xFFFF6B8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2E55).withOpacity(0.5),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/younme_logo.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'YoUnMe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Where real vibes meet real people',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const Spacer(),

                  // Primary Option: Continue with Email (Mobile button removed)
                  GestureDetector(
                    onTap: () {
                      if (onCreateAccount != null) {
                        onCreateAccount!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OnboardingWizardScreen(
                              onBack: () => Navigator.pop(context),
                              onGoToSignIn: () {
                                Navigator.pop(context);
                                if (onSignIn != null) onSignIn!();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2E55), Color(0xFFFF5E7E)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2E55).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Continue with Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Google & Apple SSO Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _socialBox(Icons.g_mobiledata_rounded, 'Google', () {}),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _socialBox(Icons.apple_rounded, 'Apple', () {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sign In Option
                  GestureDetector(
                    onTap: () {
                      if (onSignIn != null) {
                        onSignIn!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignInScreen(
                              onBack: () => Navigator.pop(context),
                              onGoToSignUp: () {
                                Navigator.pop(context);
                                if (onCreateAccount != null) onCreateAccount!();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.45),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFFFF2E55),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFFF2E55),
                            size: 20,
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

  Widget _socialBox(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF16161D),
          side: const BorderSide(color: Colors.white12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        onPressed: onTap,
      ),
    );
  }
}
