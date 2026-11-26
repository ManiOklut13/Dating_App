import 'package:flutter/material.dart';

class RelationshipGoalsStep extends StatefulWidget {
  final VoidCallback onContinue;

  const RelationshipGoalsStep({super.key, required this.onContinue});

  @override
  State<RelationshipGoalsStep> createState() => _RelationshipGoalsStepState();
}

class _RelationshipGoalsStepState extends State<RelationshipGoalsStep> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3 of 5 • Relationship Goals'),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you looking for?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose up to 3 goals that best fit what you want right now.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
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
                            ? theme.colorScheme.primary.withOpacity(0.08)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
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
                                  : theme.colorScheme.primary.withOpacity(0.10),
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
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
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
            ),

            ElevatedButton(
              onPressed: _selectedGoals.isEmpty ? null : widget.onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
