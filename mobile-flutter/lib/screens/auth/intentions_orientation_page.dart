import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'interests_page.dart';

class IntentionsOrientationPage extends StatefulWidget {
  const IntentionsOrientationPage({super.key});

  @override
  State<IntentionsOrientationPage> createState() =>
      _IntentionsOrientationPageState();
}

class _IntentionsOrientationPageState extends State<IntentionsOrientationPage> {
  static const int _maxSelections = 3;

  final List<Map<String, dynamic>> _goals = const [
    {
      'title': 'Long-term Partner',
      'subtitle': 'Looking for something serious & lasting',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'Short-term Fun',
      'subtitle': 'Casual dates & keeping things light',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'title': 'New Friends',
      'subtitle': 'Expand my circle & meet cool people',
      'icon': Icons.people_alt_rounded,
    },
    {
      'title': 'Still Figuring It Out',
      'subtitle': 'Open to seeing where things go',
      'icon': Icons.explore_rounded,
    },
  ];
  final Set<String> _selectedGoals = {};

  // Expanded to 16 Sexual Orientations
  final List<String> _sexualOrientations = const [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Asexual',
    'Demisexual',
    'Pansexual',
    'Queer',
    'Questioning',
    'Bicurious',
    'Graysexual',
    'Omnisexual',
    'Polysexual',
    'Androgynosexual',
    'Gynosexual',
    'Sapiosexual',
  ];
  final Set<String> _selectedOrientations = {};

  void _toggleGoal(String title) {
    setState(() {
      if (_selectedGoals.contains(title)) {
        _selectedGoals.remove(title);
      } else {
        if (_selectedGoals.length >= _maxSelections) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 3 relationship goals.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedGoals.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF181A24) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;
    final ready = _selectedGoals.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Step 3 of 5 • Relationship Goals',
          style: TextStyle(color: subTextColor, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedGoals.length}/$_maxSelections',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you looking for?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose up to 3 goals that best fit what you want right now.',
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),
            const SizedBox(height: 18),

            // 4 Relationship Goal Cards (Max 3 Selections)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final title = goal['title'] as String;
                final isSelected = _selectedGoals.contains(title);

                return InkWell(
                  onTap: () => _toggleGoal(title),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.10)
                          : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            goal['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Sexual Orientation (16 Options)
            Text(
              'Sexual Orientation',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select all that describe you',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sexualOrientations.map((orientation) {
                final isSelected = _selectedOrientations.contains(orientation);
                return FilterChip(
                  label: Text(
                    orientation,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.flamePink,
                  backgroundColor: cardColor,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.flamePink
                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedOrientations.add(orientation);
                      } else {
                        _selectedOrientations.remove(orientation);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            ElevatedButton(
              onPressed: ready
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InterestsPage()),
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
