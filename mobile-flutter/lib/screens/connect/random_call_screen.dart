import 'package:flutter/material.dart';
import '../calls/live_interactive_call_screen.dart';

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  // Active quick filter chip: 'Recommended', 'Nearby', 'Online', 'Interests'
  String _selectedQuickFilter = 'Recommended';
  int _activeIndex = 0;

  // Advanced "More" filter states
  String _callType = 'Both'; // 'Audio', 'Video', 'Both'
  String _genderFilter = 'Everyone'; // 'Women', 'Men', 'Non-binary', 'Everyone'
  RangeValues _ageRange = const RangeValues(18, 35);
  double _maxRadiusKm = 50;
  String _selectedLanguage = 'Any';
  bool _verifiedOnly = false;

  // Mock pool of random-call users with rich metadata so every filter truly updates results
  final List<Map<String, dynamic>> _allCallUsers = const [
    {
      'name': 'Kavya',
      'age': 23,
      'gender': 'Women',
      'distanceKm': 3,
      'isOnline': true,
      'isRecommended': true,
      'verified': true,
      'language': 'Telugu',
      'callType': 'Both',
      'city': 'Madhapur, Hyderabad',
      'interests': ['Coffee Lover', 'Telugu Melodies', 'Road Trips'],
      'avatarUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600',
    },
    {
      'name': 'Arjun',
      'age': 26,
      'gender': 'Men',
      'distanceKm': 2,
      'isOnline': true,
      'isRecommended': false,
      'verified': true,
      'language': 'English',
      'callType': 'Audio',
      'city': 'Gachibowli, Hyderabad',
      'interests': ['PC Gaming', 'Gym & Weight Training', 'Cricket'],
      'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600',
    },
    {
      'name': 'Sneha',
      'age': 24,
      'gender': 'Women',
      'distanceKm': 14,
      'isOnline': true,
      'isRecommended': true,
      'verified': true,
      'language': 'Hindi',
      'callType': 'Video',
      'city': 'Banjara Hills, Hyderabad',
      'interests': ['Photography', 'Movies & Cinema', 'Coffee Lover'],
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
    },
    {
      'name': 'Nikhil',
      'age': 25,
      'gender': 'Men',
      'distanceKm': 6,
      'isOnline': false,
      'isRecommended': true,
      'verified': false,
      'language': 'Telugu',
      'callType': 'Both',
      'city': 'Kukatpally, Hyderabad',
      'interests': ['Bike Rides', 'Street Food', 'PC Gaming'],
      'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
    },
    {
      'name': 'Divya',
      'age': 22,
      'gender': 'Women',
      'distanceKm': 4,
      'isOnline': true,
      'isRecommended': false,
      'verified': true,
      'language': 'English',
      'callType': 'Audio',
      'city': 'Kondapur, Hyderabad',
      'interests': ['Road Trips', 'Anime', 'Live Concerts'],
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
    },
  ];

  // Current user's interests used when "Interests" filter is selected
  final Set<String> _myInterests = const {
    'Coffee Lover',
    'PC Gaming',
    'Road Trips',
    'Telugu Melodies',
  };

  // Dynamically filters & sorts profiles whenever any quick chip or "More" filter changes
  List<Map<String, dynamic>> get _filteredProfiles {
    final results = _allCallUsers.where((user) {
      final age = user['age'] as int;
      final dist = user['distanceKm'] as int;
      final gender = user['gender'] as String;
      final lang = user['language'] as String;
      final callMode = user['callType'] as String;
      final isVerified = user['verified'] as bool;
      final isOnline = user['isOnline'] as bool;
      final userInterests = (user['interests'] as List<String>).toSet();

      // 1. Apply "More" sheet constraints first
      if (age < _ageRange.start.round() || age > _ageRange.end.round()) return false;
      if (dist > _maxRadiusKm.round()) return false;
      if (_genderFilter != 'Everyone' && gender != _genderFilter) return false;
      if (_selectedLanguage != 'Any' && lang != _selectedLanguage) return false;
      if (_verifiedOnly && !isVerified) return false;
      if (_callType != 'Both' && callMode != 'Both' && callMode != _callType) {
        return false;
      }

      // 2. Apply Quick Filter Chip rules
      switch (_selectedQuickFilter) {
        case 'Nearby':
          return dist <= 8;
        case 'Online':
          return isOnline;
        case 'Interests':
          return userInterests.intersection(_myInterests).isNotEmpty;
        case 'Recommended':
        default:
          return true;
      }
    }).toList();

    // Sort dynamically based on selected quick filter
    results.sort((a, b) {
      switch (_selectedQuickFilter) {
        case 'Nearby':
          return (a['distanceKm'] as int).compareTo(b['distanceKm'] as int);
        case 'Online':
          final aOnline = (a['isOnline'] as bool) ? 0 : 1;
          final bOnline = (b['isOnline'] as bool) ? 0 : 1;
          return aOnline.compareTo(bOnline);
        case 'Interests':
          final aOverlap = (a['interests'] as List<String>).toSet().intersection(_myInterests).length;
          final bOverlap = (b['interests'] as List<String>).toSet().intersection(_myInterests).length;
          return bOverlap.compareTo(aOverlap);
        case 'Recommended':
        default:
          final aRec = (a['isRecommended'] as bool) ? 0 : 1;
          final bRec = (b['isRecommended'] as bool) ? 0 : 1;
          return aRec.compareTo(bRec);
      }
    });

    return results;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedQuickFilter = 'Recommended';
      _callType = 'Both';
      _genderFilter = 'Everyone';
      _ageRange = const RangeValues(18, 35);
      _maxRadiusKm = 50;
      _selectedLanguage = 'Any';
      _verifiedOnly = false;
      _activeIndex = 0;
    });
  }

  void _openMoreFiltersSheet() {
    String tempCallType = _callType;
    String tempGender = _genderFilter;
    RangeValues tempAge = _ageRange;
    double tempRadius = _maxRadiusKm;
    String tempLang = _selectedLanguage;
    bool tempVerified = _verifiedOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final primary = Theme.of(context).colorScheme.primary;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Call Preferences',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempCallType = 'Both';
                              tempGender = 'Everyone';
                              tempAge = const RangeValues(18, 35);
                              tempRadius = 50;
                              tempLang = 'Any';
                              tempVerified = false;
                            });
                          },
                          child: Text('Reset', style: TextStyle(color: primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text('Call Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Both', 'Audio', 'Video'].map((t) {
                        return ChoiceChip(
                          label: Text(t),
                          selected: tempCallType == t,
                          onSelected: (_) => setSheetState(() => tempCallType = t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    const Text('Show Me', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Everyone', 'Women', 'Men', 'Non-binary'].map((g) {
                        return ChoiceChip(
                          label: Text(g),
                          selected: tempGender == g,
                          onSelected: (_) => setSheetState(() => tempGender = g),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Age Range', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${tempAge.start.round()} - ${tempAge.end.round()} yrs',
                            style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    RangeSlider(
                      values: tempAge,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: primary,
                      onChanged: (val) => setSheetState(() => tempAge = val),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Distance', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${tempRadius.round()} km',
                            style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: tempRadius,
                      min: 2,
                      max: 150,
                      divisions: 148,
                      activeColor: primary,
                      onChanged: (val) => setSheetState(() => tempRadius = val),
                    ),

                    const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Any', 'Telugu', 'English', 'Hindi'].map((lang) {
                        return ChoiceChip(
                          label: Text(lang),
                          selected: tempLang == lang,
                          onSelected: (_) => setSheetState(() => tempLang = lang),
                        );
                      }).toList(),
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Verified Profiles Only'),
                      activeColor: primary,
                      value: tempVerified,
                      onChanged: (val) => setSheetState(() => tempVerified = val),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _callType = tempCallType;
                          _genderFilter = tempGender;
                          _ageRange = tempAge;
                          _maxRadiusKm = tempRadius;
                          _selectedLanguage = tempLang;
                          _verifiedOnly = tempVerified;
                          _activeIndex = 0;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Call Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startCall(Map<String, dynamic> user, {required bool isVideo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: user['name'] as String,
          avatarUrl: user['avatarUrl'] as String,
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final profiles = _filteredProfiles;
    final safeIndex = profiles.isEmpty ? 0 : _activeIndex.clamp(0, profiles.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Call Lounge', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: _openMoreFiltersSheet,
              icon: Icon(Icons.tune_rounded, size: 18, color: primary),
              label: Text('More', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Recommended', 'Nearby', 'Online', 'Interests'].map((chip) {
                final selected = _selectedQuickFilter == chip;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip),
                    selected: selected,
                    selectedColor: primary.withOpacity(0.16),
                    labelStyle: TextStyle(
                      color: selected ? primary : null,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedQuickFilter = chip;
                        _activeIndex = 0;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: profiles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No matches found for current filters',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _resetAllFilters,
                            child: Text('Reset All Filters', style: TextStyle(color: primary)),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildActiveUserCard(profiles[safeIndex], profiles.length, safeIndex, primary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUserCard(
    Map<String, dynamic> user,
    int totalCount,
    int currentIdx,
    Color primary,
  ) {
    final interests = user['interests'] as List<String>;
    final isOnline = user['isOnline'] as bool;
    final isVerified = user['verified'] as bool;
    final callType = user['callType'] as String;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  user['avatarUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.person, size: 72, color: Colors.white54),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${user['distanceKm']} km away • ${user['language']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      if (isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Online',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${user['name']}, ${user['age']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 20),
                          ],
                        ],
                      ),
                      Text(
                        user['city'] as String,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: interests
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _myInterests.contains(tag)
                                        ? primary.withOpacity(0.8)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconButton(
                  onPressed: totalCount > 1
                      ? () => setState(() => _activeIndex = (currentIdx + 1) % totalCount)
                      : null,
                  icon: const Icon(Icons.skip_next_rounded),
                  tooltip: 'Next Profile (${currentIdx + 1}/$totalCount)',
                ),
                const SizedBox(width: 8),
                if (callType == 'Both' || callType == 'Audio')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _startCall(user, isVideo: false),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Audio'),
                    ),
                  ),
                if (callType == 'Both') const SizedBox(width: 10),
                if (callType == 'Both' || callType == 'Video')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startCall(user, isVideo: true),
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: const Text('Video'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
