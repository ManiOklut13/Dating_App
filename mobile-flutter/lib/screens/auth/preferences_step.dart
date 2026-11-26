import 'package:flutter/material.dart';

class PreferencesStep extends StatefulWidget {
  final VoidCallback onContinue;

  const PreferencesStep({super.key, required this.onContinue});

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  // 4 Tabs: Select any 1, 2, 3, or all 4 without restrictions
  final List<Map<String, dynamic>> _lookingForTabs = const [
    {'label': 'Long-term Partner', 'icon': Icons.favorite_rounded},
    {'label': 'Short-term Fun', 'icon': Icons.local_fire_department_rounded},
    {'label': 'New Friends', 'icon': Icons.people_alt_rounded},
    {'label': 'Still Figuring It Out', 'icon': Icons.explore_rounded},
  ];
  final Set<String> _selectedLookingFor = {};

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Step 3 of 5 • Dating Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you looking for?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Select any options that match your vibe (select as many as you want)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),

            // 4 Tabs - Unrestricted Multi-Select (can pick 1, 2, 3, or 4)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lookingForTabs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final item = _lookingForTabs[index];
                final label = item['label'] as String;
                final isSelected = _selectedLookingFor.contains(label);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLookingFor.remove(label);
                      } else {
                        _selectedLookingFor.add(label); // No max limit
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected ? theme.primaryColor : Colors.grey.shade700,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: isSelected ? theme.primaryColor : null,
                            ),
                          ),
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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Select all that describe you',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sexualOrientations.map((orientation) {
                final isSelected = _selectedOrientations.contains(orientation);
                return FilterChip(
                  label: Text(orientation),
                  selected: isSelected,
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedLookingFor.isEmpty ? null : widget.onContinue,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
