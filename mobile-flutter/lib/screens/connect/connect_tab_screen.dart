import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class _MatchCounterpart {
  final String userId;
  final String nickname;
  final String avatarAsset;
  final String city;
  final bool isVerified;

  const _MatchCounterpart({
    required this.userId,
    required this.nickname,
    required this.avatarAsset,
    required this.city,
    required this.isVerified,
  });
}

class _Match {
  final String id;
  final _MatchCounterpart counterpart;
  final int messagePairCount;
  final String? lastMessage;

  const _Match({
    required this.id,
    required this.counterpart,
    required this.messagePairCount,
    this.lastMessage,
  });
}

class ConnectTabScreen extends StatefulWidget {
  final void Function(String convId)? onOpenChat;
  final void Function(String calleeId, String name, String avatar)? onOpenCall;
  final VoidCallback? onOpenStore;

  const ConnectTabScreen({
    super.key,
    this.onOpenChat,
    this.onOpenCall,
    this.onOpenStore,
  });

  @override
  State<ConnectTabScreen> createState() => _ConnectTabScreenState();
}

class _ConnectTabScreenState extends State<ConnectTabScreen> {
  bool _loading = true;
  late List<_Match> _matches;

  @override
  void initState() {
    super.initState();
    _matches = [
      _Match(
        id: 'conv-ananya-1',
        counterpart: const _MatchCounterpart(
          userId: 'ananya',
          nickname: 'Ananya Sharma',
          avatarAsset: 'assets/images/ananya.jpg',
          city: 'Bandra, Mumbai',
          isVerified: true,
        ),
        messagePairCount: 12,
        lastMessage: 'Subko Bandra at 6:30 PM sounds wonderful!',
      ),
      _Match(
        id: 'conv-riya-2',
        counterpart: const _MatchCounterpart(
          userId: 'riya',
          nickname: 'Riya Sen',
          avatarAsset: 'assets/images/riya.jpg',
          city: 'Hauz Khas, Delhi',
          isVerified: true,
        ),
        messagePairCount: 8,
        lastMessage: 'Did you hear the new Fred again.. track?',
      ),
      _Match(
        id: 'conv-rohit-3',
        counterpart: const _MatchCounterpart(
          userId: 'rohit',
          nickname: 'Rohit Mehta',
          avatarAsset: 'assets/images/rohit.jpg',
          city: 'Indiranagar, Bengaluru',
          isVerified: true,
        ),
        messagePairCount: 5,
        lastMessage: 'Sounds like a great plan.',
      ),
    ];
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.flamePink))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text('Connect & Match Hub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Reciprocal connections, Vibe radar, and incoming likes', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                    const SizedBox(height: 24),

                    // Section 1: Mutual Matches
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 18, color: AppColors.flamePink),
                            const SizedBox(width: 6),
                            Text('Mutual Matches (${_matches.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                          ],
                        ),
                        Text('Ready to chat & call', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _matches.length,
                      itemBuilder: (context, i) {
                        final m = _matches[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.flamePink.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.flamePink, width: 2),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.asset(m.counterpart.avatarAsset, fit: BoxFit.cover),
                                      ),
                                      if (m.counterpart.isVerified)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlueAccent),
                                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.counterpart.nickname, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(m.counterpart.city, style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent)),
                                        Text('${m.messagePairCount} messages exchanged', style: TextStyle(fontSize: 10, color: theme.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (m.lastMessage != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(color: theme.searchFill, borderRadius: BorderRadius.circular(8)),
                                  child: Text('💬 "${m.lastMessage}"', style: TextStyle(fontSize: 11, color: theme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => widget.onOpenChat?.call(m.id),
                                      icon: const Icon(Icons.chat_bubble, size: 14),
                                      label: const Text('Chat', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.flamePink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 6)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () => widget.onOpenCall?.call(m.counterpart.userId, m.counterpart.nickname, m.counterpart.avatarAsset),
                                    icon: const Icon(Icons.phone, size: 16, color: AppColors.cyanAccent),
                                    style: IconButton.styleFrom(backgroundColor: theme.searchFill),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Likes You blurred stack
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 18, color: AppColors.goldAccent),
                            const SizedBox(width: 6),
                            Text("'Likes You' Blurred Stack", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                          ],
                        ),
                        Text('Secret Admirers', style: TextStyle(fontSize: 12, color: AppColors.goldAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 64,
                            child: Stack(
                              children: [
                                for (int i = 0; i < 3; i++)
                                  Positioned(
                                    left: i * 20.0,
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: theme.bgCard, width: 3),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(
                                        ['assets/images/ananya.jpg', 'assets/images/riya.jpg', 'assets/images/rohit.jpg'][i],
                                        fit: BoxFit.cover,
                                        color: Colors.grey,
                                        colorBlendMode: BlendMode.saturation,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('3 People Liked Your Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                                const SizedBox(height: 4),
                                Text('Reveal who liked you and match instantly.', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: widget.onOpenStore,
                            icon: const Icon(Icons.lock, size: 15),
                            label: const Text('Unlock (50 Coins)', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldAccent, foregroundColor: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Vibe compatibility
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 18, color: AppColors.cyanAccent),
                        const SizedBox(width: 6),
                        Text('Vibe Compatibility Algorithm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: theme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.borderSubtle)),
                      child: Column(
                        children: [
                          _vibeRow('🎵 Music & Indie Vinyl Taste', 0.95, AppColors.cyanAccent, theme),
                          const SizedBox(height: 10),
                          _vibeRow('☕ Cafe Culture & City Vibes', 0.92, AppColors.flamePink, theme),
                          const SizedBox(height: 10),
                          _vibeRow('💬 Wit & Conversation Depth', 0.88, AppColors.goldAccent, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _vibeRow(String label, double value, Color color, YoUnMeThemeExtension theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: theme.textSecondary)),
            Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: theme.searchFill,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
