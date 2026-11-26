import 'package:flutter/material.dart';

class DiscoveryFiltersScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const DiscoveryFiltersScreen({super.key, this.initialFilters});

  @override
  State<DiscoveryFiltersScreen> createState() => _DiscoveryFiltersScreenState();
}

class _DiscoveryFiltersScreenState extends State<DiscoveryFiltersScreen> {
  // Core Discovery Filters
  late double _radiusKm;
  late RangeValues _ageRange;
  late bool _expandDistanceIfEmpty;

  // Gender / Show Me
  final List<String> _genderOptions = const ['Women', 'Men', 'Non-binary', 'Everyone'];
  late String _selectedGender;

  // Relationship Goals
  final List<String> _goalOptions = const [
    'Long-term Partner',
    'Short-term Fun',
    'New Friends',
    'Still Figuring It Out',
  ];
  late Set<String> _selectedGoals;

  // Quality & Trust Switches
  late bool _verifiedOnly;
  late bool _recentlyActiveOnly;
  late bool _hasBioOnly;

  // Must-Have / Preferred Interests
  final List<String> _quickInterests = const [
    'Coffee Lover',
    'Gym & Weight Training',
    'Road Trips',
    'Movies & Cinema',
    'PC Gaming',
    'Photography',
    'Street Food',
    'Music & Concerts',
  ];
  late Set<String> _selectedInterests;

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilters;
    _radiusKm = ((init?['radiusKm'] as num?) ?? 25).toDouble();
    final minAge = (init?['minAge'] as num?)?.toDouble() ?? 20.0;
    final maxAge = (init?['maxAge'] as num?)?.toDouble() ?? 32.0;
    _ageRange = RangeValues(minAge, maxAge);
    _expandDistanceIfEmpty = (init?['expandDistance'] as bool?) ?? true;
    _selectedGender = (init?['showMe'] as String?) ?? 'Women';
    _selectedGoals = init?['goals'] != null
        ? Set<String>.from(init!['goals'] as Iterable)
        : {'Long-term Partner'};
    _verifiedOnly = (init?['verifiedOnly'] as bool?) ?? true;
    _recentlyActiveOnly = (init?['recentlyActiveOnly'] as bool?) ?? false;
    _hasBioOnly = (init?['hasBioOnly'] as bool?) ?? true;
    _selectedInterests = init?['interests'] != null
        ? Set<String>.from(init!['interests'] as Iterable)
        : {};
  }

  void _resetFilters() {
    setState(() {
      _radiusKm = 25;
      _ageRange = const RangeValues(18, 35);
      _expandDistanceIfEmpty = true;
      _selectedGender = 'Everyone';
      _selectedGoals.clear();
      _verifiedOnly = false;
      _recentlyActiveOnly = false;
      _hasBioOnly = false;
      _selectedInterests.clear();
    });
  }

  void _applyFilters() {
    Navigator.pop<Map<String, dynamic>>(context, {
      'radiusKm': _radiusKm.round(),
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
      'expandDistance': _expandDistanceIfEmpty,
      'showMe': _selectedGender,
      'goals': _selectedGoals.toList(),
      'verifiedOnly': _verifiedOnly,
      'recentlyActiveOnly': _recentlyActiveOnly,
      'hasBioOnly': _hasBioOnly,
      'interests': _selectedInterests.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discovery Filters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: TextStyle(color: primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                // 1. DISTANCE & RADIUS CARD
                _FilterSectionCard(
                  title: 'Distance Radius',
                  trailingBadge: '${_radiusKm.round()} km',
                  child: Column(
                    children: [
                      Slider(
                        value: _radiusKm,
                        min: 2,
                        max: 150,
                        divisions: 148,
                        activeColor: primary,
                        label: '${_radiusKm.round()} km',
                        onChanged: (val) => setState(() => _radiusKm = val),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text(
                          'Show people slightly further away if I run out',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: _expandDistanceIfEmpty,
                        activeColor: primary,
                        onChanged: (val) =>
                            setState(() => _expandDistanceIfEmpty = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. AGE RANGE CARD
                _FilterSectionCard(
                  title: 'Age Range',
                  trailingBadge:
                      '${_ageRange.start.round()} - ${_ageRange.end.round()} yrs',
                  child: RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 60,
                    divisions: 42,
                    activeColor: primary,
                    labels: RangeLabels(
                      '${_ageRange.start.round()}',
                      '${_ageRange.end.round()}',
                    ),
                    onChanged: (val) => setState(() => _ageRange = val),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. SHOW ME (GENDER PREFERENCE)
                _FilterSectionCard(
                  title: 'Show Me',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _genderOptions.map((gender) {
                      final isSelected = _selectedGender == gender;
                      return ChoiceChip(
                        label: Text(gender),
                        selected: isSelected,
                        selectedColor: primary.withOpacity(0.16),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primary : null,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedGender = gender),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. RELATIONSHIP GOALS
                _FilterSectionCard(
                  title: 'Relationship Goals',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goalOptions.map((goal) {
                      final isSelected = _selectedGoals.contains(goal);
                      return FilterChip(
                        label: Text(goal),
                        selected: isSelected,
                        selectedColor: primary.withOpacity(0.16),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primary : null,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGoals.add(goal);
                            } else {
                              _selectedGoals.remove(goal);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 5. PROFILE QUALITY & ACTIVITY
                _FilterSectionCard(
                  title: 'Profile Preferences',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Verified Profiles Only',
                            style: TextStyle(fontSize: 14)),
                        subtitle: Text('Only show photo-verified members',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        value: _verifiedOnly,
                        activeColor: primary,
                        onChanged: (val) => setState(() => _verifiedOnly = val),
                      ),
                      const Divider(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Recently Active',
                            style: TextStyle(fontSize: 14)),
                        subtitle: Text('Active within the last 24 hours',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        value: _recentlyActiveOnly,
                        activeColor: primary,
                        onChanged: (val) =>
                            setState(() => _recentlyActiveOnly = val),
                      ),
                      const Divider(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Has Written Bio',
                            style: TextStyle(fontSize: 14)),
                        subtitle: Text('Hide profiles without an about section',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        value: _hasBioOnly,
                        activeColor: primary,
                        onChanged: (val) => setState(() => _hasBioOnly = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 6. SHARED INTERESTS
                _FilterSectionCard(
                  title: 'Shared Interests',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        selectedColor: primary.withOpacity(0.16),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primary : null,
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
                ),
              ],
            ),
          ),

          // Sticky Bottom Apply Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Clean Card Container for Each Filter Group
class _FilterSectionCard extends StatelessWidget {
  final String title;
  final String? trailingBadge;
  final Widget child;

  const _FilterSectionCard({
    required this.title,
    required this.child,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (trailingBadge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailingBadge!,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
