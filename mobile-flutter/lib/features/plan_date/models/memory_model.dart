// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Memory Model
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';

@immutable
class Memory {
  final String dateId;
  final int rating; // 1–5
  final List<String> tags;
  final List<String> photoPaths; // local or uploaded URLs
  final String note;
  final bool sharedWithPartner;

  const Memory({
    required this.dateId,
    required this.rating,
    this.tags = const [],
    this.photoPaths = const [],
    this.note = '',
    this.sharedWithPartner = false,
  });

  Memory copyWith({
    String? dateId,
    int? rating,
    List<String>? tags,
    List<String>? photoPaths,
    String? note,
    bool? sharedWithPartner,
  }) =>
      Memory(
        dateId: dateId ?? this.dateId,
        rating: rating ?? this.rating,
        tags: tags ?? this.tags,
        photoPaths: photoPaths ?? this.photoPaths,
        note: note ?? this.note,
        sharedWithPartner: sharedWithPartner ?? this.sharedWithPartner,
      );
}

const List<String> kMemoryTags = [
  'Great conversation',
  'Lots of laughs',
  'Felt comfortable',
  'Great food',
  'Perfect spot',
  'Would repeat',
];

