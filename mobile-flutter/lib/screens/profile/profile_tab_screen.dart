import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/app_state_provider.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appStateProvider.notifier);

    final checklistItems = [
      'Phone Verification (Twilio WhatsApp OTP)',
      'Basic Identity & Bio',
      'Discovery Preferences',
      '6 Photos Uploaded',
      'Voice PIN Recording Sample',
      'Blink SDK Oval Face Liveness Test',
      'Anonymous Call Avatar Configured',
      'Contacts Sync & Privacy Shield',
      'GPS Location Precision Enabled',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Profile Card: Circular avatar, "Arjun Mehta, 26", "Blue Tick Verified" badge, bio, GPS, Voice PIN
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Circular avatar
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEC4899), width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66EC4899),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 44, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name + Verified Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Arjun Mehta, 26',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x2638BDF8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x8038BDF8)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 12, color: Color(0xFF38BDF8)),
                              SizedBox(width: 4),
                              Text(
                                'Blue Tick Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bio
                    const Text(
                      'Building next-gen AI tech • Subko coffee addict • Mumbai (Bandra West)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    // GPS & Voice PIN pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF241822),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF2E1E2B)),
                          ),
                          child: const Text(
                            '📍 Bandra (19.0596° N, 72.8295° E)',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x2622C55E),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x8022C55E)),
                          ),
                          child: const Row(
                            children: [
                              Text('🎤', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 4),
                              Text(
                                'Voice PIN Active',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Onboarding Progress Card: Large "92%" (Auto-awarded Blue Tick (>=70%)) with gradient progress bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Verification Score',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Auto-awarded Blue Tick (>=70%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF38BDF8)),
                            ),
                          ],
                        ),
                        Text(
                          '92%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Gradient progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 8,
                        color: const Color(0xFF2E1E2B),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.92,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Two side-by-side action buttons: "Test Onboarding Wizard" & "Log Out & Splash"
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.setAuthenticated(false);
                        notifier.setAuthScreen(AuthScreen.onboarding);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF241822),
                          border: Border.all(color: const Color(0xFF2E1E2B)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Test Onboarding Wizard',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.setAuthenticated(false);
                        notifier.setAuthScreen(AuthScreen.splash);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF241822),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Log Out & Splash',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 9-Step Verification Status Card: Scrollable checklist with green checkmarks and "Done" labels
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF22C55E), size: 18),
                        SizedBox(width: 8),
                        Text(
                          '9-Step Verification Status',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Spacer(),
                        Text(
                          '9/9 Completed',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    ...List.generate(checklistItems.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x2622C55E),
                              ),
                              child: const Icon(Icons.check, size: 13, color: Color(0xFF22C55E)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                checklistItems[index],
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x1A22C55E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
