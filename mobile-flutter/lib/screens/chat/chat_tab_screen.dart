import 'package:flutter/material.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import 'individual_chat_screen.dart';

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({super.key});

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatRequestItem {
  final String id;
  final String name;
  final String avatar;
  final String message;
  final String time;
  final bool isVerified;
  final bool isBlockedLink;

  const _ChatRequestItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.message,
    required this.time,
    this.isVerified = true,
    this.isBlockedLink = false,
  });
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'messages'; // 'messages' | 'requests'
  String _requestsSubTab = 'received'; // 'received' | 'sent'
  String _selectedFilter = 'all'; // 'all', 'unread', 'online', 'verified'

  String _whoCanMessage = 'everyone'; // 'everyone', 'matches', 'nobody'

  final List<_ChatRequestItem> _receivedRequests = [
    const _ChatRequestItem(
      id: 'r1',
      name: 'Sana',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      message: 'Hey Alex! Loved your profile taste in indie vinyls 🎵 Let\'s catch coffee sometime?',
      time: '1h ago',
      isVerified: true,
    ),
    const _ChatRequestItem(
      id: 'r2',
      name: 'Aryan',
      avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
      message: 'Message hidden (link blocked)',
      time: '3h ago',
      isVerified: true,
      isBlockedLink: true,
    ),
    const _ChatRequestItem(
      id: 'r3',
      name: 'Nisha',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      message: 'Hi! Are you also into photography and weekend hikes around Bandra?',
      time: '5h ago',
      isVerified: true,
    ),
  ];

  final List<_ChatRequestItem> _sentRequests = [
    const _ChatRequestItem(
      id: 's1',
      name: 'Priya',
      avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      message: 'Would love to explore Subko coffee with you this Saturday!',
      time: 'Yesterday',
      isVerified: true,
    ),
    const _ChatRequestItem(
      id: 's2',
      name: 'Tanya',
      avatar: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=800&q=80',
      message: 'Subko sourdough flatbread sounds delicious 🥐',
      time: '2d ago',
      isVerified: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1B1119),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChatSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1119),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chat settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Who can message me',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 14),
                    _settingsRadio('Everyone', 'everyone', 'Anyone on YoUnMe can send message requests', setSheetState),
                    _settingsRadio('Matches', 'matches', 'Only mutual matches can start conversations', setSheetState),
                    _settingsRadio('Nobody', 'nobody', 'Pause incoming messages and requests temporarily', setSheetState),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _settingsRadio(String title, String val, String subtitle, StateSetter setSheetState) {
    final selected = _whoCanMessage == val;
    return GestureDetector(
      onTap: () {
        setSheetState(() => _whoCanMessage = val);
        setState(() => _whoCanMessage = val);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0x33EC4899) : const Color(0xFF241822),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFEC4899) : const Color(0xFF2E1E2B),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFFEC4899) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final allConversations = AppDataService.instance.conversations;
        final filtered = allConversations.where((conv) {
          final query = _searchQuery.trim().toLowerCase();
          final matches = query.isEmpty ||
              conv.name.toLowerCase().contains(query) ||
              conv.lastMessage.toLowerCase().contains(query);
          if (!matches) return false;
          switch (_selectedFilter) {
            case 'unread':
              return conv.unreadCount > 0;
            case 'online':
              return conv.isOnline;
            case 'verified':
              return conv.isVerified;
            default:
              return true;
          }
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0D070C),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: "Chats" (Messages, requests & connections) + 3 icon buttons: Audio Call, Video Call, Settings Gear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Messages, requests & connections',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Audio Call icon button
                          GestureDetector(
                            onTap: () => _showSnack('Calls are available inside a chat'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1119),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E1E2B)),
                              ),
                              child: const Icon(Icons.call_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Video Call icon button
                          GestureDetector(
                            onTap: () => _showSnack('Calls are available inside a chat'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1119),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E1E2B)),
                              ),
                              child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Settings Gear
                          GestureDetector(
                            onTap: _openChatSettingsSheet,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1119),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E1E2B)),
                              ),
                              child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Main toggle pills: Messages | Requests [3]
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1119),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E1E2B)),
                    ),
                    child: Row(
                      children: [
                        _tabToggle('Messages', 'messages'),
                        _tabToggle('Requests [3]', 'requests'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_selectedTab == 'messages') ...[
                    // Search bar "Search chats by name"
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: const InputDecoration(
                                hintText: 'Search chats by name',
                                hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // "Invite to App" card with "Sync" pink button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0x33EC4899),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_add_outlined, color: Color(0xFFEC4899), size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invite to App', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text('Sync phone contacts to find friends discreetly', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showSnack('Contacts synced! Found 2 friends on YoUnMe ✨');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                                ),
                              ),
                              child: const Text('Sync', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter pills: All, Unread, Online, Verified
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('All', 'all', allConversations.length),
                          _filterChip('Unread', 'unread', allConversations.where((c) => c.unreadCount > 0).length),
                          _filterChip('Online', 'online', allConversations.where((c) => c.isOnline).length),
                          _filterChip('Verified', 'verified', allConversations.where((c) => c.isVerified).length),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Conversation list (Ananya ✓ — "Haha great taste! What ind... 13h")
                    ...filtered.map((conv) => _buildConversationTile(conv)),
                  ] else ...[
                    // Requests [3] view
                    _buildRequestsView(),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabToggle(String label, String key) {
    final active = _selectedTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEC4899)])
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, String key, int count) {
    final active = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0x33EC4899) : const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? const Color(0xFFEC4899) : const Color(0xFF2E1E2B),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? const Color(0xFFEC4899) : const Color(0xFF9CA3AF),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 10,
                  color: active ? const Color(0xFFEC4899) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ChatConversationModel conv) {
    final hasUnread = conv.unreadCount > 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IndividualChatScreen(conversation: conv)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread ? const Color(0x66EC4899) : const Color(0xFF2E1E2B),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: conv.avatarAsset != null ? AssetImage(conv.avatarAsset!) : null,
                  backgroundColor: const Color(0xFF241822),
                  child: conv.avatarAsset == null
                      ? Text(conv.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                      : null,
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1B1119), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conv.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (conv.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: Color(0xFF38BDF8)),
                      ],
                      const Spacer(),
                      Text(
                        conv.timestamp,
                        style: TextStyle(fontSize: 10.5, color: hasUnread ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread ? Colors.white : const Color(0xFF9CA3AF),
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REQUESTS [3] VIEW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRequestsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-pills: Received (3) | Sent (2)
        Row(
          children: [
            _requestsSubPill('Received (3)', 'received'),
            const SizedBox(width: 8),
            _requestsSubPill('Sent (2)', 'sent'),
          ],
        ),
        const SizedBox(height: 12),

        // Counter row: "✉️ 3/10 requests used today" + "+ New Request" pink button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1119),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2E1E2B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('✉️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    '3/10 requests used today',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showSnack('Select profile from Discovery to send new request ✨'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEC4899)]),
                  ),
                  child: const Text(
                    '+ New Request',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Request cards list
        if (_requestsSubTab == 'received')
          ..._receivedRequests.map((req) => _buildRequestCard(req))
        else
          ..._sentRequests.map((req) => _buildRequestCard(req, isSent: true)),
      ],
    );
  }

  Widget _requestsSubPill(String label, String key) {
    final active = _requestsSubTab == key;
    return GestureDetector(
      onTap: () => setState(() => _requestsSubTab = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEC4899) : const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? const Color(0xFFEC4899) : const Color(0xFF2E1E2B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(_ChatRequestItem req, {bool isSent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1119),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E1E2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(req.avatar)),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(req.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    if (req.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Color(0xFF38BDF8)),
                    ],
                  ],
                ),
              ),
              Text(req.time, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),

          // Blocked link amber warning box if applicable
          if (req.isBlockedLink)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0x26F59E0B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x66F59E0B)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Message hidden (link blocked by Trust Guard)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              req.message,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.35),
            ),

          if (!isSent) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showSnack('Declined request from ${req.name}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF241822),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E1E2B)),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showSnack('Accepted request! Chat unlocked with ${req.name} 🎉'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEC4899)]),
                    ),
                    child: const Text('✓ Accept', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
