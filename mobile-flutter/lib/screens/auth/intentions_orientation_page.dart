import 'package:flutter/material.dart';
import 'interests_page.dart';

class IntentionsOrientationPage extends StatefulWidget {
  const IntentionsOrientationPage({super.key});

  @override
  State<IntentionsOrientationPage> createState() =>
      _IntentionsOrientationPageState();
}

class _IntentionsOrientationPageState extends State<IntentionsOrientationPage> {
  String? _intention;
  String? _orientation;

  final List<Map<String, String>> _intentions = [
    {'title': 'Long-term relationship', 'emoji': '❤️'},
    {'title': 'Short-term relationship', 'emoji': '🔥'},
    {'title': 'Long-term, open to short', 'emoji': '🥂'},
    {'title': 'New friends & casual dates', 'emoji': '☕'},
  ];

  final List<Map<String, String>> _orientations = [
    {'title': 'Straight', 'emoji': '💫'},
    {'title': 'Gay', 'emoji': '🌈'},
    {'title': 'Lesbian', 'emoji': '💖'},
    {'title': 'Bisexual', 'emoji': '💜'},
    {'title': 'Asexual', 'emoji': '🖤'},
    {'title': 'Pansexual', 'emoji': '✨'},
  ];

  @override
  Widget build(BuildContext context) {
    final ready = _intention != null && _orientation != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Step 3 of 5 • Relationship Goals',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are you looking for?',
              style: TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._intentions.map((item) {
              final selected = _intention == item['title'];
              return GestureDetector(
                onTap: () => setState(() => _intention = item['title']),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF2E55).withOpacity(0.18)
                        : const Color(0xFF16161D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF2E55)
                          : Colors.white10,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item['title']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected
                            ? const Color(0xFFFF2E55)
                            : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 26),
            const Text(
              'Sexual Orientation',
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orientations.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.7,
              ),
              itemBuilder: (context, index) {
                final item = _orientations[index];
                final selected = _orientation == item['title'];
                return GestureDetector(
                  onTap: () => setState(() => _orientation = item['title']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFF2E55)
                          : const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFF2E55)
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['emoji']!,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      ready ? const Color(0xFFFF2E55) : Colors.grey[850],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: ready
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InterestsPage()),
                        );
                      }
                    : null,
                child: const Text('Continue',
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
