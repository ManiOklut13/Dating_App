import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/theme_service.dart';
import '../../features/plan_date/screens/plan_date_screen.dart';
import 'whatsapp_sticker_drawer.dart';

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

  bool _isDrawerOpen = false;
  bool _hasInputText = false;

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

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasInputText) {
      setState(() {
        _hasInputText = hasText;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    AppDataService.instance.sendMessage(widget.conversation.id, text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _toggleStickerDrawer() {
    if (_isDrawerOpen) {
      setState(() => _isDrawerOpen = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _isDrawerOpen = true);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _handleStickerSelected(StickerItem sticker) {
    AppDataService.instance.sendMessage(
      widget.conversation.id,
      sticker.emoji,
      type: 'sticker',
    );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _handleEmojiSelected(String emoji) {
    final currentText = _textController.text;
    final selection = _textController.selection;
    final newText = selection.textBefore(currentText) +
        emoji +
        selection.textAfter(currentText);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + emoji.length,
      ),
    );
  }

  void _handleGifSelected(String gifUrl, String title) {
    AppDataService.instance.sendMessage(
      widget.conversation.id,
      title,
      type: 'gif',
      mediaUrl: gifUrl,
    );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _handleBackspace() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      _textController.text = text.characters.skipLast(1).toString();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REQUIREMENT 3: PLUS (+) ICON POP-UP MENU (Camera, Add Photo, Plan Date)
  // ─────────────────────────────────────────────────────────────────────────
  void _showPlusMenu(BuildContext context) {
    // Dismiss drawer and keyboard
    if (_isDrawerOpen) setState(() => _isDrawerOpen = false);
    _focusNode.unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2C34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2A3942),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Little handle bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: WhatsAppColors.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 1: Camera (EXACT FIRST OPTION)
                  _buildPlusMenuItem(
                    icon: Icons.camera_alt_rounded,
                    iconBg: const Color(0xFFFF2D55),
                    title: 'Camera',
                    subtitle: 'Take a photo or quick selfie',
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleCameraAction();
                    },
                  ),

                  const Divider(color: Color(0xFF2A3942), height: 1),

                  // Option 2: Add Photo (EXACT SECOND OPTION)
                  _buildPlusMenuItem(
                    icon: Icons.photo_library_rounded,
                    iconBg: const Color(0xFF9B51E0),
                    title: 'Add Photo',
                    subtitle: 'Choose from dating photo gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleAddPhotoAction();
                    },
                  ),

                  const Divider(color: Color(0xFF2A3942), height: 1),

                  // Option 3: Plan Date (EXACT THIRD OPTION)
                  _buildPlusMenuItem(
                    icon: Icons.calendar_month_rounded,
                    iconBg: const Color(0xFFFFD700),
                    title: 'Plan Date',
                    subtitle: 'Schedule a coffee, dinner, or walk',
                    onTap: () {
                      Navigator.pop(ctx);
                      _handlePlanDateAction();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlusMenuItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBg.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: iconBg.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Icon(icon, color: iconBg, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: WhatsAppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: WhatsAppColors.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: WhatsAppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _handleCameraAction() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.flamePink),
                const SizedBox(height: 12),
                const Text(
                  'Camera Snapshot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WhatsAppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulate capturing a live photo to share instantly in your chat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: WhatsAppColors.textMuted),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A884),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.camera),
                    label: const Text('Capture & Send Snapshot', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppDataService.instance.sendMessage(
                        widget.conversation.id,
                        '📸 Live Camera Photo',
                        type: 'image',
                        mediaUrl: 'assets/images/ananya.jpg',
                      );
                      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAddPhotoAction() {
    final samplePhotos = [
      {'title': 'Sunset Coffee', 'asset': 'assets/images/ananya.jpg'},
      {'title': 'Art Studio Vibes', 'asset': 'assets/images/riya.jpg'},
      {'title': 'Weekend Hike', 'asset': 'assets/images/rohit.jpg'},
      {'title': 'City Lights', 'asset': 'assets/images/aditya.jpg'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WhatsAppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: WhatsAppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: samplePhotos.length,
                  itemBuilder: (context, idx) {
                    final photo = samplePhotos[idx];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        AppDataService.instance.sendMessage(
                          widget.conversation.id,
                          photo['title']!,
                          type: 'image',
                          mediaUrl: photo['asset']!,
                        );
                        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          photo['asset']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePlanDateAction() {
    // ── Navigate to the full "Plan a Date" feature screen ─────────────────
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: const [],
          child: PlanDateScreen(
            initialPartnerId: widget.conversation.id,
            initialPartnerName: widget.conversation.name,
            initialPartnerAvatar: widget.conversation.avatarAsset,
            initialPartnerOnline: widget.conversation.isOnline,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INVITE TO APP MODAL
  // ─────────────────────────────────────────────────────────────────────────
  void _showInviteToAppModal(BuildContext context) {
    const inviteLink = 'https://younme.app/invite?code=YOUNME-ALEX-VIP';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
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
                      color: WhatsAppColors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A884).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFF00A884),
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
                              color: WhatsAppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Earn 50 YoUnMe Coins for each friend who joins',
                            style: TextStyle(
                              fontSize: 12,
                              color: WhatsAppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202C33),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3942)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          inviteLink,
                          style: TextStyle(
                            color: AppColors.cyanAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: WhatsAppColors.textPrimary),
                        tooltip: 'Copy Link',
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite link copied to clipboard!'),
                              backgroundColor: Color(0xFF00A884),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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
                          foregroundColor: WhatsAppColors.textPrimary,
                          side: const BorderSide(color: Color(0xFF2A3942)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share Link'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening share drawer...'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A884),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('WhatsApp'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inviting via WhatsApp...'),
                              backgroundColor: Color(0xFF00A884),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD METHOD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final currentConv = AppDataService.instance.conversations.firstWhere(
          (c) => c.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        return Scaffold(
          backgroundColor: WhatsAppColors.background,
          appBar: AppBar(
            backgroundColor: WhatsAppColors.appHeader,
            elevation: 0.5,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: WhatsAppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF2A3942),
                      backgroundImage: currentConv.avatarAsset != null
                          ? AssetImage(currentConv.avatarAsset!)
                          : null,
                      child: currentConv.avatarAsset == null
                          ? Text(
                              currentConv.name.substring(0, 1),
                              style: const TextStyle(
                                color: WhatsAppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: currentConv.isOnline
                              ? const Color(0xFF00E676)
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WhatsAppColors.appHeader,
                            width: 1.5,
                          ),
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
                              currentConv.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: WhatsAppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (currentConv.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 15,
                              color: AppColors.cyanAccent,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        currentConv.isOnline ? 'online' : 'offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: currentConv.isOnline
                              ? const Color(0xFF00A884)
                              : WhatsAppColors.textMuted,
                          fontWeight: currentConv.isOnline
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ─────────────────────────────────────────────────────────────────
            // REQUIREMENT 2: TOP RIGHT NAVIGATION BAR UPDATE
            // Between the Call button and Settings button: REPLACE VIDEO ICON
            // WITH "Invite to App" BUTTON!
            // ─────────────────────────────────────────────────────────────────
            actions: [
              // 1. Call Button
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: WhatsAppColors.textPrimary, size: 21),
                tooltip: 'Voice Call',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting voice call with ${currentConv.name}...'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // 2. "Invite to App" Button (Replaces Video Call icon!)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showInviteToAppModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A884).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00A884).withValues(alpha: 0.7),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 14,
                              color: Color(0xFF00A884),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Invite to App',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00A884),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Settings Button (3-Dot menu)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: WhatsAppColors.textPrimary, size: 22),
                color: const Color(0xFF1F2C34),
                onSelected: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$val action performed'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'View Profile',
                    child: Text('View Profile', style: TextStyle(color: WhatsAppColors.textPrimary)),
                  ),
                  const PopupMenuItem(
                    value: 'Search Chat',
                    child: Text('Search', style: TextStyle(color: WhatsAppColors.textPrimary)),
                  ),
                  const PopupMenuItem(
                    value: 'Mute Notifications',
                    child: Text('Mute Notifications', style: TextStyle(color: WhatsAppColors.textPrimary)),
                  ),
                  const PopupMenuItem(
                    value: 'Wallpaper',
                    child: Text('Wallpaper', style: TextStyle(color: WhatsAppColors.textPrimary)),
                  ),
                  const PopupMenuItem(
                    value: 'Safety & Report',
                    child: Text('Safety & Report', style: TextStyle(color: AppColors.errorRed)),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Security Guard Ribbon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                color: const Color(0xFF182229),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.goldAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Messages and calls are end-to-end encrypted with YoUnMe Contact Guard.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: WhatsAppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages List with Date Separator Pill
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: currentConv.messages.length + 1, // +1 for Date Pill
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: WhatsAppColors.datePill,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: WhatsAppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }

                    final msg = currentConv.messages[index - 1];
                    return _buildWhatsAppBubble(context, msg, theme);
                  },
                ),
              ),

              // ─────────────────────────────────────────────────────────────
              // REQUIREMENT 1: WHATSAPP STYLE COMPOSER BAR & INPUT PILL
              // ─────────────────────────────────────────────────────────────
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 6, 8, 8),
                  decoration: const BoxDecoration(
                    color: WhatsAppColors.background,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Plus (+) Icon on the left of input bar (Requirement 3 trigger)
                      Container(
                        margin: const EdgeInsets.only(bottom: 2, right: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _showPlusMenu(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF202C33),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: WhatsAppColors.textPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // WhatsApp Input Pill: Contains Emoji toggle, TextField, and Camera
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: WhatsAppColors.inputPill,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Emoji / Keyboard toggle icon
                              IconButton(
                                icon: Icon(
                                  _isDrawerOpen
                                      ? Icons.keyboard_alt_outlined
                                      : Icons.emoji_emotions_outlined,
                                  color: WhatsAppColors.textMuted,
                                  size: 24,
                                ),
                                onPressed: _toggleStickerDrawer,
                              ),

                              // Text field
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  style: const TextStyle(
                                    color: WhatsAppColors.textPrimary,
                                    fontSize: 15,
                                  ),
                                  maxLines: 4,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    hintStyle: TextStyle(
                                      color: WhatsAppColors.textMuted,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 4,
                                    ),
                                  ),
                                  onSubmitted: (_) => _handleSend(),
                                ),
                              ),

                              // Camera shortcut icon inside the pill
                              IconButton(
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: WhatsAppColors.textMuted,
                                  size: 22,
                                ),
                                onPressed: _handleCameraAction,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Circular WhatsApp Floating Mic / Send Button
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        child: Material(
                          color: const Color(0xFF00A884), // WhatsApp signature green
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _hasInputText
                                ? _handleSend
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Hold to record voice note...'),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              child: Icon(
                                _hasInputText
                                    ? Icons.send_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─────────────────────────────────────────────────────────────
              // REQUIREMENT 1: WHATSAPP STYLE STICKER/EMOJI/GIF DRAWER
              // ─────────────────────────────────────────────────────────────
              if (_isDrawerOpen)
                WhatsAppStickerDrawer(
                  onStickerSelected: _handleStickerSelected,
                  onEmojiSelected: _handleEmojiSelected,
                  onGifSelected: _handleGifSelected,
                  onBackspace: _handleBackspace,
                ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REQUIREMENT 1 & 4: WHATSAPP DARK-MODE MESSAGE BUBBLES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWhatsAppBubble(
    BuildContext context,
    ChatMessageModel msg,
    YoUnMeThemeExtension theme,
  ) {
    final isMe = msg.isMe;

    // 1. Sticker message (Transparent background, large sticker, timestamp below)
    if (msg.type == 'sticker') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                msg.body,
                style: const TextStyle(fontSize: 90),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.timestamp,
                    style: const TextStyle(
                      fontSize: 10,
                      color: WhatsAppColors.textMuted,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 14,
                      color: WhatsAppColors.checkmarkBlue,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 2. Photo / Image message
    if (msg.type == 'image' && msg.mediaUrl != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? WhatsAppColors.outgoingBubble : WhatsAppColors.incomingBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 3),
              bottomRight: Radius.circular(isMe ? 3 : 14),
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  msg.mediaUrl!,
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                ),
              ),
              if (msg.body.isNotEmpty && msg.body != 'Shared a photo') ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
                  child: Text(
                    msg.body,
                    style: const TextStyle(
                      color: WhatsAppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.timestamp,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all,
                        size: 14,
                        color: WhatsAppColors.checkmarkBlue,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Date Plan message card
    if (msg.type == 'date_plan') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF1B3B33)
                : const Color(0xFF202C33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.goldAccent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Date Invitation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldAccent,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A884).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A884),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: WhatsAppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    msg.timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 14,
                      color: WhatsAppColors.checkmarkBlue,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 4. Standard Text message bubble (WhatsApp classic Dark Mode styling)
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
        decoration: BoxDecoration(
          color: isMe ? WhatsAppColors.outgoingBubble : WhatsAppColors.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
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
                fontSize: 14.5,
                height: 1.35,
                color: WhatsAppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : WhatsAppColors.textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: WhatsAppColors.checkmarkBlue,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
