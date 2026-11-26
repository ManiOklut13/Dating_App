import 'package:flutter/material.dart';

class CategorizedInterestsStep extends StatefulWidget {
  final VoidCallback onContinue;

  const CategorizedInterestsStep({super.key, required this.onContinue});

  @override
  State<CategorizedInterestsStep> createState() =>
      _CategorizedInterestsStepState();
}

class _CategorizedInterestsStepState extends State<CategorizedInterestsStep> {
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
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 4 of 5 • Discovery & Interests'),
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
                    color: theme.colorScheme.surface,
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
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
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

                      const Divider(height: 20),

                      // Radius Limit Header + Live Value Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maximum Distance Radius',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                          style: theme.textTheme.titleMedium?.copyWith(
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
                              label: Text(interest),
                              selected: isSelected,
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
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _selectedInterests.length < 3 ? null : widget.onContinue,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _selectedInterests.length < 3
                      ? 'Select at least 3 interests (${_selectedInterests.length}/3)'
                      : 'Continue (${_selectedInterests.length} Selected)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
