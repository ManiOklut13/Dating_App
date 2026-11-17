// ─────────────────────────────────────────────────────────────────────────────
// After Date Memories Screen
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plan_date_model.dart';
import '../models/memory_model.dart';
import '../providers/plan_date_providers.dart';
import '../plan_date_theme.dart';
import '../widgets/gradient_text.dart';

class AfterDateMemoriesScreen extends ConsumerWidget {
  final String dateId;
  final DateMode mode;

  const AfterDateMemoriesScreen({
    super.key,
    required this.dateId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memory = ref.watch(memoryFormProvider(dateId));
    final notifier = ref.read(memoryFormProvider(dateId).notifier);

    return Scaffold(
      backgroundColor: PDColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            const _BgGlows(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Header ─────────────────────────────────────────
                      Row(
                        children: [
                          Semantics(
                            label: 'Close memories',
                            button: true,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(PDRadius.avatar),
                              child: Container(
                                width: kMinTouchTarget,
                                height: kMinTouchTarget,
                                decoration: BoxDecoration(
                                  color: PDColors.card,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: PDColors.cardBorder),
                                ),
                                child: const Icon(Icons.close, color: PDColors.textPrimary, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GradientText(
                            'After Date Memories',
                            style: PDTextStyles.heading.copyWith(fontSize: 18),
                            gradient: PDGradients.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Context badge ──────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: PDColors.inputFill,
                            borderRadius: BorderRadius.circular(PDRadius.chip),
                            border: Border.all(color: PDColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                mode == DateMode.virtual
                                    ? Icons.videocam_outlined
                                    : Icons.location_on_outlined,
                                size: 14,
                                color: PDColors.textViolet,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mode == DateMode.virtual ? 'Virtual Date' : 'Offline Date',
                                style: PDTextStyles.muted.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Rating ─────────────────────────────────────────
                      _RatingSection(
                        rating: memory.rating,
                        onRatingChanged: notifier.setRating,
                      ),
                      const SizedBox(height: 16),

                      // ── Photos ─────────────────────────────────────────
                      _PhotosSection(
                        photos: memory.photoPaths,
                        onAdd: (path) => notifier.addPhoto(path),
                        onRemove: notifier.removePhoto,
                      ),
                      const SizedBox(height: 16),

                      // ── Tags ───────────────────────────────────────────
                      _TagsSection(
                        selectedTags: memory.tags,
                        onToggle: notifier.toggleTag,
                      ),
                      const SizedBox(height: 16),

                      // ── Memory note ────────────────────────────────────
                      _MemoryNoteField(
                        note: memory.note,
                        onChanged: notifier.setNote,
                      ),
                      const SizedBox(height: 16),

                      // ── Share toggle ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PDColors.card,
                          borderRadius: BorderRadius.circular(PDRadius.card),
                          border: Border.all(color: PDColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Share with partner', style: PDTextStyles.sectionTitle),
                                  Text(
                                    'They\'ll see your rating after they rate too',
                                    style: PDTextStyles.muted,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: memory.sharedWithPartner,
                              onChanged: notifier.setSharedWithPartner,
                              activeColor: PDColors.textAccent,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // ── Save CTA ──────────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SaveBar(
                enabled: memory.rating > 0,
                onSave: () => _save(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(memoryFormProvider(dateId).notifier).save();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null ? '✅ Memories saved!' : '❌ Save failed'),
          backgroundColor: PDColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (result != null) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating (1–5 hearts)
// ─────────────────────────────────────────────────────────────────────────────
class _RatingSection extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const _RatingSection({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your date', style: PDTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Private until your partner rates too', style: PDTextStyles.muted),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < rating;
              return Semantics(
                label: '${i + 1} heart${i == 0 ? '' : 's'} rating',
                button: true,
                child: GestureDetector(
                  onTap: () => onRatingChanged(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedScale(
                      scale: filled ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        filled ? Icons.favorite : Icons.favorite_border,
                        size: 36,
                        color: filled ? PDColors.textAccent : PDColors.chipBorder,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Photos — 6-slot grid
// ─────────────────────────────────────────────────────────────────────────────
class _PhotosSection extends StatelessWidget {
  final List<String> photos;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _PhotosSection({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pick(BuildContext context, ValueChanged<String> onAdd) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: PDColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PDRadius.card)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: PDColors.textViolet),
              title: Text('Camera', style: PDTextStyles.body),
              onTap: () async {
                Navigator.pop(context);
                final XFile? file = await picker.pickImage(source: ImageSource.camera);
                if (file != null) onAdd(file.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: PDColors.textViolet),
              title: Text('Gallery', style: PDTextStyles.body),
              onTap: () async {
                Navigator.pop(context);
                final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                if (file != null) onAdd(file.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos', style: PDTextStyles.sectionTitle),
          Text('Tap to add, tap again to remove', style: PDTextStyles.muted),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6,
            itemBuilder: (context, i) {
              final hasPhoto = i < photos.length;
              return GestureDetector(
                onTap: () {
                  if (hasPhoto) {
                    onRemove(photos[i]);
                  } else {
                    _pick(context, onAdd);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PDRadius.chip),
                  child: Container(
                    decoration: BoxDecoration(
                      color: PDColors.inputFill,
                      borderRadius: BorderRadius.circular(PDRadius.chip),
                      border: Border.all(color: PDColors.cardBorder),
                    ),
                    child: hasPhoto
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              photos[i].startsWith('assets/')
                                  ? Image.asset(
                                      photos[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image,
                                        color: PDColors.textMuted,
                                      ),
                                    )
                                  : Image.file(
                                      File(photos[i]),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image,
                                        color: PDColors.textMuted,
                                      ),
                                    ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined,
                                  color: PDColors.textMuted, size: 26),
                              const SizedBox(height: 4),
                              Text('Add', style: PDTextStyles.muted.copyWith(fontSize: 10)),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tags
// ─────────────────────────────────────────────────────────────────────────────
class _TagsSection extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<String> onToggle;

  const _TagsSection({required this.selectedTags, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tags', style: PDTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMemoryTags.map((tag) {
              final selected = selectedTags.contains(tag);
              return Semantics(
                label: '$tag memory tag',
                selected: selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onToggle(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected ? PDGradients.primary : null,
                      color: selected ? null : PDColors.inputFill,
                      borderRadius: BorderRadius.circular(PDRadius.chip),
                      border: Border.all(
                        color: selected ? Colors.transparent : PDColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : PDColors.textMuted,
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Memory note text area
// ─────────────────────────────────────────────────────────────────────────────
class _MemoryNoteField extends StatelessWidget {
  final String note;
  final ValueChanged<String> onChanged;

  const _MemoryNoteField({required this.note, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Memory Note', style: PDTextStyles.sectionTitle),
              Text(
                '${note.length}/200',
                style: PDTextStyles.muted.copyWith(
                  color: note.length > 180 ? PDColors.textAccent : PDColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: PDColors.inputFill,
              borderRadius: BorderRadius.circular(PDRadius.input),
              border: Border.all(color: PDColors.inputBorder),
            ),
            child: TextField(
              maxLength: 200,
              maxLines: 4,
              minLines: 3,
              style: PDTextStyles.body,
              onChanged: onChanged,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  const SizedBox.shrink(),
              decoration: const InputDecoration(
                hintText: 'Write a note about this date...',
                hintStyle: TextStyle(color: PDColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save memories button bar
// ─────────────────────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSave;

  const _SaveBar({required this.enabled, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [PDColors.bg.withValues(alpha: 0), PDColors.bg],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Semantics(
          label: 'Save to memories',
          button: true,
          enabled: enabled,
          child: GestureDetector(
            onTap: enabled ? onSave : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: enabled ? PDGradients.primary : null,
                color: enabled ? null : PDColors.disabledFill,
                borderRadius: BorderRadius.circular(PDRadius.control),
                boxShadow: enabled ? PDShadows.ctaGlow : null,
                border: enabled ? null : Border.all(color: PDColors.disabledBorder),
              ),
              alignment: Alignment.center,
              child: Text(
                'Save to memories',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : PDColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background glows
// ─────────────────────────────────────────────────────────────────────────────
class _BgGlows extends StatelessWidget {
  const _BgGlows();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              width: 280,
              height: 280,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [PDColors.glowViolet, Colors.transparent],
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

