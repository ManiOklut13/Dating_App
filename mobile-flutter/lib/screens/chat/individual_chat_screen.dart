import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../calls/calls_screen.dart';
import 'chat_emoji_picker.dart';
import 'plan_date_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _K {
  _K._();

  static const Color bg = Color(0xFF0A070D);
  static const Color header = Color(0xFF0C080F);
  static const Color panel = Color(0xFF120F17);
  static const Color field = Color(0xFF171320);
  static const Color bubbleIn = Color(0xFF1B1622);
  static const Color border = Color(0x1FFFFFFF);
  static const Color divider = Color(0xFF1F1825);
  static const Color pink = Color(0xFFFF2D55);
  static const Color pinkSoft = Color(0xFFFF6B8B);
  static const Color gold = Color(0xFFFFC94D);
  static const Color green = Color(0xFF22C55E);
  static const Color purple = Color(0xFFB47CFF);
  static const Color verified = Color(0xFF4DA3FF);
  static const Color muted = Color(0xFF6E6480);

  static const LinearGradient plus = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFC026D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient outgoing = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFD6246E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient send = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFC026D3)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient pageGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33230712), Color(0x000A070D)],
  );
}

class IndividualChatScreen extends StatefulWidget {
  final ChatConversationModel conversation;

  const IndividualChatScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _emojiOpen = false;
  bool _hasInputText = false;
  bool _muted = false;
  bool _screenshotGuardOn = true;

  bool _recording = false;
  int _recSeconds = 0;
  Timer? _recTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataService.instance.markAsRead(widget.conversation.id);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  ChatConversationModel get _conv {
    return AppDataService.instance.conversations.firstWhere(
      (c) => c.id == widget.conversation.id,
      orElse: () => widget.conversation,
    );
  }

  // ── Composer helpers ──────────────────────────────────────────────────────
  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasInputText) {
      setState(() => _hasInputText = hasText);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _emojiOpen) {
      setState(() => _emojiOpen = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    AppDataService.instance.sendMessage(widget.conversation.id, text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _toggleEmojiPicker() {
    if (_emojiOpen) {
      setState(() => _emojiOpen = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() {
        _emojiOpen = true;
        _recording = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, emoji);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void _sendSticker(String sticker) {
    AppDataService.instance.sendMessage(
      widget.conversation.id,
      sticker,
      type: 'sticker',
    );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  // ── Recording ─────────────────────────────────────────────────────────────
  String get _recLabel {
    final m = (_recSeconds ~/ 60).toString();
    final s = (_recSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startRecording() {
    if (_recording) return;
    _focusNode.unfocus();
    _recTimer?.cancel();
    setState(() {
      _emojiOpen = false;
      _recording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recSeconds++);
    });
  }

  void _cancelRecording() {
    _recTimer?.cancel();
    setState(() {
      _recording = false;
      _recSeconds = 0;
    });
  }

  void _sendRecording() {
    final label = _recLabel;
    _recTimer?.cancel();
    setState(() {
      _recording = false;
      _recSeconds = 0;
    });
    AppDataService.instance.sendMessage(
      widget.conversation.id,
      'Voice note · $label',
      type: 'voice',
    );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  // ── Navigation / sheets ───────────────────────────────────────────────────
  void _openPlanDate() {
    final conv = _conv;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanDateScreen(partner: conv)),
    );
  }

  void _handleAudioCall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CallsScreen()),
    );
  }

  void _showPlusMenu() {
    if (_emojiOpen) setState(() => _emojiOpen = false);
    _focusNode.unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _K.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: _K.border)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _sheetOption(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                bg: const Color(0xFF3A1220),
                accent: const Color(0xFFFF5C7A),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCamera();
                },
              ),
              _sheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Photos and videos',
                bg: const Color(0xFF2A1638),
                accent: _K.purple,
                onTap: () {
                  Navigator.pop(ctx);
                  _openGallery();
                },
              ),
              _sheetOption(
                icon: Icons.calendar_month_outlined,
                label: 'Plan a date',
                bg: const Color(0xFF33280F),
                accent: _K.gold,
                onTap: () {
                  Navigator.pop(ctx);
                  _openPlanDate();
                },
              ),
              _sheetOption(
                icon: Icons.mic_none_rounded,
                label: 'Voice note',
                bg: const Color(0xFF12291C),
                accent: const Color(0xFF4ADE80),
                onTap: () {
                  Navigator.pop(ctx);
                  _startRecording();
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required Color bg,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 21, color: accent),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCamera() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _K.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1220),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _K.pink.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 28,
                  color: Color(0xFFFF5C7A),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Camera Snapshot',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Capture a moment and share it instantly in this chat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: _K.muted, height: 1.4),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  AppDataService.instance.sendMessage(
                    widget.conversation.id,
                    '📸 Live Camera Photo',
                    type: 'image',
                    mediaUrl: 'assets/images/ananya.jpg',
                  );
                  Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _K.send,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Capture & Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGallery() {
    const photos = [
      {'title': 'Sunset Coffee', 'asset': 'assets/images/ananya.jpg'},
      {'title': 'Art Studio Vibes', 'asset': 'assets/images/riya.jpg'},
      {'title': 'Weekend Hike', 'asset': 'assets/images/rohit.jpg'},
      {'title': 'City Lights', 'asset': 'assets/images/aditya.jpg'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _K.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Photos and videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, size: 20, color: _K.muted),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: photos.length,
                itemBuilder: (_, i) {
                  final photo = photos[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      AppDataService.instance.sendMessage(
                        widget.conversation.id,
                        photo['title']!,
                        type: 'image',
                        mediaUrl: photo['asset']!,
                      );
                      Future.delayed(
                        const Duration(milliseconds: 100),
                        _scrollToBottom,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(photo['asset']!, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet() {
    final conv = _conv;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _K.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2A2036),
                    backgroundImage: conv.avatarAsset != null
                        ? AssetImage(conv.avatarAsset!)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                conv.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (conv.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified,
                                size: 15,
                                color: _K.verified,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${conv.age} · ${conv.occupation}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _K.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conv.city,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _K.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (conv.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  conv.bio,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (conv.interests.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final interest in conv.interests)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _K.pink.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _K.pink.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _K.pinkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openPlanDate();
                      },
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _K.field,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _K.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: _K.gold,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Plan a date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: _K.send,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }

  void _showInviteSheet() {
    const inviteLink = 'https://younme.app/invite?code=YOUNME-ALEX-VIP';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _K.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invite to YoUnMe',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Earn 50 YoUnMe Coins for each friend who joins.',
                style: TextStyle(fontSize: 12.5, color: _K.muted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                decoration: BoxDecoration(
                  color: _K.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _K.border),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        inviteLink,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA2BC),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy link',
                      icon: const Icon(
                        Icons.copy,
                        size: 17,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                          const ClipboardData(text: inviteLink),
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _snack('Invite link copied to clipboard');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _snack('Opening share options…');
                },
                child: Container(
                  height: 46,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _K.send,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Share link',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReport() {
    final conv = _conv;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _K.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _K.border),
        ),
        title: const Text(
          'Safety & Report',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: Text(
          'Report ${conv.name} for inappropriate behaviour? Our Trust Guard team reviews every report.',
          style: const TextStyle(color: Color(0xFF9AA2BC), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _K.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('Report submitted to Trust Guard');
            },
            child: const Text(
              'Report',
              style: TextStyle(color: _K.pink, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF231A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final conv = _conv;
        final bottomInset =
            _emojiOpen ? 0.0 : MediaQuery.paddingOf(context).bottom;

        return Scaffold(
          backgroundColor: _K.bg,
          body: Container(
            decoration: const BoxDecoration(gradient: _K.pageGlow),
            child: Column(
              children: [
                _buildHeader(conv),
                _buildTrustGuard(),
                Expanded(child: _buildMessages(conv)),
                if (_recording) _buildRecordingStrip(),
                _buildComposer(bottomInset),
                if (_emojiOpen)
                  ChatEmojiPicker(
                    onEmojiSelected: _insertEmoji,
                    onStickerSelected: _sendSticker,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ChatConversationModel conv) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.paddingOf(context).top + 8,
        12,
        8,
      ),
      color: _K.header,
      child: Row(
        children: [
          _headerCircle(
            Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _K.outgoing,
                ),
                child: ClipOval(
                  child: conv.avatarAsset != null
                      ? Image.asset(conv.avatarAsset!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF2A2036),
                          alignment: Alignment.center,
                          child: Text(
                            conv.name.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
              if (conv.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _K.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: _K.header, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conv.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (conv.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: _K.verified,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  conv.isOnline ? 'Online now' : 'Last seen 2h ago',
                  style: const TextStyle(fontSize: 11.5, color: _K.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _headerCircle(
            Icons.call_outlined,
            color: _K.green,
            onTap: _handleAudioCall,
          ),
          const SizedBox(width: 8),
          _headerCircle(
            Icons.calendar_month_outlined,
            color: _K.gold,
            onTap: _openPlanDate,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Chat options',
            color: _K.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: _K.border),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showProfileSheet();
                  break;
                case 'mute':
                  setState(() => _muted = !_muted);
                  _snack(_muted ? 'Notifications muted' : 'Notifications on');
                  break;
                case 'invite':
                  _showInviteSheet();
                  break;
                case 'search':
                  _snack('Search is available from the Chat tab');
                  break;
                case 'report':
                  _confirmReport();
                  break;
              }
            },
            itemBuilder: (context) => [
              _menuItem('profile', Icons.person_outline, 'View profile'),
              _menuItem(
                'mute',
                _muted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                _muted ? 'Unmute notifications' : 'Mute notifications',
              ),
              _menuItem('invite', Icons.person_add_alt_1, 'Invite to YoUnMe'),
              _menuItem('search', Icons.search, 'Search chat'),
              _menuItem(
                'report',
                Icons.shield_outlined,
                'Safety & Report',
                color: _K.pink,
              ),
            ],
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: _K.field,
                shape: BoxShape.circle,
                border: Border.all(color: _K.border),
              ),
              child: const Icon(
                Icons.more_vert,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    Color color = Colors.white,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 17, color: color.withValues(alpha: 0.85)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 13.5, color: color),
          ),
        ],
      ),
    );
  }

  Widget _headerCircle(
    IconData icon, {
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: _K.field,
          shape: BoxShape.circle,
          border: Border.all(color: _K.border),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ── Trust Guard banner ────────────────────────────────────────────────────
  Widget _buildTrustGuard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF3A0F1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _K.pink.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 15, color: _K.pinkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Trust Guard: Stay safe while chatting',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: _K.pinkSoft.withValues(alpha: 0.95),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _screenshotGuardOn = !_screenshotGuardOn);
              _snack(
                _screenshotGuardOn
                    ? 'Screenshot Guard enabled'
                    : 'Screenshot Guard paused',
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4A1224),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _K.pink.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Screenshot Guard',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _screenshotGuardOn
                      ? const Color(0xFFFFC2D1)
                      : _K.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages ──────────────────────────────────────────────────────────────
  Widget _buildMessages(ChatConversationModel conv) {
    if (conv.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 34, color: _K.divider),
              SizedBox(height: 12),
              Text(
                'Messages are protected by Trust Guard',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: _K.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      itemCount: conv.messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildDatePill();
        return _buildMessage(conv.messages[index - 1]);
      },
    );
  }

  Widget _buildDatePill() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _K.bubbleIn,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _K.border),
        ),
        child: const Text(
          'TODAY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: _K.muted,
          ),
        ),
      ),
    );
  }

  Widget _timestamp(bool isMe, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: color ??
                (isMe ? Colors.white.withValues(alpha: 0.72) : _K.muted),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(
            Icons.done_all,
            size: 13,
            color: color ?? Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ],
    );
  }

  Widget _buildMessage(ChatMessageModel msg) {
    final isMe = msg.isMe;

    // Stickers render without a bubble.
    if (msg.type == 'sticker') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(msg.body, style: const TextStyle(fontSize: 76)),
              const SizedBox(height: 2),
              _timestamp(isMe, msg.timestamp),
            ],
          ),
        ),
      );
    }

    // Image message.
    if (msg.type == 'image' && msg.mediaUrl != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isMe ? _K.outgoing : null,
            color: isMe ? null : _K.bubbleIn,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  msg.mediaUrl!,
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                ),
              ),
              if (msg.body.isNotEmpty && msg.body != 'Shared a photo')
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
                  child: Text(
                    msg.body,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                child: _timestamp(
                  isMe,
                  msg.timestamp,
                  color: isMe ? null : _K.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Voice note.
    if (msg.type == 'voice') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          decoration: BoxDecoration(
            gradient: isMe ? _K.outgoing : null,
            color: isMe ? null : _K.bubbleIn,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            border: isMe ? null : Border.all(color: _K.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.22)
                      : _K.pink.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: isMe ? Colors.white : _K.pinkSoft,
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: List.generate(14, (i) {
                  final heights = [6.0, 11.0, 16.0, 9.0, 14.0, 7.0];
                  return Container(
                    width: 2.5,
                    height: heights[i % heights.length],
                    margin: const EdgeInsets.only(right: 2.5),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.8)
                          : _K.pinkSoft.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.body.replaceFirst('Voice note · ', ''),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white : Colors.white70,
                    ),
                  ),
                  _timestamp(isMe, msg.timestamp),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Date invitation card.
    if (msg.type == 'date_plan') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _K.bubbleIn,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _K.gold.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _K.gold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                      color: _K.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Date Invitation',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _K.gold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _K.green.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _K.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.body,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _timestamp(isMe, msg.timestamp),
              ),
            ],
          ),
        ),
      );
    }

    // Plain text.
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        padding: const EdgeInsets.fromLTRB(13, 9, 11, 7),
        decoration: BoxDecoration(
          gradient: isMe ? _K.outgoing : null,
          color: isMe ? null : _K.bubbleIn,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: _K.border),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          runSpacing: 2,
          children: [
            Text(
              msg.body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Colors.white,
              ),
            ),
            _timestamp(isMe, msg.timestamp),
          ],
        ),
      ),
    );
  }

  // ── Recording strip ───────────────────────────────────────────────────────
  Widget _buildRecordingStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A0D1E), Color(0xFF240A16)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _K.pink.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B5C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Recording Audio Note: $_recLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _K.border),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendRecording,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: _K.send,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.send_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ── Composer ──────────────────────────────────────────────────────────────
  Widget _buildComposer(double bottomInset) {
    return Container(
      color: _K.bg,
      padding: EdgeInsets.fromLTRB(12, 4, 12, 8 + bottomInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showPlusMenu,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _K.plus,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _K.pink.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: _K.field,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _K.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 4, 2),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: Color(0xFF7A7188),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  _composerIcon(
                    _emojiOpen
                        ? Icons.keyboard_alt_outlined
                        : Icons.emoji_emotions_outlined,
                    _toggleEmojiPicker,
                  ),
                  _composerIcon(Icons.image_outlined, _openGallery),
                  _composerIcon(
                    _hasInputText ? Icons.send_rounded : Icons.mic_none_rounded,
                    _hasInputText ? _handleSend : _startRecording,
                    color: _hasInputText ? _K.pinkSoft : null,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _composerIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 44,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: color ?? const Color(0xFF9C93AC)),
      ),
    );
  }
}
