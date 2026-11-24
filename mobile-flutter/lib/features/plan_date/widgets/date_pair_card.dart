import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/profiles_data.dart';
import '../../../models/chat_profile_models.dart';
import '../../../services/app_data_service.dart';
import '../../../services/chat_list_provider.dart';
import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Shows the user/partner pair, animated partner swap, and partner search.
class DatePairCard extends ConsumerStatefulWidget {
  const DatePairCard({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<DatePairCard> createState() => _DatePairCardState();
}

class _DatePairCardState extends ConsumerState<DatePairCard> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(planDateProvider(widget.chatId));
    final chats = ref.watch(chatConversationsProvider);
    final query = _searchController.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? chats
        : chats
            .where((chat) => chat.name.toLowerCase().contains(query))
            .toList();
    final userPhoto = AppDataService.instance.userProfile.photos.first;
    final partner = draft.partner;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'YOUR DATE PAIR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: PDColors.chooserPink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 172,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _YouCard(userPhoto: userPhoto),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PartnerCard(
                        partner: partner,
                        onSwap: () => _showPartnerSearch(),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 54,
                  child: Center(child: _HeartBadge()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (_) => setState(() => _showResults = true),
                onTap: () => setState(() => _showResults = true),
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 13.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for partner...',
                  hintStyle: const TextStyle(
                    color: PDColors.textMuted,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: PDColors.textMuted,
                    size: 19,
                  ),
                  filled: true,
                  fillColor: PDColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(color: PDColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(color: PDColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(
                      color: PDColors.gradientPink,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (_showResults && _searchFocus.hasFocus)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 54,
                  child: Material(
                    elevation: 12,
                    color: PDColors.controlFill,
                    borderRadius: BorderRadius.circular(PDRadius.control),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 210),
                      child: matches.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No matching chats',
                                style: PDTextStyles.muted,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final chat = matches[index];
                                return ListTile(
                                  minLeadingWidth: 32,
                                  leading: ClipOval(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: chat.avatarAsset != null
                                          ? SafeProfileImage(
                                              imageUrl: chat.avatarAsset!,
                                              width: 32,
                                              height: 32,
                                            )
                                          : Container(
                                              color: PDColors.cardBorder,
                                              alignment: Alignment.center,
                                              child: Text(
                                                chat.name.substring(0, 1),
                                                style: const TextStyle(
                                                  color: PDColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    chat.name,
                                    style: const TextStyle(
                                      color: PDColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () => _selectPartner(chat),
                                );
                              },
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPartnerSearch() {
    _searchFocus.requestFocus();
    setState(() => _showResults = true);
  }

  void _selectPartner(ChatConversationModel chat) {
    ref.read(planDateProvider(widget.chatId).notifier).setPartner(chat);
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _showResults = false);
  }

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: PDColors.card,
    borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
    border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
  );
}

class _YouCard extends StatelessWidget {
  const _YouCard({required this.userPhoto});

  final String userPhoto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D3BFF), Color(0xFF2A1454)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Positioned(
            left: 10,
            top: 10,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: PDColors.cardBorder,
              child: Icon(
                Icons.person,
                size: 17,
                color: PDColors.textPrimary,
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: SafeProfileImage(
                  imageUrl: userPhoto,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              'You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner, required this.onSwap});

  final ChatConversationModel? partner;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final name = partner?.name ?? 'Choose a partner';
    final avatar = partner?.avatarAsset;
    final isOnline = partner?.isOnline ?? false;

    return GestureDetector(
      onTap: onSwap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOut,
              child: avatar != null
                  ? SafeProfileImage(
                      key: ValueKey<String>(avatar + name),
                      imageUrl: avatar,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      key: ValueKey<String>('fallback-$name'),
                      color: PDColors.controlFill,
                      alignment: Alignment.center,
                      child: Text(
                        name.substring(0, 1),
                        style: const TextStyle(
                          color: PDColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xCC08040E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? PDColors.online : PDColors.offline,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 8,
              bottom: 10,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartBadge extends StatefulWidget {
  const _HeartBadge();

  @override
  State<_HeartBadge> createState() => _HeartBadgeState();
}

class _HeartBadgeState extends State<_HeartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1.06).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: PDGradients.selection,
            boxShadow: [
              BoxShadow(
                color: Color(0x66E91E8C),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
