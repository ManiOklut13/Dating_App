import 'package:flutter/foundation.dart';
import '../models/call_user.dart';

/// Singleton service that holds in-memory call history for the current session.
/// In a production app this would be backed by a local database (e.g. Hive/SQLite).
class CallHistoryService extends ChangeNotifier {
  CallHistoryService._();
  static final CallHistoryService instance = CallHistoryService._();

  final List<CallHistoryEntry> _history = _buildDemoHistory();

  List<CallHistoryEntry> get history => List.unmodifiable(_history);

  /// Record a completed demo call.  Avoids duplicate entries via [id].
  void addEntry(CallHistoryEntry entry) {
    // Deduplicate: do not insert if same id already exists
    if (_history.any((e) => e.id == entry.id)) return;
    _history.insert(0, entry); // newest first
    notifyListeners();
  }

  // ── pre-seed with a few historical demo entries ──────────────────────────
  static List<CallHistoryEntry> _buildDemoHistory() {
    final now = DateTime.now();
    return [
      CallHistoryEntry(
        id: 'hist-1',
        user: kDemoUsers[0], // Ananya
        type: CallType.video,
        direction: CallDirection.incoming,
        timestamp: now.subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 4, seconds: 12),
      ),
      CallHistoryEntry(
        id: 'hist-2',
        user: kDemoUsers[1], // Riya
        type: CallType.audio,
        direction: CallDirection.outgoing,
        timestamp: now.subtract(const Duration(hours: 5)),
        duration: const Duration(minutes: 1, seconds: 48),
      ),
      CallHistoryEntry(
        id: 'hist-3',
        user: kDemoUsers[2], // Meera
        type: CallType.audio,
        direction: CallDirection.missed,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        duration: Duration.zero,
      ),
    ];
  }
}
