import 'package:flutter/material.dart';

/// Represents a contact that can be called.
class CallUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final String city;

  const CallUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
    required this.city,
  });
}

/// Type of a completed call entry in history.
enum CallType { audio, video }

/// Direction of the call from the local user's perspective.
enum CallDirection { outgoing, incoming, missed }

/// A single entry in the call history log.
class CallHistoryEntry {
  final String id;
  final CallUser user;
  final CallType type;
  final CallDirection direction;
  final DateTime timestamp;
  final Duration duration;
  final bool isDemo; // demo vs real WebRTC call

  const CallHistoryEntry({
    required this.id,
    required this.user,
    required this.type,
    required this.direction,
    required this.timestamp,
    required this.duration,
    this.isDemo = true,
  });

  /// Human-readable duration string, e.g. "2:34".
  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Icon representing direction.
  IconData get directionIcon {
    switch (direction) {
      case CallDirection.outgoing:
        return Icons.call_made;
      case CallDirection.incoming:
        return Icons.call_received;
      case CallDirection.missed:
        return Icons.call_missed;
    }
  }

  /// Colour for direction icon.
  Color get directionColor {
    switch (direction) {
      case CallDirection.outgoing:
        return const Color(0xFF00E676);
      case CallDirection.incoming:
        return const Color(0xFF00E5FF);
      case CallDirection.missed:
        return const Color(0xFFFF4757);
    }
  }
}

/// Static demo roster — mirrors the web-app mock data users.
final List<CallUser> kDemoUsers = [
  const CallUser(
    id: '22222222-2222-2222-2222-222222222222',
    name: 'Ananya Sharma',
    avatarUrl: null, // local asset not bundled; avatar widget falls back to initials
    isVerified: true,
    city: 'Bandra, Mumbai',
  ),
  const CallUser(
    id: 'user-riya-2',
    name: 'Riya Sen',
    avatarUrl: null,
    isVerified: true,
    city: 'Hauz Khas, Delhi',
  ),
  const CallUser(
    id: 'user-meera-4',
    name: 'Meera Nair',
    avatarUrl: null,
    isVerified: false,
    city: 'Kochi, Kerala',
  ),
  const CallUser(
    id: 'user-aisha-5',
    name: 'Aisha Khan',
    avatarUrl: null,
    isVerified: true,
    city: 'Banjara Hills, Hyderabad',
  ),
  const CallUser(
    id: 'user-kabir-6',
    name: 'Kabir Kapoor',
    avatarUrl: null,
    isVerified: true,
    city: 'Colaba, Mumbai',
  ),
];
