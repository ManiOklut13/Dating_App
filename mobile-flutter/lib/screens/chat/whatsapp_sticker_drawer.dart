import 'package:flutter/material.dart';

/// WhatsApp Dark Mode Palette Constants
class WhatsAppColors {
  WhatsAppColors._();

  static const Color background = Color(0xFF0B141A);
  static const Color appHeader = Color(0xFF1F2C34);
  static const Color drawerBg = Color(0xFF121B22);
  static const Color inputBar = Color(0xFF1F2C34);
  static const Color inputPill = Color(0xFF2A3942);
  static const Color searchPill = Color(0xFF202C33);
  static const Color outgoingBubble = Color(0xFF005C4B);
  static const Color incomingBubble = Color(0xFF202C33);
  static const Color textPrimary = Color(0xFFE9EDEF);
  static const Color textMuted = Color(0xFF8696A0);
  static const Color accentGreen = Color(0xFF00A884);
  static const Color checkmarkBlue = Color(0xFF53BDEB);
  static const Color datePill = Color(0xFF182229);
  static const Color drawerTabActive = Color(0xFF00A884);
  static const Color drawerTabInactive = Color(0xFF8696A0);
  static const Color packIndicator = Color(0xFF00A884);
}

/// Sticker item definition
class StickerItem {
  final String id;
  final String emoji;
  final String label;
  final String packId;
  final String? assetPath;

  const StickerItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.packId,
    this.assetPath,
  });
}

/// WhatsApp-style Sticker, Emoji, and GIF Drawer for Dark Mode
class WhatsAppStickerDrawer extends StatefulWidget {
  final Function(StickerItem sticker) onStickerSelected;
  final Function(String emoji) onEmojiSelected;
  final Function(String gifUrl, String title) onGifSelected;
  final VoidCallback onBackspace;

  const WhatsAppStickerDrawer({
    super.key,
    required this.onStickerSelected,
    required this.onEmojiSelected,
    required this.onGifSelected,
    required this.onBackspace,
  });

  @override
  State<WhatsAppStickerDrawer> createState() => _WhatsAppStickerDrawerState();
}

class _WhatsAppStickerDrawerState extends State<WhatsAppStickerDrawer> {
  // Main tabs: 0: Emoji, 1: GIF, 2: Stickers (Defaulting to Stickers as per reference)
  int _activeMainTab = 2;

  // Selected sticker pack index
  int _selectedPackIndex = 0;

  // Selected emoji category index
  int _selectedEmojiCategory = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sticker Packs
  final List<Map<String, dynamic>> _stickerPacks = [
    {
      'id': 'love',
      'icon': '❤️',
      'title': 'Love & Romance',
      'items': [
        const StickerItem(id: 's_love_1', emoji: '❤️', label: 'Heart Love', packId: 'love'),
        const StickerItem(id: 's_love_2', emoji: '🥰', label: 'Love Blast', packId: 'love'),
        const StickerItem(id: 's_love_3', emoji: '😘', label: 'Flying Kiss', packId: 'love'),
        const StickerItem(id: 's_love_4', emoji: '🌹', label: 'Red Rose', packId: 'love'),
        const StickerItem(id: 's_love_5', emoji: '💍', label: 'Soulmate', packId: 'love'),
        const StickerItem(id: 's_love_6', emoji: '💌', label: 'Love Letter', packId: 'love'),
        const StickerItem(id: 's_love_7', emoji: '💘', label: 'Cupid Arrow', packId: 'love'),
        const StickerItem(id: 's_love_8', emoji: '💖', label: 'Sparkling Heart', packId: 'love'),
        const StickerItem(id: 's_love_9', emoji: '😍', label: 'Heart Eyes', packId: 'love'),
        const StickerItem(id: 's_love_10', emoji: '💐', label: 'Bouquet', packId: 'love'),
        const StickerItem(id: 's_love_11', emoji: '🍫', label: 'Chocolates', packId: 'love'),
        const StickerItem(id: 's_love_12', emoji: '👩‍❤️‍👨', label: 'Together', packId: 'love'),
      ],
    },
    {
      'id': 'dating',
      'icon': '☕',
      'title': 'Dating & Vibes',
      'items': [
        const StickerItem(id: 's_date_1', emoji: '☕', label: 'Coffee Date?', packId: 'dating'),
        const StickerItem(id: 's_date_2', emoji: '🍷', label: 'Wine & Dine', packId: 'dating'),
        const StickerItem(id: 's_date_3', emoji: '🍕', label: 'Pizza Night', packId: 'dating'),
        const StickerItem(id: 's_date_4', emoji: '🎬', label: 'Movie Date', packId: 'dating'),
        const StickerItem(id: 's_date_5', emoji: '✨', label: 'Vibe Check', packId: 'dating'),
        const StickerItem(id: 's_date_6', emoji: '🚗', label: 'Long Drive', packId: 'dating'),
        const StickerItem(id: 's_date_7', emoji: '🌅', label: 'Sunset Walk', packId: 'dating'),
        const StickerItem(id: 's_date_8', emoji: '🧁', label: 'Sweet Tooth', packId: 'dating'),
      ],
    },
    {
      'id': 'cute',
      'icon': '🐾',
      'title': 'Cute Animals',
      'items': [
        const StickerItem(id: 's_cute_1', emoji: '🐱', label: 'Cute Kitty', packId: 'cute'),
        const StickerItem(id: 's_cute_2', emoji: '🐼', label: 'Panda Hug', packId: 'cute'),
        const StickerItem(id: 's_cute_3', emoji: '🐶', label: 'Puppy Eyes', packId: 'cute'),
        const StickerItem(id: 's_cute_4', emoji: '🐰', label: 'Bunny Hop', packId: 'cute'),
        const StickerItem(id: 's_cute_5', emoji: '🐻', label: 'Teddy Hug', packId: 'cute'),
        const StickerItem(id: 's_cute_6', emoji: '🦊', label: 'Clever Fox', packId: 'cute'),
        const StickerItem(id: 's_cute_7', emoji: '🐥', label: 'Sweet Chick', packId: 'cute'),
        const StickerItem(id: 's_cute_8', emoji: '🐨', label: 'Lazy Koala', packId: 'cute'),
      ],
    },
    {
      'id': 'reactions',
      'icon': '😂',
      'title': 'Reactions',
      'items': [
        const StickerItem(id: 's_re_1', emoji: '😂', label: 'ROFL', packId: 'reactions'),
        const StickerItem(id: 's_re_2', emoji: '🔥', label: 'Too Hot', packId: 'reactions'),
        const StickerItem(id: 's_re_3', emoji: '🥳', label: 'Party Time', packId: 'reactions'),
        const StickerItem(id: 's_re_4', emoji: '🙈', label: 'Blushing', packId: 'reactions'),
        const StickerItem(id: 's_re_5', emoji: '💃', label: 'Dancing', packId: 'reactions'),
        const StickerItem(id: 's_re_6', emoji: '🥂', label: 'Cheers', packId: 'reactions'),
        const StickerItem(id: 's_re_7', emoji: '⚡', label: 'Shocked', packId: 'reactions'),
        const StickerItem(id: 's_re_8', emoji: '💯', label: 'Perfection', packId: 'reactions'),
      ],
    },
  ];

  // Emoji categories
  final List<Map<String, dynamic>> _emojiCategories = [
    {
      'icon': '😀',
      'title': 'Smileys',
      'emojis': [
        '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
        '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
        '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
        '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨',
      ],
    },
    {
      'icon': '❤️',
      'title': 'Love & Hearts',
      'emojis': [
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
        '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
        '💘', '💝', '💟', '💋', '💌', '💐', '🌹', '🥀',
      ],
    },
    {
      'icon': '👋',
      'title': 'People',
      'emojis': [
        '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏',
        '✌️', '🤞', '🫰', '🤟', '🤘', '🤙', '👈', '👉',
        '👆', '🖕', '👇', '☝️', '👍', '👎', '✊', '👊',
      ],
    },
    {
      'icon': '🍕',
      'title': 'Food',
      'emojis': [
        '☕', '🍵', '🧋', '🍺', '🍻', '🥂', '🍷', '🍸',
        '🍕', '🍔', '🍟', '🌭', '🥪', '🌮', '🍣', '🍱',
        '🧁', '🍰', '🎂', '🍩', '🍪', '🍫', '🍬', '🍭',
      ],
    },
    {
      'icon': '🎉',
      'title': 'Activities',
      'emojis': [
        '🎉', '🎊', '🎈', '🎁', '🎂', '🎃', '🎄', '🎆',
        '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏉', '🎱',
        '🎨', '🎬', '🎤', '🎧', '🎷', '🎸', '🎹', '🎺',
      ],
    },
  ];

  // Curated GIFs
  final List<Map<String, String>> _curatedGifs = [
    {'title': 'Heart Eyes Wave', 'url': 'https://media.giphy.com/media/l41lI4bYmcsPJX9Go/giphy.gif', 'preview': '😍 Wave'},
    {'title': 'Cute Wink', 'url': 'https://media.giphy.com/media/3oz8xAFtqoOUUrsh7W/giphy.gif', 'preview': '😉 Wink'},
    {'title': 'Coffee Toast', 'url': 'https://media.giphy.com/media/3oKIPnAiaMCws8nOsE/giphy.gif', 'preview': '☕ Cheers'},
    {'title': 'Blushing Smile', 'url': 'https://media.giphy.com/media/26AHONQ99Rn7jsMaQ/giphy.gif', 'preview': '🥰 Blush'},
    {'title': 'Dance Party', 'url': 'https://media.giphy.com/media/l3q2wJsC23ikJg9xe/giphy.gif', 'preview': '💃 Dance'},
    {'title': 'High Five', 'url': 'https://media.giphy.com/media/3oEjHV0z8S7WM4MwnK/giphy.gif', 'preview': '✋ High Five'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      decoration: const BoxDecoration(
        color: WhatsAppColors.drawerBg,
        border: Border(
          top: BorderSide(color: Color(0xFF202C33), width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: WhatsAppColors.searchPill,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: WhatsAppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: _activeMainTab == 0
                      ? 'Search emojis...'
                      : (_activeMainTab == 1
                          ? 'Search GIFs...'
                          : 'Search sticker packs...'),
                  hintStyle: const TextStyle(
                    color: WhatsAppColors.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: WhatsAppColors.textMuted,
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close,
                            color: WhatsAppColors.textMuted,
                            size: 16,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
              ),
            ),
          ),

          // ── Sub-Pack / Category Header (WhatsApp Style) ─────────
          if (_activeMainTab == 2) _buildStickerPackSelector(),
          if (_activeMainTab == 0) _buildEmojiCategorySelector(),

          // ── Content Area (Grid) ─────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _activeMainTab,
              children: [
                _buildEmojiGrid(),
                _buildGifGrid(),
                _buildStickersGrid(),
              ],
            ),
          ),

          // ── WhatsApp Bottom Navigation Bar ──────────────────────
          _buildBottomTabBar(),
        ],
      ),
    );
  }

  // ── Sticker Packs Top Row ───────────────────────────────────────
  Widget _buildStickerPackSelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E262C), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stickerPacks.length,
        itemBuilder: (context, index) {
          final pack = _stickerPacks[index];
          final isSelected = _selectedPackIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPackIndex = index;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? WhatsAppColors.packIndicator
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pack['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pack['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? WhatsAppColors.textPrimary
                            : WhatsAppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Emoji Categories Top Row ────────────────────────────────────
  Widget _buildEmojiCategorySelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E262C), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _emojiCategories.length,
        itemBuilder: (context, index) {
          final cat = _emojiCategories[index];
          final isSelected = _selectedEmojiCategory == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedEmojiCategory = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? WhatsAppColors.packIndicator
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  cat['icon'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? WhatsAppColors.textPrimary
                        : WhatsAppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stickers Grid (4 Columns, WhatsApp Style) ───────────────────
  Widget _buildStickersGrid() {
    final currentPack = _stickerPacks[_selectedPackIndex];
    final List<StickerItem> allItems = (currentPack['items'] as List<StickerItem>);

    final items = _searchQuery.isEmpty
        ? allItems
        : allItems
            .where((s) => s.label.toLowerCase().contains(_searchQuery))
            .toList();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No stickers found',
          style: TextStyle(color: WhatsAppColors.textMuted, fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4-column WhatsApp sticker layout
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final sticker = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.onStickerSelected(sticker),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2A3942).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sticker.emoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      sticker.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: WhatsAppColors.textMuted,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Emoji Grid (8 Columns, WhatsApp Style) ──────────────────────
  Widget _buildEmojiGrid() {
    final category = _emojiCategories[_selectedEmojiCategory];
    final List<String> allEmojis = (category['emojis'] as List<String>);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: allEmojis.length,
      itemBuilder: (context, index) {
        final emoji = allEmojis[index];

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onEmojiSelected(emoji),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }

  // ── GIF Grid (2 Columns, WhatsApp Style) ────────────────────────
  Widget _buildGifGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _curatedGifs.length,
      itemBuilder: (context, index) {
        final gif = _curatedGifs[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => widget.onGifSelected(gif['url']!, gif['title']!),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2A3942),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.gif_box_rounded,
                      color: WhatsAppColors.accentGreen,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gif['preview']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: WhatsAppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Bar with Tab Buttons & Backspace ─────────────────────
  Widget _buildBottomTabBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF162026),
        border: Border(
          top: BorderSide(color: Color(0xFF1F2C34), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty spacer for balance
          const SizedBox(width: 32),

          // Center Tabs: Emoji, GIF, Stickers (WhatsApp Style)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji Tab
              _buildMainTabButton(
                index: 0,
                icon: Icons.sentiment_satisfied_alt_outlined,
                activeIcon: Icons.sentiment_satisfied_alt,
                label: 'Emoji',
              ),
              const SizedBox(width: 24),

              // GIF Tab
              _buildMainTabButton(
                index: 1,
                icon: Icons.gif_box_outlined,
                activeIcon: Icons.gif_box,
                label: 'GIF',
              ),
              const SizedBox(width: 24),

              // Stickers Tab
              _buildMainTabButton(
                index: 2,
                icon: Icons.sticky_note_2_outlined,
                activeIcon: Icons.sticky_note_2,
                label: 'Stickers',
              ),
            ],
          ),

          // Right Backspace Icon
          IconButton(
            icon: const Icon(
              Icons.backspace_outlined,
              size: 20,
              color: WhatsAppColors.textMuted,
            ),
            tooltip: 'Backspace',
            onPressed: widget.onBackspace,
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabButton({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _activeMainTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMainTab = index;
          _searchQuery = '';
          _searchController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 24,
          color: isActive
              ? WhatsAppColors.drawerTabActive
              : WhatsAppColors.drawerTabInactive,
        ),
      ),
    );
  }
}
