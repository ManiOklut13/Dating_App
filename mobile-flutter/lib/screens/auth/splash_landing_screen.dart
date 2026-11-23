import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import 'landing_page.dart';

export 'landing_page.dart';

class SplashLandingScreen extends StatelessWidget {
  final VoidCallback? onCreateAccount;
  final VoidCallback? onSignIn;
  final void Function(OnboardingProfileData)? onComplete;

  const SplashLandingScreen({
    super.key,
    this.onCreateAccount,
    this.onSignIn,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return LandingPage(
      onCreateAccount: onCreateAccount,
      onSignIn: onSignIn,
      onComplete: onComplete,
    );
  }
}
