import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import '../../data/profiles_data.dart';

class MessageRequestScreen extends StatefulWidget {
  final CandidateCard profile;

  const MessageRequestScreen({
    super.key,
    required this.profile,
  });

  @override
  State<MessageRequestScreen> createState() => _MessageRequestScreenState();
}

class _MessageRequestScreenState extends State<MessageRequestScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isRecordingVoice = false;
  int _voiceSeconds = 0;
  Timer? _voiceTimer;
  bool _hasVoiceNote = false;

  late final AnimationController _waveAnimCtrl;

  final List<String> _icebreakerPrompts = [
    'Two truths and a lie about our next coffee date? ☕',
    'What\'s the best travel story you never get tired of telling? ✈️',
    'If our playlist had only 3 songs, what\'s your first pick? 🎵',
    'Spontaneous weekend road trip or cozy movie night? 🎬',
    'What\'s a passion project you\'re currently obsessed with? ✨',
    'Pineapple on pizza: absolute dealbreaker or secretly gourmet? 🍕',
    'What is your all-time favorite hidden spot in the city? 📍',
  ];

  @override
  void initState() {
    super.initState();
    _waveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _focusNode.dispose();
    _voiceTimer?.cancel();
    _waveAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleVoiceRecording() {
    if (_isRecordingVoice) {
      _stopVoiceRecording();
    } else {
      _startVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecordingVoice = true;
      _voiceSeconds = 0;
      _hasVoiceNote = false;
    });
    _voiceTimer?.cancel();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_voiceSeconds >= 30) {
        _stopVoiceRecording();
      } else {
        setState(() => _voiceSeconds++);
      }
    });
  }

  void _stopVoiceRecording() {
    _voiceTimer?.cancel();
    setState(() {
      _isRecordingVoice = false;
      _hasVoiceNote = _voiceSeconds > 0;
    });
  }

  void _deleteVoiceNote() {
    setState(() {
      _hasVoiceNote = false;
      _voiceSeconds = 0;
    });
  }

  void _pickIcebreaker(String prompt) {
    setState(() {
      _msgCtrl.text = prompt;
    });
    _focusNode.requestFocus();
  }

  void _handleSend() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty && !_hasVoiceNote) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message or record a voice note.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFE11D48),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Message request sent to ${widget.profile.nickname}! ✨',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  void _openIcebreakersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131620),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFF8DA1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Choose an Icebreaker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any prompt to immediately auto-fill your message request:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _icebreakerPrompts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (c, i) {
                      final prompt = _icebreakerPrompts[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickIcebreaker(prompt);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF191C24),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x1FFFFFFF)),
                          ),
                          child: Text(
                            prompt,
                            style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.35),
                          ),
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF140A12),
                border: Border(bottom: BorderSide(color: Color(0xFF2E1E2B))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SafeProfileImage(imageUrl: profile.photoUrls.first),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.nickname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified, size: 14, color: Color(0xFF38BDF8)),
                          ],
                        ),
                        Text(
                          'Message Request • ${profile.city}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x2BF43F5E),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x66F43F5E)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_email_unread_outlined, size: 12, color: Color(0xFFFF8DA1)),
                        SizedBox(width: 4),
                        Text(
                          'Direct Vibe',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Profile Context & Icebreaker Suggestions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Hero Mini-Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C24),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SafeProfileImage(imageUrl: profile.photoUrls.first),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${profile.nickname}, ${profile.age}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('• ${profile.preference}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Shared Interests Badges
                    if (profile.sharedInterests.isNotEmpty) ...[
                      const Text(
                        'Shared Passions',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.sharedInterests.map((interest) {
                          return GestureDetector(
                            onTap: () {
                              _pickIcebreaker('Hey ${profile.nickname}! I noticed you love $interest too ✨');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0x26FFFFFF)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(interest, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.add, size: 12, color: Color(0xFFFF8DA1)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Quick Icebreaker Suggestions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFF8DA1)),
                            SizedBox(width: 6),
                            Text(
                              'Instant Icebreaker Ideas',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _openIcebreakersSheet,
                          child: const Text(
                            'View All',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _icebreakerPrompts.take(3).map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => _pickIcebreaker(prompt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF191C24),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0x1FFFFFFF)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      prompt,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFFF8DA1)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Voice Note Status Card if Recorded
            if (_hasVoiceNote)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x2638BDF8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x6638BDF8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    Text(
                      'Voice Note Attached (${_voiceSeconds}s)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _deleteVoiceNote,
                      child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),

            // Live Voice Recording Indicator
            if (_isRecordingVoice)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33EF4444),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x80EF4444)),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _waveAnimCtrl,
                      builder: (context, child) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(_waveAnimCtrl.value),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Recording voice note... 0:${_voiceSeconds.toString().padLeft(2, '0')} / 0:30',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _stopVoiceRecording,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('DONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Composer Dock (Chat Box + Icebreaker Icon + Voice Note + Send)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF140A12),
                border: Border(top: BorderSide(color: Color(0xFF2E1E2B))),
              ),
              child: Row(
                children: [
                  // Icebreaker Prompt Icon inside / beside composer
                  GestureDetector(
                    onTap: _openIcebreakersSheet,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C24),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33FF4D88)),
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFF8DA1), size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Chat text typing box
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C24),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _msgCtrl,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Message to ${profile.nickname}...',
                          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Voice Message Note Option (Microphone button)
                  GestureDetector(
                    onTap: _toggleVoiceRecording,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isRecordingVoice ? const Color(0xFFEF4444) : const Color(0xFF191C24),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecordingVoice ? const Color(0xFFEF4444) : const Color(0x3338BDF8),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isRecordingVoice ? Icons.stop : Icons.mic_none_rounded,
                        color: _isRecordingVoice ? Colors.white : const Color(0xFF38BDF8),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x59F43F5E),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
