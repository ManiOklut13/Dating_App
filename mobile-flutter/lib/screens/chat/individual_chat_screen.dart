import 'package:flutter/material.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../calls/live_interactive_call_screen.dart';

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
  bool _isVanishMode = false;
  int _messageCount = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataService.instance.markAsRead(widget.conversation.id);
      _scrollToBottom();
    });
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
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Check Trust Guard phone number / link blocker
    final containsPhone = RegExp(r'\b\d{10}\b|\b\d{5}[-\s]\d{5}\b').hasMatch(text);
    final containsLink = RegExp(r'(https?:\/\/|www\.)\S+').hasMatch(text);

    if (containsPhone || containsLink) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛡️ Trust Guard: Phone numbers & external links locked until 20 messages exchanged!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    AppDataService.instance.sendMessage(widget.conversation.id, text);
    _textController.clear();
    setState(() => _messageCount++);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _startCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: widget.conversation.name,
          avatarUrl: widget.conversation.avatarAsset != null
              ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80'
              : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
          isVideo: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataService.instance,
      builder: (context, _) {
        final conv = AppDataService.instance.getConversation(widget.conversation.id) ?? widget.conversation;

        return Scaffold(
          backgroundColor: _isVanishMode ? const Color(0xFF090408) : const Color(0xFF0D070C),
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar: < Back, Avatar, "A 💎 Active Now • Mumbai (Bandra)", "Vanish" toggle button, pink "Call" button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF140A12),
                    border: const Border(bottom: BorderSide(color: Color(0xFF2E1E2B))),
                    boxShadow: _isVanishMode
                        ? [const BoxShadow(color: Color(0x669B51E0), blurRadius: 12)]
                        : null,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x26FFFFFF)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),

                      CircleAvatar(
                        radius: 19,
                        backgroundImage: conv.avatarAsset != null ? AssetImage(conv.avatarAsset!) : null,
                        backgroundColor: const Color(0xFF241822),
                        child: conv.avatarAsset == null
                            ? Text(conv.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                            : null,
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  conv.name,
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                const Text('💎', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            const Text(
                              'Active Now • Mumbai (Bandra)',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF22C55E), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // Vanish toggle button
                      GestureDetector(
                        onTap: () {
                          setState(() => _isVanishMode = !_isVanishMode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isVanishMode ? '👻 Vanish Mode ON: messages disappear after view' : 'Vanish Mode OFF'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isVanishMode ? const Color(0xFF9B51E0) : const Color(0xFF1B1119),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isVanishMode ? const Color(0xFFC084FC) : const Color(0xFF2E1E2B),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_off_outlined,
                                size: 12,
                                color: _isVanishMode ? Colors.white : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vanish',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _isVanishMode ? Colors.white : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Pink "Call" button
                      GestureDetector(
                        onTap: _startCall,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.call, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Call', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Safety banner: "🛡️ Trust Guard Active: Phone numbers & external links locked (Day 1/3 • 6/20 messages)"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B1119),
                    border: Border(bottom: BorderSide(color: Color(0xFF2E1E2B))),
                  ),
                  child: Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trust Guard Active: Phone numbers & external links locked (Day 1/3 • $_messageCount/20 messages)',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x33F59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Auto-Unlocks at 20', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                      ),
                    ],
                  ),
                ),

                // Chat Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: conv.messages.length,
                    itemBuilder: (context, i) {
                      final msg = conv.messages[i];
                      final isSent = msg.isMe;

                      return Align(
                        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: isSent
                                ? const LinearGradient(
                                    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                                  )
                                : null,
                            color: isSent ? null : const Color(0xFF1B1119),
                            border: isSent ? null : Border.all(color: const Color(0xFF2E1E2B)),
                          ),
                          child: Column(
                            crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.body,
                                style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.35),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg.timestamp,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: isSent ? const Color(0xFFFFD5E0) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  if (isSent) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.done_all, size: 12, color: Colors.white70),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Composer: + attachment button, text input "Type a message... (Try phone", pink Send circle button
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF140A12),
                    border: Border(top: BorderSide(color: Color(0xFF2E1E2B))),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attachment options: Photos, Location, Date Plan 📸')),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1119),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2E1E2B)),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1119),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFF2E1E2B)),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Type a message... (Try phone',
                              hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: _handleSend,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                            ),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
