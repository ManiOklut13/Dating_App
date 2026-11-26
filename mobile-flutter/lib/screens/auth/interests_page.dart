import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'face_verification_page.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // Discovery Preference Sliders (Age Range & Distance Radius in km)
  RangeValues _ageRange = const RangeValues(20, 32);
  double _radiusKm = 25;

  final Map<String, List<String>> _categorizedInterests = const {
    'Sports & Fitness': [
      'Gym & Weight Training',
      'Cricket',
      'Badminton',
      'Running',
      'Yoga',
      'Cycling',
      'Swimming',
      'Football',
    ],
    'Entertainment & Gaming': [
      'PC Gaming',
      'GTA V',
      'Movies & Cinema',
      'Anime',
      'Stand-up Comedy',
      'Web Series',
      'Board Games',
    ],
    'Food & Cooking': [
      'Street Food',
      'Air Fryer Baking',
      'Coffee Lover',
      'Biryani',
      'Dark Chocolate',
      'Cooking',
      'Vegan / Healthy Eating',
    ],
    'Music & Arts': [
      'Telugu Melodies',
      'Indie Music',
      'Live Concerts',
      'Photography',
      'Video Editing',
      'Sketching',
      'Dancing',
    ],
    'Travel & Outdoors': [
      'Road Trips',
      'Bike Rides',
      'Beach Getaways',
      'Trekking',
      'Solo Travel',
      'Camping',
      'City Exploration',
    ],
    'Tech & Lifestyle': [
      'Coding & Tech',
      'Stock Market & Trading',
      'Startups',
      'Podcasts',
      'Reading',
      'Pets & Dogs',
      'Volunteering',
    ],
  };

  final Set<String> _selectedInterests = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final cardColor = isDark ? const Color(0xFF181A24) : Colors.white;
    final chipBg = isDark ? const Color(0xFF16161D) : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Step 4 of 5 • Discovery & Interests',
          style: TextStyle(color: subTextColor, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_selectedInterests.length}/3 min',
                style: TextStyle(
                  color: _selectedInterests.length >= 3
                      ? Colors.green
                      : primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. AGE RANGE & DISTANCE RADIUS CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age Range Header + Live Value Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preferred Age Range',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_ageRange.start.round()} - ${_ageRange.end.round()} yrs',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _ageRange,
                        min: 18,
                        max: 60,
                        divisions: 42,
                        activeColor: primary,
                        labels: RangeLabels(
                          '${_ageRange.start.round()}',
                          '${_ageRange.end.round()}',
                        ),
                        onChanged: (RangeValues newRange) {
                          setState(() => _ageRange = newRange);
                        },
                      ),

                      Divider(
                        height: 20,
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),

                      // Radius Limit Header + Live Value Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maximum Distance Radius',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_radiusKm.round()} km',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _radiusKm,
                        min: 2,
                        max: 150,
                        divisions: 148,
                        activeColor: primary,
                        label: '${_radiusKm.round()} km',
                        onChanged: (double newRadius) {
                          setState(() => _radiusKm = newRadius);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. CATEGORIZED INTERESTS SECTION
                ..._categorizedInterests.entries.map((entry) {
                  final category = entry.key;
                  final items = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: items.map((interest) {
                            final isSelected =
                                _selectedInterests.contains(interest);
                            return FilterChip(
                              label: Text(
                                interest,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.flamePink,
                              backgroundColor: chipBg,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.flamePink
                                    : (isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedInterests.length >= 3
                      ? primary
                      : (isDark ? Colors.grey[850] : Colors.grey[300]),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _selectedInterests.length < 3
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FaceVerificationPage(),
                          ),
                        );
                      },
                child: Text(
                  _selectedInterests.length < 3
                      ? 'Select at least 3 interests (${_selectedInterests.length}/3)'
                      : 'Continue (${_selectedInterests.length} Selected)',
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
