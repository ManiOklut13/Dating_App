import 'package:flutter/material.dart';
import 'face_verification_page.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _interests = [
    {'name': 'Coffee Dates', 'icon': '☕'},
    {'name': 'Road Trips', 'icon': '🚗'},
    {'name': 'Gym & Fitness', 'icon': '🏋️'},
    {'name': 'Telugu Movies', 'icon': '🎬'},
    {'name': 'Music & Concerts', 'icon': '🎧'},
    {'name': 'Photography', 'icon': '📸'},
    {'name': 'Cooking & Baking', 'icon': '🍕'},
    {'name': 'Gaming', 'icon': '🎮'},
    {'name': 'Dog Lover', 'icon': '🐶'},
    {'name': 'Cricket', 'icon': '🏏'},
    {'name': 'Badminton', 'icon': '🏸'},
    {'name': 'Late Night Drives', 'icon': '🌙'},
    {'name': 'Street Food', 'icon': '🌮'},
    {'name': 'Beach Walks', 'icon': '🏖️'},
    {'name': 'Tech & Coding', 'icon': '💻'},
    {'name': 'Stand-up Comedy', 'icon': '🎤'},
    {'name': 'Reading', 'icon': '📚'},
    {'name': 'Biryani', 'icon': '🍲'},
    {'name': 'Travel', 'icon': '✈️'},
    {'name': 'Art & Sketching', 'icon': '🎨'},
  ];

  bool get _hasMinimumFive => _selected.length >= 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Step 4 of 5 • Interests',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick Your Interests',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select at least 5 interests to continue',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _hasMinimumFive
                        ? Colors.greenAccent.withOpacity(0.18)
                        : const Color(0xFF16161D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _hasMinimumFive
                          ? Colors.greenAccent
                          : const Color(0xFFFF2E55),
                    ),
                  ),
                  child: Text(
                    '${_selected.length} / 5 min',
                    style: TextStyle(
                      color: _hasMinimumFive
                          ? Colors.greenAccent
                          : const Color(0xFFFF2E55),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: _interests.map((item) {
                  final name = item['name']!;
                  final icon = item['icon']!;
                  final isSelected = _selected.contains(name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(name);
                        } else {
                          _selected.add(name);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF2E55)
                            : const Color(0xFF16161D),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF2E55)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasMinimumFive
                      ? const Color(0xFFFF2E55)
                      : Colors.grey[850],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _hasMinimumFive
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FaceVerificationPage()),
                        );
                      }
                    : null,
                child: Text(
                  _hasMinimumFive
                      ? 'Continue (${_selected.length} Selected)'
                      : 'Select ${5 - _selected.length} More',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
