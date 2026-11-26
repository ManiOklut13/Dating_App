import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'date_plan_models.dart';

// ── Color & Style Constants matching Screenshots 2 & 3 ───────────────────────
class _ADColors {
  _ADColors._();

  static const Color bg = Color(0xFF0B0711);
  static const Color card = Color(0xFF1A1424);
  static const Color cardBorder = Color(0xFF2B223B);
  static const Color recessedBg = Color(0xFF130E1B);
  static const Color recessedBorder = Color(0xFF241C30);

  static const Color pink = Color(0xFFE9297B);
  static const Color pinkGradientEnd = Color(0xFFF03888);
  static const Color textMuted = Color(0xFF9A91A8);
  static const Color heartEmpty = Color(0xFF9A91A8);
  static const Color tileEmpty = Color(0xFF140F1D);

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [pink, pinkGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// "After the Date" reflection screen.
/// Implements full interactive state: mode switch, 5-heart rating, photo addition,
/// highlights chip toggling, live 200-character memory note, and share switch.
class AfterTheDateScreen extends StatefulWidget {
  const AfterTheDateScreen({
    super.key,
    this.partnerName = 'Ananya',
    this.dateTitle = 'Movie Night',
    this.dateTime,
    this.durationMinutes = 60,
    this.mode = DateMode.virtual,
    this.splitLabel = '50% / 50%',
    this.coinCost = 150,
    this.rating = 0,
    this.photos = const [],
    this.highlights = const [],
    this.memoryNote = '',
    this.shareToggle = true,
  });

  final String partnerName;
  final String dateTitle;
  final DateTime? dateTime;
  final int durationMinutes;
  final DateMode mode;
  final String splitLabel;
  final int coinCost;
  final int rating; // 0..5
  final List<String> photos;
  final List<String> highlights;
  final String memoryNote;
  final bool shareToggle;

  @override
  State<AfterTheDateScreen> createState() => _AfterTheDateScreenState();
}

class _AfterTheDateScreenState extends State<AfterTheDateScreen> {
  late DateMode _mode;
  late int _rating;
  late List<String> _photos;
  late Set<String> _selectedHighlights;
  late TextEditingController _memoryNoteController;
  late bool _shareToggle;

  static const List<String> _kHighlightOptions = [
    'Great conversation',
    'Lots of laughs',
    'Felt comfortable',
    'Great food',
    'Perfect spot',
    'Would repeat',
  ];

  static const List<String> _kSamplePhotoAssets = [
    'assets/images/ananya.jpg',
    'assets/images/riya.jpg',
    'assets/images/rohit.jpg',
    'assets/images/aditya.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _rating = widget.rating;
    _photos = List<String>.from(widget.photos);
    _selectedHighlights = Set<String>.from(widget.highlights);
    _memoryNoteController = TextEditingController(text: widget.memoryNote);
    _shareToggle = widget.shareToggle;
    _memoryNoteController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _memoryNoteController.removeListener(_onTextChanged);
    _memoryNoteController.dispose();
    super.dispose();
  }

  String get _formattedSubtitle {
    final dt = widget.dateTime ?? DateTime.now();
    final dateStr = DateFormat('MMMM d').format(dt);
    final timeStr = DateFormat('HH:mm a').format(dt);
    final modeLabel = _mode == DateMode.virtual ? 'Virtual Date' : 'Offline Date';
    return '$modeLabel · $dateStr · $timeStr · ${widget.durationMinutes} min';
  }

  void _addPhoto() {
    if (_photos.length >= 6) {
      _showToast('Maximum of 6 photos reached');
      return;
    }
    setState(() {
      final nextAsset = _kSamplePhotoAssets[_photos.length % _kSamplePhotoAssets.length];
      _photos.add(nextAsset);
    });
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      setState(() {
        _photos.removeAt(index);
      });
    }
  }

  void _toggleHighlight(String label) {
    setState(() {
      if (_selectedHighlights.contains(label)) {
        _selectedHighlights.remove(label);
      } else {
        _selectedHighlights.add(label);
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF231A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveToMemories() {
    _showToast('Saved to memories with ${widget.partnerName}! 🎉');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ADColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          color: _ADColors.bg,
          gradient: RadialGradient(
            center: Alignment(0.85, -0.9),
            radius: 1.3,
            colors: [
              Color(0x33E9297B),
              _ADColors.bg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── A. Top App Bar ───────────────────────────────────────────
              _buildTopAppBar(),

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Date Header & Mode Toggle Card
                      _buildDateSummaryCard(),
                      const SizedBox(height: 16),

                      // 2. "How did it go?" Rating Card
                      _buildRatingCard(),
                      const SizedBox(height: 16),

                      // 3. "Add Photos" Card
                      _buildAddPhotosCard(),
                      const SizedBox(height: 16),

                      // 4. "What made it special?" Highlights Card
                      _buildHighlightsCard(),
                      const SizedBox(height: 16),

                      // 5. "Memory Note" Card
                      _buildMemoryNoteCard(),
                      const SizedBox(height: 16),

                      // 6. "Share with {PartnerName}" Toggle Card
                      _buildShareToggleCard(),
                      const SizedBox(height: 24),

                      // 7. Bottom CTA Button
                      _buildSaveButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── A. Top App Bar ─────────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'After the ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: 'Date',
                  style: TextStyle(
                    color: _ADColors.pink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Date Header & Mode Toggle Card ──────────────────────────────────────
  Widget _buildDateSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _ADColors.pink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dateTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formattedSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ADColors.textMuted,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented mode switcher: Virtual | Offline
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _ADColors.recessedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _ADColors.cardBorder),
            ),
            child: Row(
              children: [
                _buildModePill(
                  label: 'Virtual',
                  isActive: _mode == DateMode.virtual,
                  onTap: () => setState(() => _mode = DateMode.virtual),
                ),
                const SizedBox(width: 6),
                _buildModePill(
                  label: 'Offline',
                  isActive: _mode == DateMode.offline,
                  onTap: () => setState(() => _mode = DateMode.offline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? _ADColors.pink : Colors.transparent,
            gradient: isActive ? _ADColors.buttonGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : _ADColors.textMuted,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 2. "How did it go?" Rating Card ────────────────────────────────────────
  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How did it go?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your rating is private until your partner shares hers.',
            style: TextStyle(
              color: _ADColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // 5 heart rating buttons
          Row(
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isSelected = _rating >= starNumber;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = _rating == starNumber ? 0 : starNumber;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == 4 ? 0 : 4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _ADColors.pink.withValues(alpha: 0.18)
                          : _ADColors.tileEmpty,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _ADColors.pink : _ADColors.cardBorder,
                        width: isSelected ? 1.4 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.favorite : Icons.favorite_border,
                        color: isSelected ? _ADColors.pink : _ADColors.heartEmpty,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 3. "Add Photos" Card ───────────────────────────────────────────────────
  Widget _buildAddPhotosCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Photos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_photos.length} of 6 added',
                style: const TextStyle(
                  color: _ADColors.pink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Photo row / grid: Add button + preview thumbnails
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Add button (dashed border rounded square)
              if (_photos.length < 6)
                GestureDetector(
                  onTap: _addPhoto,
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: CustomPaint(
                      painter: _DashedRRectPainter(
                        color: _ADColors.pink,
                        strokeWidth: 1.5,
                        radius: 14,
                        dashWidth: 6.0,
                        dashSpace: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _ADColors.recessedBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: _ADColors.pink,
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: _ADColors.pink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Thumbnails of added photos
              ...List.generate(_photos.length, (index) {
                final photo = _photos[index];
                return Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1627),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _ADColors.cardBorder),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(photo),
                          onError: (_, __) {},
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. "What made it special?" Highlights Card ─────────────────────────────
  Widget _buildHighlightsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What made it special?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _kHighlightOptions.map((option) {
              final isSelected = _selectedHighlights.contains(option);
              return GestureDetector(
                onTap: () => _toggleHighlight(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _ADColors.pink : _ADColors.recessedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _ADColors.pink : _ADColors.cardBorder,
                      width: isSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _ADColors.textMuted,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 5. "Memory Note" Card ──────────────────────────────────────────────────
  Widget _buildMemoryNoteCard() {
    final count = _memoryNoteController.text.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Memory Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _ADColors.recessedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _ADColors.recessedBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _memoryNoteController,
                  maxLength: 200,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null, // Hide the default counter below TextField
                  minLines: 4,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write a memory...',
                    hintStyle: TextStyle(
                      color: _ADColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '$count/200',
                    style: const TextStyle(
                      color: _ADColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. "Share with {PartnerName}" Toggle Card ──────────────────────────────
  Widget _buildShareToggleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ADColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ADColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with ${widget.partnerName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.partnerName} can see your photos and note in your shared memories.',
                  style: const TextStyle(
                    color: _ADColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Custom animated pink toggle switch
          GestureDetector(
            onTap: () {
              setState(() {
                _shareToggle = !_shareToggle;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _shareToggle ? _ADColors.pink : const Color(0xFF2A2036),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment:
                  _shareToggle ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Bottom CTA Button ───────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveToMemories,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _ADColors.buttonGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: _ADColors.pink.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Save to memories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Rounded Rectangle Painter for Add Photo Tile
// ─────────────────────────────────────────────────────────────────────────────
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 14,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        Radius.circular(radius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashWidth, metric.length - distance);
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
