import 'package:flutter/material.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import 'individual_chat_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reference-screen design tokens (deep dark purple-black theme)
// ─────────────────────────────────────────────────────────────────────────────
class _RefColors {
  _RefColors._();

  static const Color bg = Color(0xFF130E1A);
  static const Color cardFill = Color(0x14FFFFFF); // semi-transparent surface
  static const Color cardBorder = Color(0x24FFFFFF);
  static const Color pink = Color(0xFFFF2D55);
  static const Color pinkSoft = Color(0xFFFF6B8B);
  static const Color gold = Color(0xFFFFD700);
  static const Color verifiedBlue = Color(0xFF4DA3FF);
  static const Color online = Color(0xFF00E676);

  static const LinearGradient titleGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFFF6B8B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient pillGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class _ChatRequest {
  final String name;
  final String? avatarAsset;
  final String time;
  final String message;

  const _ChatRequest({
    required this.name,
    this.avatarAsset,
    required this.time,
    required this.message,
  });
}

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({super.key});

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, unread, online, verified
  String _selectedTab = 'messages'; // messages, requests

  static const List<_ChatRequest> _requests = [
    _ChatRequest(
      name: 'Priya Nair',
      avatarAsset: 'assets/images/ananya.jpg',
      time: '2h',
      message: 'Hi Alex! We matched at the Indie music meetup last week',
    ),
    _ChatRequest(
      name: 'Kabir Singh',
      avatarAsset: 'assets/images/rohit.jpg',
      time: '8h',
      message: 'Hey! Your startup post was great. Mind connecting?',
    ),
    _ChatRequest(
      name: 'Sana Iyer',
      avatarAsset: 'assets/images/riya.jpg',
      time: '1d',
      message: 'Loved your film photography. Which camera do you use?',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF231A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDarkMode;

    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final allConversations = AppDataService.instance.conversations;
        final unreadMsgTotal = allConversations.fold<int>(
          0,
          (sum, c) => sum + c.unreadCount,
        );

        final filtered = allConversations.where((conv) {
          final query = _searchQuery.trim().toLowerCase();
          final matchesQuery = query.isEmpty ||
              conv.name.toLowerCase().contains(query) ||
              conv.lastMessage.toLowerCase().contains(query);
          if (!matchesQuery) return false;

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

        return Container(
          color: isDark ? _RefColors.bg : theme.bgSurface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(isDark),
                      const SizedBox(height: 18),
                      _buildChatsTitleBar(theme, unreadMsgTotal),
                      const SizedBox(height: 16),
                      _buildSwitcherTabs(unreadMsgTotal),
                      const SizedBox(height: 14),
                      _buildSearchBar(theme, isDark),
                      const SizedBox(height: 14),
                      if (_selectedTab == 'messages') ...[
                        _buildFilterPills(theme, isDark, allConversations),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),

              if (_selectedTab == 'requests')
                _buildRequestsList(theme, isDark)
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'Search Results (${filtered.length})'
                          : 'Conversations (${filtered.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(theme),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final conv = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: _buildChatCard(context, conv, theme, isDark),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        );
      },
    );
  }

  // ─── 2. Top header: back arrow, gradient "Chat", coin / streak / bell ──────
  Widget _buildTopHeader(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showSnack('Back'),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _RefColors.cardFill,
              shape: BoxShape.circle,
              border: Border.all(color: _RefColors.cardBorder),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ShaderMask(
          shaderCallback: (bounds) =>
              _RefColors.titleGradient.createShader(bounds),
          child: const Text(
            'Chat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        _buildCoinBadge(),
        const SizedBox(width: 8),
        _buildStreakBadge(),
        const SizedBox(width: 8),
        _buildBellButton(),
      ],
    );
  }

  Widget _buildCoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _RefColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _RefColors.gold.withValues(alpha: 0.35)),
      ),
      child: const Text(
        '250 Coins',
        style: TextStyle(
          color: _RefColors.gold,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
        ),
      ),
      child: const Text(
        '4 Streak',
        style: TextStyle(
          color: Color(0xFFFF6B35),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBellButton() {
    return GestureDetector(
      onTap: () => _showSnack('No new notifications'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _RefColors.cardFill,
          shape: BoxShape.circle,
          border: Border.all(color: _RefColors.cardBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: Colors.white,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _RefColors.pink,
                  shape: BoxShape.circle,
                  border: Border.all(color: _RefColors.bg, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 3. "Chats" section header + quick actions + demo pill ────────────────
  Widget _buildChatsTitleBar(YoUnMeThemeExtension theme, int unreadMsgTotal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (unreadMsgTotal > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _RefColors.pink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadMsgTotal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Messages, requests & connections',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _RefColors.gold.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Demo data',
                  style: TextStyle(
                    color: Color(0xFF2B2100),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildHeaderIcon(
          Icons.phone_outlined,
          'Voice calls',
          () => _showSnack('Voice calls coming soon'),
        ),
        const SizedBox(width: 8),
        _buildHeaderIcon(
          Icons.sync_rounded,
          'Sync contacts',
          _showInviteToAppModal,
        ),
        const SizedBox(width: 8),
        _buildHeaderIcon(
          Icons.settings_outlined,
          'Chat settings',
          _showChatSettingsSheet,
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _RefColors.cardFill,
            shape: BoxShape.circle,
            border: Border.all(color: _RefColors.cardBorder),
          ),
          child: Icon(icon, size: 19, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
    );
  }

  // ─── 4. Messages / Requests switcher ──────────────────────────────────────
  Widget _buildSwitcherTabs(int unreadMsgTotal) {
    Widget tab(String key, String label, {int? badge}) {
      final selected = _selectedTab == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: selected ? _RefColors.pillGradient : null,
              color: selected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (badge != null && badge > 0) ...[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.25)
                          : _RefColors.pink,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _RefColors.cardFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _RefColors.cardBorder),
      ),
      child: Row(
        children: [
          tab('messages', 'Messages'),
          tab('requests', 'Requests', badge: _requests.length),
        ],
      ),
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar(YoUnMeThemeExtension theme, bool isDark) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? _RefColors.cardFill : theme.searchFill,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _RefColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: theme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: theme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search chats by name',
                hintStyle: TextStyle(color: Color(0xFF6E6480), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Icon(Icons.close, size: 18, color: theme.textMuted),
            ),
        ],
      ),
    );
  }

  // ─── Filter pills: All / Unread / Online / Verified ───────────────────────
  Widget _buildFilterPills(
    YoUnMeThemeExtension theme,
    bool isDark,
    List<ChatConversationModel> all,
  ) {
    Widget pill(String label, String key, int count) {
      final isSelected = _selectedFilter == key;
      return GestureDetector(
        onTap: () => setState(() => _selectedFilter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _RefColors.pink.withValues(alpha: 0.16)
                : _RefColors.cardFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _RefColors.pink : _RefColors.cardBorder,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? _RefColors.pinkSoft
                      : Colors.white.withValues(alpha: 0.65),
                ),
              ),
              if (count > 0 && key != 'all') ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? _RefColors.pinkSoft
                        : theme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          pill('All', 'all', all.length),
          const SizedBox(width: 8),
          pill(
            'Unread',
            'unread',
            all.where((c) => c.unreadCount > 0).length,
          ),
          const SizedBox(width: 8),
          pill(
            'Online',
            'online',
            all.where((c) => c.isOnline).length,
          ),
          const SizedBox(width: 8),
          pill(
            'Verified',
            'verified',
            all.where((c) => c.isVerified).length,
          ),
        ],
      ),
    );
  }

  // ─── 6. Chat list card ────────────────────────────────────────────────────
  Widget _buildChatCard(
    BuildContext context,
    ChatConversationModel conv,
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    final hasUnread = conv.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IndividualChatScreen(conversation: conv),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? _RefColors.cardFill : theme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasUnread
                ? _RefColors.pink.withValues(alpha: 0.35)
                : _RefColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF2A2036),
                  backgroundImage: conv.avatarAsset != null
                      ? AssetImage(conv.avatarAsset!)
                      : null,
                  child: conv.avatarAsset == null
                      ? Text(
                          conv.name.substring(0, 1),
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: conv.isOnline
                          ? _RefColors.online
                          : const Color(0xFF8E8E93),
                      shape: BoxShape.circle,
                      border: Border.all(color: _RefColors.bg, width: 2),
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
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                conv.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: hasUnread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conv.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 15,
                                color: _RefColors.verifiedBlue,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conv.timestamp,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: hasUnread
                              ? _RefColors.pinkSoft
                              : theme.textMuted,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? Colors.white.withValues(alpha: 0.9)
                                : theme.textMuted,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          height: 20,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: _RefColors.pink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showChatCardMenu(conv),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatCardMenu(ChatConversationModel conv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1526),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.done_all, color: Colors.white),
                title: const Text(
                  'Mark as read',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  AppDataService.instance.markAsRead(conv.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.archive_outlined, color: Colors.white),
                title: const Text(
                  'Archive chat',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSnack('Chat archived');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: _RefColors.pink),
                title: const Text(
                  'Delete chat',
                  style: TextStyle(color: _RefColors.pink),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSnack('Delete is disabled for demo data');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Requests tab ─────────────────────────────────────────────────────────
  Widget _buildRequestsList(YoUnMeThemeExtension theme, bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final req = _requests[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? _RefColors.cardFill : theme.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _RefColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF2A2036),
                    backgroundImage: req.avatarAsset != null
                        ? AssetImage(req.avatarAsset!)
                        : null,
                    child: req.avatarAsset == null
                        ? Text(
                            req.name.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                req.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              req.time,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: theme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _showSnack('${req.name} accepted!'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: _RefColors.pillGradient,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showSnack('Request declined'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _RefColors.cardBorder,
                                    ),
                                  ),
                                  child: const Text(
                                    'Decline',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
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
        },
        childCount: _requests.length,
      ),
    );
  }

  Widget _buildEmptyState(YoUnMeThemeExtension theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _RefColors.cardFill,
                shape: BoxShape.circle,
                border: Border.all(color: _RefColors.cardBorder),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: theme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results matching "$_searchQuery"'
                  : 'You have no chats matching this filter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textSecondary),
            ),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'all') ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedFilter = 'all';
                  });
                },
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: _RefColors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Sync → invite modal ──────────────────────────────────────────────────
  void _showInviteToAppModal() {
    const inviteLink = 'https://younme.app/invite?code=YOUNME-ALEX-VIP';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1526),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: _RefColors.pillGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite to YoUnMe App',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Earn 50 YoUnMe Coins for each friend who joins',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9C92AB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _RefColors.cardFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _RefColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          inviteLink,
                          style: TextStyle(
                            color: _RefColors.pinkSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 18, color: Colors.white),
                        tooltip: 'Copy Link',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showSnack('Invite link copied to clipboard!');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: _RefColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share Link'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showSnack('Opening share options...');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _RefColors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('Invite'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showSnack('Sharing invite...');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Settings sheet ───────────────────────────────────────────────────────
  void _showChatSettingsSheet() {
    Widget option(String label, String key, IconData icon) {
      final selected = _selectedFilter == key;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: selected ? _RefColors.pink : Colors.white),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? _RefColors.pink : Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: _RefColors.pink)
            : const Icon(Icons.circle_outlined, color: Colors.white38),
        onTap: () {
          setState(() => _selectedFilter = key);
          Navigator.pop(context);
        },
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1526),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inbox Filter Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                option('Show all chats', 'all', Icons.forum_outlined),
                option(
                  'Show unread only',
                  'unread',
                  Icons.mark_chat_unread_outlined,
                ),
                option(
                  'Show online users only',
                  'online',
                  Icons.circle,
                ),
                option(
                  'Show verified only',
                  'verified',
                  Icons.verified_outlined,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
