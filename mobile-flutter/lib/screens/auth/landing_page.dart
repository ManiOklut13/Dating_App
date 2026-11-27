import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import 'email_entry_page.dart';
import 'phone_entry_page.dart';
import 'sign_in_page.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback? onSignIn;
  final void Function(OnboardingProfileData)? onComplete;

  const LandingPage({
    super.key,
    this.onSignIn,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0B0B0F) : theme.scaffoldBackgroundColor;
    final titleColor = isDark ? Colors.white : const Color(0xFF181A24);
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final secondaryBtnBg = isDark ? const Color(0xFF16161D) : Colors.white;
    final secondaryBtnText = isDark ? Colors.white : const Color(0xFF181A24);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          if (isDark) ...[
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
          ] else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFEEF3),
                      Color(0xFFFAFAFC),
                      Colors.white,
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
                    width: 124,
                    height: 124,
                    padding: const EdgeInsets.all(3),
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
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/younme_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'YoUnMe',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Where real vibes meet real people',
                    style: TextStyle(color: subtitleColor, fontSize: 15),
                  ),
                  const Spacer(),

                  // 1st Option: Continue with Email
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmailEntryPage(),
                        ),
                      );
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
                  const SizedBox(height: 14),

                  // 2nd Option: Continue with Mobile Number
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryBtnText,
                        backgroundColor: secondaryBtnBg,
                        side: const BorderSide(color: Color(0xFFFF2E55), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.phone_iphone_rounded,
                          color: Color(0xFFFF2E55), size: 22),
                      label: const Text(
                        'Continue with Mobile Number',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhoneEntryPage(startedWithEmail: false),
                          ),
                        );
                      },
                    ),
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
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      decoration: BoxDecoration(
                        color: secondaryBtnBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF2E55).withOpacity(0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFFFF2E55),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
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
}
