import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  _P._();

  static const Color panel = Color(0xFF0B0810);
  static const Color pill = Color(0xFF171320);
  static const Color border = Color(0x1FFFFFFF);
  static const Color divider = Color(0xFF1F1825);
  static const Color muted = Color(0xFF6E6480);

  static const LinearGradient pillGradient = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFC026D3)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient underline = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFA855F7), Color(0xFF00E5FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class _EmojiCategory {
  final String icon;
  final List<String> emojis;

  const _EmojiCategory({required this.icon, required this.emojis});
}

const _categories = <_EmojiCategory>[
  _EmojiCategory(icon: '😀', emojis: [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
    '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
    '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
    '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
    '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
    '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
    '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥',
    '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧',
    '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐',
    '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑',
    '🤠', '😈', '👿', '🤡', '💩', '👻', '💀', '👽',
    '🤖', '🎃', '😺', '😸', '😹', '😻', '😼', '🙀',
  ]),
  _EmojiCategory(icon: '❤️', emojis: [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
    '💘', '💝', '💟', '♥️', '💌', '💋', '😍', '🥰',
    '😘', '💐', '🌹', '🌷', '🌺', '🌸', '💮', '🏵️',
    '🍫', '🎁', '🥂', '🍷', '🕯️', '🎶', '🌙', '✨',
  ]),
  _EmojiCategory(icon: '👍', emojis: [
    '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏',
    '✌️', '🤞', '🤟', '🤘', '🤙', '👈', '👉', '👆',
    '👇', '☝️', '👍', '👎', '✊', '👊', '🤛', '🤜',
    '👏', '🙌', '👐', '🤲', '🤝', '🙏', '💪', '🦾',
    '🤷', '🤦', '🙆', '🙅', '🙋', '🧏', '💃', '🕺',
  ]),
  _EmojiCategory(icon: '🐱', emojis: [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
    '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈',
    '🙉', '🙊', '🐔', '🐧', '🐦', '🐤', '🦆', '🦅',
    '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🦋',
    '🐌', '🐞', '🐢', '🐍', '🐙', '🦑', '🦀', '🐠',
    '🐬', '🐳', '🦈', '🐊', '🐘', '🦒', '🐪', '🦌',
    '🐕', '🐈', '🕊️', '🐇', '🦦', '🐿️',
  ]),
  _EmojiCategory(icon: '🍔', emojis: [
    '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇',
    '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥',
    '🥝', '🍅', '🥑', '🥦', '🥕', '🌽', '🌶️', '🥒',
    '🥬', '🍄', '🥜', '🍞', '🥐', '🥖', '🥨', '🥞',
    '🧇', '🧀', '🍔', '🍟', '🍕', '🌭', '🥪', '🌮',
    '🥗', '🍝', '🍜', '🍲', '🍣', '🍱', '🍤', '🍙',
    '🍡', '🍧', '🍨', '🍦', '🧁', '🍰', '🎂', '🍮',
    '🍭', '🍬', '🍫', '🍿', '🍩', '🍪', '☕', '🍵',
    '🥤', '🍺', '🍻', '🥂', '🍷', '🥃', '🍸', '🍹',
  ]),
  _EmojiCategory(icon: '⚽', emojis: [
    '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
    '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
    '🏏', '⛳', '🏹', '🎣', '🥊', '🥋', '⛸️', '🛹',
    '🎿', '⛷️', '🏂', '🏋️', '🤸', '🤺', '🤾', '🏌️',
    '🏇', '🧘', '🏄', '🏊', '🚴', '🚵', '🎯', '🎮',
  ]),
  _EmojiCategory(icon: '✈️', emojis: [
    '🚗', '🚕', '🚙', '🚌', '🏎️', '🚓', '🚑', '🚒',
    '🛻', '🚚', '🚜', '🛵', '🏍️', '🚲', '🛴', '✈️',
    '🚀', '🛸', '🚁', '⛵', '🚤', '🛳️', '⚓', '🏝️',
    '🏖️', '🏔️', '🗻', '🌋', '🏕️', '🏠', '🏡', '🌆',
    '🌃', '🌉', '🗼', '🎡', '🎢', '🎠', '🌅', '🌄',
  ]),
  _EmojiCategory(icon: '💡', emojis: [
    '💡', '🔦', '🕯️', '📱', '💻', '⌨️', '🖥️', '🖨️',
    '🎧', '📷', '📸', '📹', '🎥', '📺', '📻', '🎙️',
    '⏰', '⌚', '📚', '📖', '✏️', '🖊️', '🎨', '🎭',
    '🎬', '🎤', '🎸', '🎹', '🥁', '🎺', '🎻', '🎲',
    '🧩', '🎁', '🎈', '🎉', '🎊', '🔮', '🪄', '🌈',
  ]),
];

const _stickers = <String>[
  '❤️', '🥰', '😘', '🌹', '💍', '💌', '💘', '💖',
  '😍', '💐', '🍫', '👩‍❤️‍👨', '☕', '🍷', '🍕', '🎬',
  '✨', '🚗', '🌅', '🧁', '🐱', '🐼', '🐶', '🐰',
];

/// Dark emoji / sticker panel shown below the message composer.
class ChatEmojiPicker extends StatefulWidget {
  final ValueChanged<String> onEmojiSelected;
  final ValueChanged<String> onStickerSelected;

  const ChatEmojiPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onStickerSelected,
  });

  @override
  State<ChatEmojiPicker> createState() => _ChatEmojiPickerState();
}

class _ChatEmojiPickerState extends State<ChatEmojiPicker> {
  int _tab = 0; // 0 Emoji, 1 Bitmoji, 2 Stickers, 3 GIF
  int _category = 0;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.44;
    final height = maxHeight.clamp(220.0, 330.0);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: _P.panel,
        border: Border(top: BorderSide(color: _P.divider)),
      ),
      child: Column(
        children: [
          _buildTabs(),
          Expanded(child: _buildContent()),
          if (_tab == 0) _buildCategoryBar(),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Row(
        children: [
          _tabChip(0, 'Emoji', Icons.emoji_emotions_outlined),
          const SizedBox(width: 2),
          _tabChip(1, 'Bitmoji', Icons.auto_awesome_outlined),
          const SizedBox(width: 2),
          _tabChip(2, 'Stickers', Icons.sticky_note_2_outlined),
          const SizedBox(width: 2),
          _tabChip(3, 'GIF', null),
          const Spacer(),
          GestureDetector(
            onTap: _showSearchNote,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _P.pill,
                shape: BoxShape.circle,
                border: Border.all(color: _P.border),
              ),
              child: const Icon(Icons.search, size: 15, color: _P.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(int index, String label, IconData? icon) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 12 : 8,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: selected ? _P.pillGradient : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : _P.muted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF9C93AC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (_tab) {
      case 2:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: _stickers.length,
          itemBuilder: (_, i) => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.onStickerSelected(_stickers[i]),
            child: Center(
              child: Text(_stickers[i], style: const TextStyle(fontSize: 34)),
            ),
          ),
        );
      case 1:
        return _buildEmptyTab(
          Icons.auto_awesome_outlined,
          'Bitmoji is not available in this offline build',
        );
      case 3:
        return _buildEmptyTab(
          Icons.gif_box_outlined,
          'GIF search needs a network connection',
        );
      default:
        final emojis = _categories[_category].emojis;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: emojis.length,
          itemBuilder: (_, i) => InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => widget.onEmojiSelected(emojis[i]),
            child: Center(
              child: Text(emojis[i], style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
    }
  }

  Widget _buildEmptyTab(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: _P.muted),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _P.muted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category bar ──────────────────────────────────────────────────────────
  Widget _buildCategoryBar() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _P.divider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _category = 0),
            child: const Icon(
              Icons.access_time_rounded,
              size: 18,
              color: _P.muted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: List.generate(_categories.length, (i) {
                  final active = _category == i;
                  return GestureDetector(
                    onTap: () => setState(() => _category = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      height: 42,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _categories[i].icon,
                            style: TextStyle(
                              fontSize: 17,
                              color: active ? null : _P.muted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            height: 3,
                            width: active ? 18 : 0,
                            decoration: BoxDecoration(
                              gradient: _P.underline,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Emoji search is not available offline'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF231A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
