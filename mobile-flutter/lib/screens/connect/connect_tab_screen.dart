import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/profiles_data.dart';
import '../../models/discovery_connect_models.dart';
import '../calls/live_interactive_call_screen.dart';

class ConnectTabScreen extends StatefulWidget {
  const ConnectTabScreen({super.key});

  @override
  State<ConnectTabScreen> createState() => _ConnectTabScreenState();
}

class _ConnectTabScreenState extends State<ConnectTabScreen>
    with SingleTickerProviderStateMixin {
  int _subTabIndex = 0; // 0: Random call, 1: Likes, 2: Matches
  String _activeFilter = 'Recommended';
  String? _expandedFloatingAvatarId;

  late final AnimationController _waveCtrl;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _cardBg => _isDark ? const Color(0xFF1B1119) : Colors.white;
  Color get _elevatedBg =>
      _isDark ? const Color(0xFF241822) : const Color(0xFFF3F4F6);
  Color get _innerBg =>
      _isDark ? const Color(0xFF140A12) : const Color(0xFFF8FAFC);
  Color get _borderCol =>
      _isDark ? const Color(0xFF2E1E2B) : Colors.grey.shade200;
  Color get _primaryText => _isDark ? Colors.white : const Color(0xFF181A24);
  Color get _mutedText =>
      _isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;

  final List<String> _filters = [
    'Recommended',
    'Nearby',
    '• Online',
    'Interests'
  ];

  // Advanced "More" filter states for Random Calls
  String _callType = 'Both'; // 'Audio', 'Video', 'Both'
  String _genderFilter = 'Everyone'; // 'Women', 'Men', 'Non-binary', 'Everyone'
  RangeValues _ageRange = const RangeValues(18, 35);
  double _maxRadiusKm = 50;
  String _selectedLanguage = 'Any';
  bool _verifiedOnly = false;

  final List<Map<String, dynamic>> _allCallUsers = const [
    {
      'id': 'f_1',
      'name': 'Kavya',
      'age': 23,
      'gender': 'Women',
      'distanceKm': 3,
      'isOnline': true,
      'isRecommended': true,
      'verified': true,
      'language': 'Telugu',
      'sticker': '🦊',
      'callType': 'Both',
      'ringColor': Color(0xFF38BDF8),
      'interests': ['Coffee Lover', 'Telugu Melodies', 'Road Trips'],
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'f_2',
      'name': 'Aanya',
      'age': 24,
      'gender': 'Women',
      'distanceKm': 14,
      'isOnline': true,
      'isRecommended': true,
      'verified': true,
      'language': 'Hindi',
      'sticker': '🐰',
      'callType': 'Video',
      'ringColor': Color(0xFFEC4899),
      'interests': ['Photography', 'Movies & Cinema', 'Coffee Lover'],
      'avatar':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'f_3',
      'name': 'Rohan',
      'age': 26,
      'gender': 'Men',
      'distanceKm': 2,
      'isOnline': true,
      'isRecommended': false,
      'verified': true,
      'language': 'English',
      'sticker': '🐼',
      'callType': 'Audio',
      'ringColor': Color(0xFF22C55E),
      'interests': ['PC Gaming', 'Gym & Weight Training', 'Cricket'],
      'avatar':
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'f_4',
      'name': 'Sneha',
      'age': 22,
      'gender': 'Women',
      'distanceKm': 5,
      'isOnline': false,
      'isRecommended': true,
      'verified': true,
      'language': 'Tamil',
      'sticker': '🐱',
      'callType': 'Both',
      'ringColor': Color(0xFFA855F7),
      'interests': ['Road Trips', 'Anime', 'Live Concerts'],
      'avatar':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'f_5',
      'name': 'Nikhil',
      'age': 25,
      'gender': 'Men',
      'distanceKm': 6,
      'isOnline': false,
      'isRecommended': true,
      'verified': false,
      'language': 'Telugu',
      'sticker': '🦁',
      'callType': 'Both',
      'ringColor': Color(0xFFF59E0B),
      'interests': ['Bike Rides', 'Street Food', 'PC Gaming'],
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
    },
  ];

  final Set<String> _myInterests = const {
    'Coffee Lover',
    'PC Gaming',
    'Road Trips',
    'Telugu Melodies',
  };

  List<Map<String, dynamic>> get _filteredCallUsers {
    final results = _allCallUsers.where((user) {
      final age = user['age'] as int;
      final dist = user['distanceKm'] as int;
      final gender = user['gender'] as String;
      final lang = user['language'] as String;
      final callMode = user['callType'] as String;
      final isVerified = user['verified'] as bool;
      final isOnline = user['isOnline'] as bool;
      final userInterests = (user['interests'] as List<String>).toSet();

      if (age < _ageRange.start.round() || age > _ageRange.end.round()) {
        return false;
      }
      if (dist > _maxRadiusKm.round()) return false;
      if (_genderFilter != 'Everyone' && gender != _genderFilter) return false;
      if (_selectedLanguage != 'Any' && lang != _selectedLanguage) return false;
      if (_verifiedOnly && !isVerified) return false;
      if (_callType != 'Both' && callMode != 'Both' && callMode != _callType) {
        return false;
      }

      switch (_activeFilter) {
        case 'Nearby':
          return dist <= 8;
        case '• Online':
          return isOnline;
        case 'Interests':
          return userInterests.intersection(_myInterests).isNotEmpty;
        case 'Recommended':
        default:
          return true;
      }
    }).toList();

    results.sort((a, b) {
      switch (_activeFilter) {
        case 'Nearby':
          return (a['distanceKm'] as int).compareTo(b['distanceKm'] as int);
        case '• Online':
          final aOnline = (a['isOnline'] as bool) ? 0 : 1;
          final bOnline = (b['isOnline'] as bool) ? 0 : 1;
          return aOnline.compareTo(bOnline);
        case 'Interests':
          final aOverlap = (a['interests'] as List<String>)
              .toSet()
              .intersection(_myInterests)
              .length;
          final bOverlap = (b['interests'] as List<String>)
              .toSet()
              .intersection(_myInterests)
              .length;
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
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                        Text(
                          'Random Call Filters',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryText),
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
                          child: const Text('Reset',
                              style: TextStyle(color: Color(0xFFEC4899))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Call Mode',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _primaryText)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Both', 'Audio', 'Video'].map((t) {
                        final selected = tempCallType == t;
                        return ChoiceChip(
                          label: Text(t,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : _mutedText)),
                          selected: selected,
                          selectedColor: const Color(0xFFEC4899),
                          backgroundColor: _elevatedBg,
                          onSelected: (_) =>
                              setSheetState(() => tempCallType = t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text('Show Me',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _primaryText)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['Everyone', 'Women', 'Men', 'Non-binary'].map((g) {
                        final selected = tempGender == g;
                        return ChoiceChip(
                          label: Text(g,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : _mutedText)),
                          selected: selected,
                          selectedColor: const Color(0xFFEC4899),
                          backgroundColor: _elevatedBg,
                          onSelected: (_) =>
                              setSheetState(() => tempGender = g),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Age Range',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _primaryText)),
                        Text(
                            '${tempAge.start.round()} - ${tempAge.end.round()} yrs',
                            style: const TextStyle(
                                color: Color(0xFFEC4899),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    RangeSlider(
                      values: tempAge,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: const Color(0xFFEC4899),
                      onChanged: (val) => setSheetState(() => tempAge = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Max Distance',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _primaryText)),
                        Text('${tempRadius.round()} km',
                            style: const TextStyle(
                                color: Color(0xFFEC4899),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: tempRadius,
                      min: 2,
                      max: 150,
                      divisions: 148,
                      activeColor: const Color(0xFFEC4899),
                      onChanged: (val) => setSheetState(() => tempRadius = val),
                    ),
                    Text('Language',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _primaryText)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Any', 'Telugu', 'English', 'Hindi', 'Tamil']
                          .map((lang) {
                        final selected = tempLang == lang;
                        return ChoiceChip(
                          label: Text(lang,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : _mutedText)),
                          selected: selected,
                          selectedColor: const Color(0xFFEC4899),
                          backgroundColor: _elevatedBg,
                          onSelected: (_) =>
                              setSheetState(() => tempLang = lang),
                        );
                      }).toList(),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Verified Profiles Only',
                          style: TextStyle(color: _primaryText)),
                      activeColor: const Color(0xFFEC4899),
                      value: tempVerified,
                      onChanged: (val) =>
                          setSheetState(() => tempVerified = val),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          setState(() {
                            _callType = tempCallType;
                            _genderFilter = tempGender;
                            _ageRange = tempAge;
                            _maxRadiusKm = tempRadius;
                            _selectedLanguage = tempLang;
                            _verifiedOnly = tempVerified;
                            _expandedFloatingAvatarId = null;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Apply Call Filters',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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

  final List<SparkCrushItem> _megaCrushes = kSparkCrushList;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  void _startCall(String name, String avatar, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: name,
          avatarUrl: avatar,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _openPickPromptModal(String partnerName) {
    final prompts = [
      'Subko coffee or cozy midnight drives?',
      'If you could teleport right now, where in Mumbai would we go?',
      'What is your go-to song when you need instant good vibes?',
      'Tell me the best dish you can make in 15 minutes!',
      'Are you more of an acoustic sunset person or a neon rooftop person?',
      'What is the most spontaneous thing you did this year?',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _borderCol)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pick Prompt for $partnerName',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _primaryText),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _mutedText, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...prompts.map((prompt) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _elevatedBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderCol),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          prompt,
                          style: TextStyle(
                              fontSize: 12, color: _primaryText, height: 1.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Prompt sent to $partnerName! 🚀'),
                              backgroundColor: const Color(0xFFEC4899),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                            ),
                          ),
                          child: const Text(
                            'Send ▷',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top segmented pill switcher: Random call | Likes | Matches
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderCol),
                ),
                child: Row(
                  children: [
                    _segmentedButton('Random call', 0),
                    _segmentedButton('Likes', 1),
                    _segmentedButton('Matches', 2),
                  ],
                ),
              ),
            ),

            // Main body for each sub-tab
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSubTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedButton(String label, int index) {
    final active = _subTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                  )
                : null,
            color: active ? null : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : _mutedText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabContent() {
    switch (_subTabIndex) {
      case 0:
        return _buildRandomCallSubTab();
      case 1:
        return _buildLikesSubTab();
      case 2:
      default:
        return _buildMatchesSubTab();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 1: RANDOM CALL
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRandomCallSubTab() {
    final filteredUsers = _filteredCallUsers;
    final bobbingProfiles = filteredUsers.take(4).map((u) {
      return RandomCallAvatarProfile(
        id: u['id'] as String,
        name: u['name'] as String,
        sticker: u['sticker'] as String,
        language: u['language'] as String,
        avatar: u['avatar'] as String,
        ringColor: u['ringColor'] as Color,
      );
    }).toList();

    final hasMoreFiltersActive = _callType != 'Both' ||
        _genderFilter != 'Everyone' ||
        _selectedLanguage != 'Any' ||
        _verifiedOnly ||
        _maxRadiusKm < 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal filter pills + "More" filter icon
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._filters.map((f) {
                final active = _activeFilter == f;
                return GestureDetector(
                  onTap: () => setState(() {
                    _activeFilter = f;
                    _expandedFloatingAvatarId = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFEC4899) : _cardBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active ? const Color(0xFFEC4899) : _borderCol,
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? Colors.white : _mutedText,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _openMoreFiltersSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: hasMoreFiltersActive
                        ? const Color(0x26EC4899)
                        : _cardBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: hasMoreFiltersActive
                          ? const Color(0xFFEC4899)
                          : _borderCol,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune,
                        size: 14,
                        color: hasMoreFiltersActive
                            ? const Color(0xFFEC4899)
                            : _mutedText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'More',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: hasMoreFiltersActive
                              ? const Color(0xFFEC4899)
                              : _mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick-connect CTA buttons side-by-side
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (filteredUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No profiles match your filters')),
                    );
                    return;
                  }
                  final target = filteredUsers.first;
                  _startCall(target['name'] as String,
                      target['avatar'] as String, false);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x3322C55E),
                          blurRadius: 12,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Join Audio Call',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (filteredUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No profiles match your filters')),
                    );
                    return;
                  }
                  final target = filteredUsers.first;
                  _startCall(target['name'] as String,
                      target['avatar'] as String, true);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x33EC4899),
                          blurRadius: 12,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Join Video Call',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Dual Sinusoidal Bézier Wave Canvas with 4 Undulating Bobbing Avatars
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waves, size: 18, color: Color(0xFFEC4899)),
                      const SizedBox(width: 6),
                      Text(
                        'Random calls',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _primaryText),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '[Live]',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E)),
                      ),
                    ],
                  ),
                  Text('Tap avatar to connect',
                      style: TextStyle(fontSize: 11, color: _mutedText)),
                ],
              ),
              const SizedBox(height: 12),

              // Animated Canvas with Bézier Waves and Bobbing Avatars
              SizedBox(
                height: 180,
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        // Dual sinusoidal canvas
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _SinusoidalWavePainter(
                              phase: _waveCtrl.value * 2 * math.pi,
                            ),
                          ),
                        ),

                        // 4 Undulating Bobbing Avatars along the waves
                        ...List.generate(bobbingProfiles.length, (i) {
                          final p = bobbingProfiles[i];
                          final isExpanded = _expandedFloatingAvatarId == p.id;
                          final phaseOffset = (i * 1.5);
                          final bobbingY = math.sin(
                                  (_waveCtrl.value * 2 * math.pi) +
                                      phaseOffset) *
                              16.0;

                          // Left positions: 6%, 30%, 54%, 78%
                          final leftPercent = 0.05 + (i * 0.24);

                          return Positioned(
                            left: leftPercent *
                                (MediaQuery.of(context).size.width - 70),
                            top: 42 + bobbingY,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedFloatingAvatarId =
                                      isExpanded ? null : p.id;
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isExpanded
                                                ? const Color(0xFFEC4899)
                                                : p.ringColor,
                                            width: isExpanded ? 2.5 : 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: p.ringColor
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(27),
                                          child: SafeProfileImage(
                                              imageUrl: p.avatar,
                                              width: 54,
                                              height: 54),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 17,
                                          height: 17,
                                          decoration: const BoxDecoration(
                                              color: Color(0xCC000000),
                                              shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text(p.sticker,
                                              style: const TextStyle(
                                                  fontSize: 9.5)),
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: CircleAvatar(
                                            radius: 4.5,
                                            backgroundColor: Color(0xFF22C55E)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(p.name,
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: _primaryText)),
                                  Text(p.language,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: _mutedText)),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _startCall(
                                              p.name, p.avatar, false),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            margin:
                                                const EdgeInsets.only(right: 3),
                                            decoration: const BoxDecoration(
                                                color: Color(0xFF22C55E),
                                                shape: BoxShape.circle),
                                            child: const Icon(Icons.call,
                                                size: 12, color: Colors.white),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _startCall(
                                              p.name, p.avatar, true),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFF38BDF8),
                                                shape: BoxShape.circle),
                                            child: const Icon(Icons.videocam,
                                                size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Random Call Metrics Card (Time spent, total calls, weekly insights)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assessment_outlined,
                      color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Random Call Metrics',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _primaryText),
                  ),
                  const Spacer(),
                  Text('Weekly Activity',
                      style: TextStyle(fontSize: 10.5, color: _mutedText)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricBox('3h 42m', 'Time Spent', Icons.timer,
                      const Color(0xFFEC4899)),
                  _metricBox('18 Calls', 'Total Calls', Icons.phone_in_talk,
                      const Color(0xFF22C55E)),
                  _metricBox('+28% Wk', 'Weekly Insights', Icons.trending_up,
                      const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Random Call History Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Random Call History',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryText),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x26EC4899),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Recent Voice & Video',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEC4899))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _callHistoryTile('Kavya', 'Video Call • 14m 20s', 'Today, 11:20 AM',
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
            isVideo: true, rating: '5.0 ⭐'),
        _callHistoryTile('Aanya', 'Audio Call • 8m 45s', 'Yesterday, 8:15 PM',
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
            isVideo: false, rating: '4.8 ⭐'),
        _callHistoryTile('Rohan', 'Audio Call • 12m 10s', 'Nov 15, 6:40 PM',
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80',
            isVideo: false, rating: '4.9 ⭐'),
        _callHistoryTile('Sneha', 'Video Call • 22m 30s', 'Nov 14, 9:05 PM',
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
            isVideo: true, rating: '5.0 ⭐'),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _metricBox(String value, String label, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 76) / 3,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: _innerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: _primaryText)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9.5, color: _mutedText)),
        ],
      ),
    );
  }

  Widget _callHistoryTile(
      String name, String typeAndDuration, String time, String avatar,
      {required bool isVideo, required String rating}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderCol),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _primaryText)),
                    const SizedBox(width: 6),
                    Text(rating,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFFF59E0B))),
                  ],
                ),
                Text(typeAndDuration,
                    style: TextStyle(fontSize: 10.5, color: _mutedText)),
                Text(time,
                    style: const TextStyle(
                        fontSize: 9.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _startCall(name, avatar, isVideo),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isVideo ? const Color(0x2638BDF8) : const Color(0x2622C55E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isVideo
                        ? const Color(0x8038BDF8)
                        : const Color(0x8022C55E)),
              ),
              child: Row(
                children: [
                  Icon(isVideo ? Icons.videocam : Icons.call,
                      size: 13,
                      color: isVideo
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF22C55E)),
                  const SizedBox(width: 4),
                  Text(
                    'Call Back',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isVideo
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 2: LIKES (TERMINOLOGY "MEGA CRUSH" & 50-ITEM VERTICAL REELS SCROLL BOX)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLikesSubTab() {
    final history = generate50LikesHistory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔥 Mega Crushes (5) (Priority Matches pink label)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🔥 Mega Crushes (5)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryText),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x33EC4899),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Priority Matches',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEC4899))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _megaCrushes.length,
            itemBuilder: (context, i) {
              final s = _megaCrushes[i];
              return Container(
                width: 105,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderCol),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(s.avatar),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.name}, ${s.age}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Mega Crush',
                      style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFFEC4899),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Weekly Activity & Insights (Live Analytics) - 4-column stat box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined,
                      color: Color(0xFF38BDF8), size: 16),
                  const SizedBox(width: 6),
                  Text('Weekly Activity & Insights',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _primaryText)),
                  const Spacer(),
                  Text('Live Analytics',
                      style: TextStyle(fontSize: 10, color: _mutedText)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('24', 'Likes Sent', '+18%'),
                  _statItem('8', 'Mega Crushes', '+35%'),
                  _statItem('3', 'Top Admirers', '100%'),
                  _statItem('8', 'Matches/Wk', '92% rate'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 10 People Liked You
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10 People Liked You',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _primaryText)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x2622C55E),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0x8022C55E)),
              ),
              child: const Text('Free Tier v1: Full View Active',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22C55E))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, i) {
              final p = kDemoProfiles[i % kDemoProfiles.length];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(p.photoUrls.first),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Contained 50-Item Vertical Reels Scroll Box in Like History with Snapping
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Likes History (50 Profiles)',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _primaryText)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x33EC4899),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0x66EC4899)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.unfold_more, size: 12, color: Color(0xFFFF8DA1)),
                  SizedBox(width: 4),
                  Text('Vertical Reels Snapping',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF8DA1))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Contained Box with Vertical Page Snapping
        Container(
          height: 380,
          decoration: BoxDecoration(
            color: _innerBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderCol),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ListView.builder(
              physics: const PageScrollPhysics(), // Snapping reels scroll
              itemCount: history.length, // All 50 items
              itemBuilder: (ctx, i) {
                final h = history[i];
                final isMegaCrush = h.type == 'mega_crush';
                final isPass = h.type == 'passed';
                final badgeColor = isMegaCrush
                    ? const Color(0xFFEC4899)
                    : isPass
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF22C55E);

                return Container(
                  height: 95,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMegaCrush ? const Color(0x66EC4899) : _borderCol,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 26, backgroundImage: NetworkImage(h.avatar)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text('${h.name}, ${h.age}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryText)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color:
                                            badgeColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    isMegaCrush
                                        ? 'MEGA CRUSH'
                                        : h.type.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: badgeColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('${h.city} • ${h.timestamp}',
                                style:
                                    TextStyle(fontSize: 11, color: _mutedText)),
                            Text(
                              h.interests.take(2).join(' • '),
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFFFF8DA1)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Matched with ${h.name}! ✨')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFE11D48), Color(0xFFEC4899)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Match',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statItem(String val, String label, String trend) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _primaryText)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: _mutedText)),
        const SizedBox(height: 2),
        Text(trend,
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF22C55E))),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 3: MATCHES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMatchesSubTab() {
    final matches = generate50Matches();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🏆 Weekly Vibe Scoreboard (Top 3 Vibed)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🏆 Weekly Vibe Scoreboard',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryText),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x26F59E0B),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Top 3 Vibed',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF59E0B))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _podiumCard('#1 Ananya', '98% Vibe',
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
                isGold: true),
            const SizedBox(width: 8),
            _podiumCard('#2 Kavya', '97% Vibe',
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80'),
            const SizedBox(width: 8),
            _podiumCard('#3 Meera', '96% Vibe',
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80'),
          ],
        ),
        const SizedBox(height: 18),

        // Make First Move (Break the ice)
        Text('Make First Move',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryText)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
                child: _makeFirstMoveCard('Ananya', '99% Match',
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80')),
            const SizedBox(width: 10),
            Expanded(
                child: _makeFirstMoveCard('Kavya', '98% Match',
                    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80')),
          ],
        ),
        const SizedBox(height: 18),

        // Matches History (50)
        Text('Matches History (50)',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryText)),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (ctx, i) {
            final m = matches[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderCol),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 20, backgroundImage: NetworkImage(m.avatar)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m.name}, ${m.age} • ${m.matchPercentage}%',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _primaryText)),
                        Text('${m.city} • ${m.lastActive}',
                            style: TextStyle(fontSize: 10.5, color: _mutedText)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call,
                        color: Color(0xFF22C55E), size: 18),
                    onPressed: () => _startCall(m.name, m.avatar, false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFFEC4899), size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Opening chat with ${m.name}...')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Potential Matches (10)
        Text('Potential Matches (10)',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryText)),
        const SizedBox(height: 10),

        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (ctx, i) {
              final m = matches[i];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Previewing ${m.name}\'s profile card ✨')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(m.avatar),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Matched Recently Metrics
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderCol),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 6),
              Text(
                '18.4% swipe-to-match • 94% avg compatibility',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _podiumCard(String rankAndName, String vibeScore, String avatar,
      {bool isGold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGold ? const Color(0xFFF59E0B) : _borderCol,
            width: isGold ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar)),
            const SizedBox(height: 6),
            Text(
              rankAndName,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primaryText),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              vibeScore,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isGold
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEC4899)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeFirstMoveCard(String name, String matchPercent, String avatar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderCol),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 26, backgroundImage: NetworkImage(avatar)),
          const SizedBox(height: 6),
          Text(name,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _primaryText)),
          Text(matchPercent,
              style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF22C55E),
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chat opened with $name')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _elevatedBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderCol),
                    ),
                    alignment: Alignment.center,
                    child: Text('Chat',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _primaryText)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openPickPromptModal(name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('💡 Prompt',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SinusoidalWavePainter extends CustomPainter {
  final double phase;

  _SinusoidalWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerY = height * 0.52;

    // First Sinusoidal Bézier wave: Rose/Crimson
    final path1 = Path();
    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFEC4899), Color(0xFFFB7185)],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Second Sinusoidal Bézier wave: Sky/Cyan
    final path2 = Path();
    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF38BDF8), Color(0xFF818CF8)],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final amplitude1 = height * 0.22;
    final amplitude2 = height * 0.18;
    final phase2 = phase + (math.pi / 2);

    path1.moveTo(0, centerY + math.sin(phase) * amplitude1);
    path2.moveTo(0, centerY + math.cos(phase2) * amplitude2);

    for (double x = 0; x <= width; x += 4) {
      final t = (x / width) * 2 * math.pi;
      final y1 = centerY + math.sin(t + phase) * amplitude1;
      final y2 = centerY + math.sin(t * 1.5 + phase2) * amplitude2;
      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _SinusoidalWavePainter oldDelegate) => true;
}
