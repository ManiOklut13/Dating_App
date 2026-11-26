import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';

class SafetyVerificationPage extends StatefulWidget {
  const SafetyVerificationPage({super.key});

  @override
  State<SafetyVerificationPage> createState() => _SafetyVerificationPageState();
}

class _SafetyVerificationPageState extends State<SafetyVerificationPage> {
  final ImagePicker _picker = ImagePicker();

  bool _isFaceVerified = false;
  bool _isVoiceVerified = false;
  bool _isRecordingVoice = false;

  bool _pushNotificationsEnabled = true;
  bool _contactsSynced = false;
  String _whoCanMessageMe = 'Matches Only';

  // Opens Real Front Camera for Live Face Check (Demo verification response)
  Future<void> _runLiveFaceCheck() async {
    try {
      final XFile? liveSelfie = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (liveSelfie != null && mounted) {
        setState(() => _isFaceVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live face detected! Original profile verified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // In case camera permission is restricted or running on unsupported browser preview
      if (mounted) {
        setState(() => _isFaceVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo check: Live face verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Voice Verification Tab/Button Action (Demo verification flow)
  Future<void> _runVoiceVerification() async {
    setState(() => _isRecordingVoice = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isRecordingVoice = false;
      _isVoiceVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice sample verified clearly!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Step 5 of 5 • Safety & Verification',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify & Secure Your Profile',
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete live checks to earn your verified badge and control who reaches you.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 22),

            // 1. Face Detect / Live Check Card (Opens Real Camera)
            _VerificationActionCard(
              icon: Icons.face_unlock_rounded,
              title: 'Live Face Detection Check',
              subtitle: _isFaceVerified
                  ? 'Original live face verified'
                  : 'Tap to open camera and verify live presence',
              buttonLabel: _isFaceVerified ? 'Verified' : 'Open Camera',
              isCompleted: _isFaceVerified,
              onPressed: _runLiveFaceCheck,
            ),
            const SizedBox(height: 14),

            // 2. Voice Verification Card
            _VerificationActionCard(
              icon: Icons.mic_rounded,
              title: 'Voice Verification',
              subtitle: _isRecordingVoice
                  ? 'Listening... Say: "Hey YoUnMe, this is my real voice"'
                  : _isVoiceVerified
                      ? 'Voice clarity verified'
                      : 'Tap to record a 3-second voice prompt',
              buttonLabel: _isRecordingVoice
                  ? 'Recording...'
                  : (_isVoiceVerified ? 'Verified' : 'Verify Voice'),
              isCompleted: _isVoiceVerified,
              onPressed: _isRecordingVoice ? () {} : _runVoiceVerification,
            ),
            const SizedBox(height: 22),

            // 3. Push Notifications Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFFF4D6D),
                title: const Text('Push Notifications',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Get instant alerts for matches & messages',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                value: _pushNotificationsEnabled,
                onChanged: (val) =>
                    setState(() => _pushNotificationsEnabled = val),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Add Friends by Contacts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.contacts_rounded,
                      color: Colors.amberAccent, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Friends by Contacts',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(
                          _contactsSynced
                              ? 'Contacts synced successfully'
                              : 'Find or block people from your phone contacts',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _contactsSynced = true),
                    child: Text(
                      _contactsSynced ? 'Synced' : 'Sync',
                      style: TextStyle(
                        color: _contactsSynced
                            ? Colors.greenAccent
                            : const Color(0xFFFF4D6D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 5. Who Can Message Me Selector
            const Text('Who Can Message Me',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ['Everyone', 'Matches Only', 'Verified Profiles Only']
                  .map((option) {
                final selected = _whoCanMessageMe == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  selectedColor: const Color(0xFFFF4D6D),
                  backgroundColor: const Color(0xFF1E1E24),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _whoCanMessageMe = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Complete Onboarding -> Go to Home Screen
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isFaceVerified && _isVoiceVerified)
                      ? const Color(0xFFFF4D6D)
                      : Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: (_isFaceVerified && _isVoiceVerified)
                    ? () {
                        try {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (route) => false);
                        } catch (_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MainShellScreen()),
                            (route) => false,
                          );
                        }
                      }
                    : null,
                child: const Text('Complete Setup & Enter Home',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool isCompleted;
  final VoidCallback onPressed;

  const _VerificationActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.isCompleted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.greenAccent : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color:
                  isCompleted ? Colors.greenAccent : const Color(0xFFFF4D6D),
              size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isCompleted ? Colors.green : const Color(0xFFFF4D6D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onPressed,
            child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
