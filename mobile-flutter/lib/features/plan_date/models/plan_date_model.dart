// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Data Models
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';

// ── Date Mode ─────────────────────────────────────────────────────────────────
enum DateMode { virtual, offline }

// ── Date Status ───────────────────────────────────────────────────────────────
enum DateStatus { proposed, accepted, declined, completed }

// ── Todo Item ─────────────────────────────────────────────────────────────────
@immutable
class TodoItem {
  final String id;
  final String text;
  final bool done;

  const TodoItem({required this.id, required this.text, this.done = false});

  TodoItem copyWith({String? id, String? text, bool? done}) => TodoItem(
        id: id ?? this.id,
        text: text ?? this.text,
        done: done ?? this.done,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TodoItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── Meetup Spot ───────────────────────────────────────────────────────────────
@immutable
class DateSpot {
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String? kind;
  final double? distanceKm;

  const DateSpot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    this.kind,
    this.distanceKm,
  });
}

// ── Split Bill ────────────────────────────────────────────────────────────────
@immutable
class SplitBill {
  /// Proposer's share in percent (0–100). Partner = 100 - proposerPct.
  final int proposerPct;

  const SplitBill({this.proposerPct = 50});

  int get partnerPct => 100 - proposerPct;

  static const presets = [
    SplitBill(proposerPct: 50),
    SplitBill(proposerPct: 70),
    SplitBill(proposerPct: 30),
    SplitBill(proposerPct: 100),
  ];

  static const List<String> presetLabels = ['50/50', '70/30', '30/70', 'I pay all'];
}

// ── Date Notes ────────────────────────────────────────────────────────────────
@immutable
class DateNotes {
  final String proposal;
  final String partner;

  const DateNotes({this.proposal = '', this.partner = ''});

  DateNotes copyWith({String? proposal, String? partner}) => DateNotes(
        proposal: proposal ?? this.proposal,
        partner: partner ?? this.partner,
      );
}

// ── Date Type ─────────────────────────────────────────────────────────────────
@immutable
class DateType {
  final String id;
  final String label;
  final String emoji;
  final DateMode mode;

  const DateType({
    required this.id,
    required this.label,
    required this.emoji,
    required this.mode,
  });
}

// ── PlanDate (the core domain object) ────────────────────────────────────────
@immutable
class PlanDate {
  final String id;
  final String proposerId;
  final String partnerId;
  final DateMode mode;
  final String typeId;
  final DateTime startAt;
  final int durationMin;
  final DateNotes notes;
  final String? dressCode;
  final DateSpot? spot;
  final List<TodoItem> todos;
  final SplitBill split;
  final int coins;
  final DateStatus status;

  const PlanDate({
    required this.id,
    required this.proposerId,
    required this.partnerId,
    required this.mode,
    required this.typeId,
    required this.startAt,
    required this.durationMin,
    required this.notes,
    this.dressCode,
    this.spot,
    required this.todos,
    required this.split,
    required this.coins,
    required this.status,
  });

  PlanDate copyWith({
    String? id,
    String? proposerId,
    String? partnerId,
    DateMode? mode,
    String? typeId,
    DateTime? startAt,
    int? durationMin,
    DateNotes? notes,
    String? dressCode,
    DateSpot? spot,
    List<TodoItem>? todos,
    SplitBill? split,
    int? coins,
    DateStatus? status,
  }) =>
      PlanDate(
        id: id ?? this.id,
        proposerId: proposerId ?? this.proposerId,
        partnerId: partnerId ?? this.partnerId,
        mode: mode ?? this.mode,
        typeId: typeId ?? this.typeId,
        startAt: startAt ?? this.startAt,
        durationMin: durationMin ?? this.durationMin,
        notes: notes ?? this.notes,
        dressCode: dressCode ?? this.dressCode,
        spot: spot ?? this.spot,
        todos: todos ?? this.todos,
        split: split ?? this.split,
        coins: coins ?? this.coins,
        status: status ?? this.status,
      );
}

