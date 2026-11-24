import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/chat_list_provider.dart';
import '../../services/theme_service.dart';
import '../calls/call_history_sheet.dart';
import 'date_plan_models.dart';
import 'individual_chat_screen.dart';
import 'plan_date_chooser_sheet.dart';
import 'plan_date_provider.dart';
import 'plan_date_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  _C._();

  static const Color bg           = Color(0xFF0C080E);
  static const Color card         = Color(0xFF14101A);
  static const Color field        = Color(0xFF14101A);
  static const Color rowDivider   = Color(0xFF1F1825);
  static const Color cardBorder   = Color(0x22FFFFFF);
  static const Color pink         = Color(0xFFFF2D55);
  static const Color pinkSoft     = Color(0xFFFF6B8B);
  static const Color verifiedBlue = Color(0xFF4DA3FF);
  static const Color online       = Color(0xFF22C55E);
  static const Color muted        = Color(0xFF6E6480);

  static const LinearGradient pill = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFE0264F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft magenta/violet wash used behind the chat list.
  static const LinearGradient pageGlow = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0x26FF4D7E), Color(0x000C080E), Color(0x1FA855F7)],
    stops: [0, 0.45, 1],
  );

  static const LinearGradient ring = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient matchPill = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient savePill = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFE040A0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Request model
// ─────────────────────────────────────────────────────────────────────────────
class _Req {
  final String name;
  final String? asset;
  final String matchPct;
  final String location;
  final String time;
  final String quote;
  final bool isVerified;
  final String subTab; // received | sent | date

  const _Req({
    required this.name,
    this.asset,
    required this.matchPct,
    required this.location,
    required this.time,
    required this.quote,
    this.isVerified = true,
    this.subTab = 'received',
  });
}

const _kRequests = <_Req>[
  _Req(name: 'Priya Malhotra', asset: 'assets/images/ananya.jpg',
      matchPct: '97%', location: 'Juhu, Mumbai', time: '10m ago',
      quote: '"Hey! Loved your taste in indie records. Would love to grab a Subko coffee sometime! 🎵 ✨"'),
  _Req(name: 'Alia Varma', asset: 'assets/images/riya.jpg',
      matchPct: '94%', location: 'Koramangala, Bengaluru', time: '1h ago',
      quote: '"Hey! That photo from your Himalayan trek looked magical. Did you ride there on an Enfield? 🏍"'),
  _Req(name: 'Divya Sen', asset: 'assets/images/riya.jpg',
      matchPct: '91%', location: 'Greater Kailash, Delhi', time: '3h ago',
      quote: '"Subko Bandra is literally my second home whenever I am in Mumbai! We should definitely connect :)"'),
  _Req(name: 'Ishaan Gujral', asset: 'assets/images/rohit.jpg',
      matchPct: '96%', location: 'Versova, Mumbai', time: '5h ago',
      quote: '"Hey! High vibe score match on world cinema & literature. Are you attending the upcoming film fest?"'),
  _Req(name: 'Kabir Singh', asset: 'assets/images/rohit.jpg',
      matchPct: '88%', location: 'Powai, Mumbai', time: '1d ago',
      quote: '"Your startup post was insightful! Would love to connect."',
      subTab: 'sent', isVerified: false),
  _Req(name: 'Sana Iyer', asset: 'assets/images/ananya.jpg',
      matchPct: '85%', location: 'Koregaon Park, Pune', time: '2d ago',
      quote: '"Loved your film photography. Which camera do you use?"',
      subTab: 'sent'),
  _Req(name: 'Riya Chopra', asset: 'assets/images/riya.jpg',
      matchPct: '90%', location: 'Bandra, Mumbai', time: '3d ago',
      quote: '"Your vinyl record collection is amazing!"',
      subTab: 'sent'),
];

// ─────────────────────────────────────────────────────────────────────────────
// ChatTabScreen
// ─────────────────────────────────────────────────────────────────────────────
class ChatTabScreen extends ConsumerStatefulWidget {
  const ChatTabScreen({super.key});

  @override
  ConsumerState<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends ConsumerState<ChatTabScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchQuery = '';
  String _msgFilter   = 'all';      // all | unread | online | verified
  String _reqFilter   = 'received'; // received | sent | date
  String _activeTab   = 'messages'; // messages | requests

  late List<_Req> _mutableReqs;

  @override
  void initState() {
    super.initState();
    _mutableReqs = List<_Req>.from(_kRequests);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
      backgroundColor: const Color(0xFF231A2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  List<ChatConversationModel> get _allConvs =>
      ref.read(chatConversationsProvider);

  int get _totalUnread => _allConvs.fold(0, (s, c) => s + c.unreadCount);

  List<_Req> get _receivedReqs =>
      _mutableReqs.where((r) => r.subTab == 'received').toList();

  List<_Req> _sentReqs(List<_Req> dateReqs) => [
        ..._mutableReqs.where((r) => r.subTab == 'sent'),
        ...dateReqs,
      ];

  List<_Req> _dateInviteReqs(List<DateInvite> invites) => invites.map((invite) {
        return _Req(
          name: invite.partner.name,
          asset: invite.partner.avatarAsset,
          matchPct: '✓',
          location: '${invite.type.label} · ${invite.modeLabel}',
          time: DateFormat('d MMM, h:mm a').format(invite.dateTime),
          quote: 'Date invite sent · ${invite.durationMinutes} min',
          subTab: 'date',
          isVerified: invite.partner.isVerified,
        );
      }).toList();

  List<_Req> _visibleReqs(List<_Req> dateReqs) {
    switch (_reqFilter) {
      case 'sent':  return _sentReqs(dateReqs);
      case 'date':  return dateReqs;
      default:      return _receivedReqs;
    }
  }

  List<ChatConversationModel> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    return _allConvs.where((c) {
      final ok = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
      if (!ok) return false;
      switch (_msgFilter) {
        case 'unread':   return c.unreadCount > 0;
        case 'online':   return c.isOnline;
        case 'verified': return c.isVerified;
        default:         return true;
      }
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ── Chat navigation ────────────────────────────────────────────────────────
  // The destination is always dark. Use an explicit opaque slide transition so
  // the platform page transition never fades/snapshots through a light route
  // surface or window background, which caused the light flash on open.
  Route<void> _chatRoute(ChatConversationModel conv) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: '/chat/${conv.id}'),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) =>
          IndividualChatScreen(conversation: conv),
      transitionsBuilder: (_, animation, __, child) {
        final position = animation.drive(
          Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
        );
        return SlideTransition(position: position, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme  = context.appTheme;
    final isDark = context.isDarkMode;
    final invites = ref.watch(dateInvitesProvider);
    final dateReqs = _dateInviteReqs(invites);
    final watchedConvs = ref.watch(chatConversationsProvider);

    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final convs    = watchedConvs;
        final filtered = _filtered;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? _C.bg : theme.bgSurface,
            gradient: isDark ? _C.pageGlow : null,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, convs),
                      const SizedBox(height: 16),
                      _buildTabSwitcher(convs),
                      const SizedBox(height: 14),
                      if (_activeTab == 'messages') ...[
                        _buildSearchBar(theme, isDark),
                        const SizedBox(height: 14),
                        _buildActiveNow(convs),
                        const SizedBox(height: 14),
                        _buildMsgFilterPills(convs),
                        const SizedBox(height: 10),
                      ] else ...[
                        _buildReqFilterPills(dateReqs),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),

              if (_activeTab == 'requests')
                _buildRequestsSliver(theme, isDark, dateReqs)
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(theme),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildChatRow(ctx, filtered[i], theme, isDark),
                    ),
                    childCount: filtered.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        );
      },
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(YoUnMeThemeExtension theme, List<ChatConversationModel> convs) {
    final subtitle = _activeTab == 'messages'
        ? '$_totalUnread unread · ${convs.length} conversations'
        : '${_receivedReqs.length} people want to connect with you';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        _iconBtn(Icons.phone_outlined, _showCallHistorySheet),
        const SizedBox(width: 8),
        _iconBtn(Icons.calendar_today_outlined, _showPlanADateSheet),
        const SizedBox(width: 8),
        _iconBtn(Icons.settings_outlined, _showChatPrivacySettings),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: _C.card, shape: BoxShape.circle,
        border: Border.all(color: _C.cardBorder),
      ),
      child: Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.85)),
    ),
  );

  // ─── Tab switcher ─────────────────────────────────────────────────────────
  Widget _buildTabSwitcher(List<ChatConversationModel> convs) {
    Widget tab(String key, String label, int badge) {
      final sel = _activeTab == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _activeTab = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: sel ? _C.pill : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: _C.pink.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withValues(alpha: 0.28) : _C.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700)),
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
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Row(children: [
        tab('messages', 'Messages', convs.length),
        tab('requests', 'Requests', _receivedReqs.length),
      ]),
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar(YoUnMeThemeExtension theme, bool isDark) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: isDark ? _C.field : theme.searchFill,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.cardBorder),
    ),
    child: Row(
      children: [
        const Icon(Icons.search, size: 20, color: Color(0xFF6E6480)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(color: theme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Search chats by name',
              hintStyle: TextStyle(color: Color(0xFF6E6480), fontSize: 14),
              border: InputBorder.none, isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
            child: const Icon(Icons.close, size: 18, color: Color(0xFF6E6480)),
          ),
      ],
    ),
  );

  // ─── Active Now ───────────────────────────────────────────────────────────
  Widget _buildActiveNow(List<ChatConversationModel> convs) {
    final online = convs.where((c) => c.isOnline).take(6).toList();
    if (online.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Active now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            GestureDetector(
              onTap: () => _snack('See all active users'),
              child: const Text('See all',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.pink)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: online.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (ctx, i) => _buildActiveAvatar(ctx, online[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAvatar(BuildContext ctx, ChatConversationModel conv) {
    final firstName = conv.name.split(' ').first;
    return GestureDetector(
      onTap: () => Navigator.of(ctx).push(_chatRoute(conv)),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54, height: 54,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(gradient: _C.ring, shape: BoxShape.circle),
              child: ClipOval(
                child: conv.avatarAsset != null
                    ? Image.asset(conv.avatarAsset!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF2A2036),
                        alignment: Alignment.center,
                        child: Text(conv.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ─── Message filter pills ─────────────────────────────────────────────────
  Widget _buildMsgFilterPills(List<ChatConversationModel> convs) {
    Widget pill(String label, String key) {
      final sel = _msgFilter == key;
      return GestureDetector(
        onTap: () => setState(() => _msgFilter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _C.pink.withValues(alpha: 0.10) : _C.field,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? _C.pink : _C.cardBorder),
          ),
          child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sel ? _C.pinkSoft : const Color(0xFF9CA3AF),
            )),
        ),
      );
    }

    final unreadCnt = convs.fold(0, (sum, c) => sum + c.unreadCount);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        pill('All', 'all'), const SizedBox(width: 8),
        pill('Unread · $unreadCnt', 'unread'), const SizedBox(width: 8),
        pill('Online', 'online'), const SizedBox(width: 8),
        pill('Verified', 'verified'),
      ]),
    );
  }

  // ─── Chat list row ────────────────────────────────────────────────────────
  Widget _buildChatRow(BuildContext ctx, ChatConversationModel conv,
      YoUnMeThemeExtension theme, bool isDark) {
    final hasUnread = conv.unreadCount > 0;
    final last = conv.messages.isNotEmpty ? conv.messages.last : null;
    final preview = last != null && last.isMe
        ? 'You: ${conv.lastMessage}'
        : conv.lastMessage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(ctx).push(_chatRoute(conv)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: conv.isPinned && isDark
                ? const LinearGradient(
                    colors: [Color(0x14FF4D7E), Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            border: Border(
              bottom: BorderSide(
                color: isDark ? _C.rowDivider : theme.borderSubtle,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: EdgeInsets.all(conv.isPinned ? 2 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: conv.isPinned ? _C.ring : null,
                    ),
                    child: ClipOval(
                      child: conv.avatarAsset != null
                          ? Image.asset(conv.avatarAsset!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF2A2036),
                              alignment: Alignment.center,
                              child: Text(conv.name.substring(0, 1),
                                  style: TextStyle(
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                    ),
                  ),
                  if (conv.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _C.online,
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.bg, width: 2),
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
                          child: Text(conv.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            )),
                        ),
                        if (conv.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified, size: 14, color: _C.verifiedBlue),
                        ],
                        if (conv.isPinned) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.push_pin, size: 12, color: _C.pink),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (conv.isVoiceNote == true)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.mic, size: 13, color: Color(0xFF9CA3AF)),
                          ),
                        Expanded(
                          child: Text(preview, maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: hasUnread ? Colors.white : const Color(0xFF9CA3AF),
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                            )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(conv.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUnread ? _C.pinkSoft : _C.muted,
                    )),
                  const SizedBox(height: 6),
                  if (hasUnread)
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        gradient: _C.pill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${conv.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Requests section ─────────────────────────────────────────────────────
  Widget _buildReqFilterPills(List<_Req> dateReqs) {
    Widget pill(String label, String key) {
      final sel = _reqFilter == key;
      return GestureDetector(
        onTap: () => setState(() => _reqFilter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _C.pink.withValues(alpha: 0.18) : _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? _C.pink : _C.cardBorder, width: sel ? 1.5 : 1),
          ),
          child: Text(label,
            style: TextStyle(
              fontSize: 12.5, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? _C.pinkSoft : Colors.white.withValues(alpha: 0.65))),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        pill('Received · ${_receivedReqs.length}', 'received'), const SizedBox(width: 8),
        pill('Sent · ${_sentReqs(dateReqs).length}', 'sent'), const SizedBox(width: 8),
        pill('Date invites · ${dateReqs.length}', 'date'),
      ]),
    );
  }

  SliverList _buildRequestsSliver(
    YoUnMeThemeExtension theme,
    bool isDark,
    List<_Req> dateReqs,
  ) {
    final list = _visibleReqs(dateReqs);
    if (list.isEmpty) {
      return SliverList(delegate: SliverChildListDelegate([
        Padding(padding: const EdgeInsets.all(40),
          child: Center(child: Text(
            _reqFilter == 'date' ? 'No date invites yet' : 'No requests in this category',
            style: const TextStyle(color: Color(0xFF6E6480), fontSize: 14)))),
      ]));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: _buildRequestCard(list[i], theme, isDark)),
        childCount: list.length,
      ),
    );
  }

  Widget _buildRequestCard(_Req req, YoUnMeThemeExtension theme, bool isDark) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF18141F) : theme.bgCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.cardBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 26, backgroundColor: const Color(0xFF2A2036),
          backgroundImage: req.asset != null ? AssetImage(req.asset!) : null,
          child: req.asset == null
              ? Text(req.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(req.name, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            if (req.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 14, color: _C.verifiedBlue),
            ],
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(gradient: _C.matchPill, borderRadius: BorderRadius.circular(8)),
              child: Text('${req.matchPct} match',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6E6480)),
            const SizedBox(width: 2),
            Text(req.location, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E88A0))),
          ]),
          const SizedBox(height: 2),
          Text(req.time, style: const TextStyle(fontSize: 11, color: Color(0xFF6E6480))),
        ])),
      ]),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF211B2D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Text(req.quote,
          style: const TextStyle(fontSize: 13.5, color: Colors.white, height: 1.5)),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _mutableReqs.removeWhere((r) => r.name == req.name));
              _snack('Request declined');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.cardBorder),
              ),
              child: const Text('✕  Decline',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _mutableReqs.removeWhere((r) => r.name == req.name));
              _snack('Connected with ${req.name}! 🎉');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: _C.pill, borderRadius: BorderRadius.circular(14)),
              child: const Text('♥  Accept',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
            ),
          ),
        ),
      ]),
    ]),
  );

  // ─── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(YoUnMeThemeExtension theme) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _C.card, shape: BoxShape.circle, border: Border.all(color: _C.cardBorder)),
          child: Icon(Icons.chat_bubble_outline, size: 40, color: theme.textMuted),
        ),
        const SizedBox(height: 16),
        Text('No conversations found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
        const SizedBox(height: 6),
        Text(
          _searchQuery.isNotEmpty ? 'No results matching "$_searchQuery"' : 'No chats match this filter',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: theme.textSecondary)),
        if (_searchQuery.isNotEmpty || _msgFilter != 'all') ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); _msgFilter = 'all'; }),
            child: const Text('Reset Filters', style: TextStyle(color: _C.pink, fontWeight: FontWeight.bold)),
          ),
        ],
      ]),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  MODAL 1 — Audio Call History
  // ══════════════════════════════════════════════════════════════════════════
  void _showCallHistorySheet() {
    showCallHistorySheet(context);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MODAL 2 — Plan a Date
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _showPlanADateSheet() async {
    final picked = await showPlanDateChooser(context);
    if (picked == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanDateScreen(partner: picked),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MODAL 3 — Chat & Privacy Settings
  // ══════════════════════════════════════════════════════════════════════════
  void _showChatPrivacySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _ChatPrivacySheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat & Privacy Settings bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ChatPrivacySheet extends StatefulWidget {
  const _ChatPrivacySheet();

  @override
  State<_ChatPrivacySheet> createState() => _ChatPrivacySheetState();
}

class _ChatPrivacySheetState extends State<_ChatPrivacySheet> {
  String _whoCanMsg       = 'matches'; // everyone | matches | nobody
  bool _showOnline        = true;
  bool _readReceipts      = true;
  bool _dmAlerts          = true;
  bool _callAlerts        = true;
  bool _isDark            = true;

  Widget _sectionHeader(IconData icon, Color iconColor, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: iconColor),
      const SizedBox(width: 8),
      Text(label,
        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1624),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x14FFFFFF)),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Color(0xFF8E88A0), fontSize: 11.5)),
      ])),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: value ? _C.pink : const Color(0xFF2A2036),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: value ? _C.pink : const Color(0x44FFFFFF)),
          ),
          child: value ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.85,
    maxChildSize: 0.95,
    minChildSize: 0.5,
    builder: (ctx, scroll) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13101A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(width: 36, height: 4,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.pink.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.shield_outlined, color: _C.pink, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Chat & Privacy Settings',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              Text('Preferences, Guard filters & blocked accounts',
                style: TextStyle(color: Color(0xFF8E88A0), fontSize: 11.5)),
            ])),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: const Icon(Icons.close, color: Colors.white, size: 22)),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // ── Who Can Message Me ─────────────────────────────────────
              const Text('Who Can Message Me',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1624),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: Row(children: [
                  _whoBtn('Everyone', 'everyone'),
                  _whoBtn('Matches Only', 'matches'),
                  _whoBtn('Nobody', 'nobody'),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Presence & Activity ────────────────────────────────────
              _sectionHeader(Icons.visibility_outlined, Colors.tealAccent, 'Presence & Activity'),
              _toggleRow('Show Online Status', 'Allow matches to see when you are active',
                  _showOnline, (v) => setState(() => _showOnline = v)),
              _toggleRow('Read Receipts', 'Show blue checkmarks when messages are read',
                  _readReceipts, (v) => setState(() => _readReceipts = v)),
              const SizedBox(height: 8),

              // ── Notifications & Alerts ─────────────────────────────────
              _sectionHeader(Icons.notifications_outlined, Colors.amber, 'Notifications & Alerts'),
              _toggleRow('Direct Message Alerts', 'Push notifications for new chat bubbles',
                  _dmAlerts, (v) => setState(() => _dmAlerts = v)),
              _toggleRow('Live Call Alerts', 'Ringtone for incoming audio/video calls',
                  _callAlerts, (v) => setState(() => _callAlerts = v)),
              const SizedBox(height: 8),

              // ── Theme Preference ───────────────────────────────────────
              _sectionHeader(Icons.dark_mode_outlined, Colors.purpleAccent, 'Theme Preference'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1624),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cyber Luxe Dark Theme',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('Aesthetic visual mode across chat screens',
                      style: TextStyle(color: Color(0xFF8E88A0), fontSize: 11.5)),
                  ])),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _isDark = !_isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2036),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Text(_isDark ? 'Switch to\nLight' : 'Switch to\nDark',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),

              // ── Blocked Users ──────────────────────────────────────────
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1624),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: Row(children: [
                  Icon(Icons.person_off_outlined, color: Colors.orange.shade300, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Blocked Users (2)',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4)),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Save & Close button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _C.savePill,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: _C.pink.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: const Text('Save & Close',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _whoBtn(String label, String key) {
    final sel = _whoCanMsg == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _whoCanMsg = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: sel ? _C.pill : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? Colors.white : Colors.white.withValues(alpha: 0.5),
            )),
        ),
      ),
    );
  }
}
