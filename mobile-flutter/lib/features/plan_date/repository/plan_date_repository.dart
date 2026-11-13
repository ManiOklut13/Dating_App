// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Repository Interface + Mock Implementation
// ─────────────────────────────────────────────────────────────────────────────
import '../models/plan_date_model.dart';
import '../models/memory_model.dart';

// ── App Config (coin cost, tile URL) ──────────────────────────────────────────
abstract final class PlanDateConfig {
  /// Coin cost to propose a date. Read from this constant (simulates remote config).
  static const int coinCost = 150;

  /// OSM tile URL template — swap to a production provider for high traffic.
  /// E.g. 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User-Agent header sent to Nominatim / Photon (required by their TOS).
  static const String nominatimUserAgent =
      'YoUnMeApp/3.2 (contact@younme.app)';

  /// Nominatim search endpoint.
  static const String nominatimUrl =
      'https://nominatim.openstreetmap.org/search';
}

// ── Abstract repository ────────────────────────────────────────────────────────
abstract class PlanDateRepository {
  Future<List<DateType>> getDateTypes(DateMode mode);
  Future<PlanDate> proposePlanDate(PlanDate plan);
  Future<Memory> saveMemory(Memory memory);
  Future<String> uploadPhoto(String localPath, void Function(double) onProgress);
}

// ── Mock implementation ────────────────────────────────────────────────────────
class MockPlanDateRepository implements PlanDateRepository {
  static final List<DateType> _virtualTypes = const [
    DateType(id: 'movie_night', label: 'Movie Night', emoji: '🎬', mode: DateMode.virtual),
    DateType(id: 'dinner',      label: 'Dinner',      emoji: '🍽️', mode: DateMode.virtual),
    DateType(id: 'coffee',      label: 'Coffee',      emoji: '☕', mode: DateMode.virtual),
    DateType(id: 'game_night',  label: 'Game Night',  emoji: '🎮', mode: DateMode.virtual),
    DateType(id: 'stargazing',  label: 'Stargazing',  emoji: '🌠', mode: DateMode.virtual),
    DateType(id: 'music_jam',   label: 'Music Jam',   emoji: '🎵', mode: DateMode.virtual),
    DateType(id: 'cook_together',label:'Cook Together',emoji: '👨‍🍳',mode: DateMode.virtual),
    DateType(id: 'park_walk_v', label: 'Park Walk',   emoji: '🌳', mode: DateMode.virtual),
    DateType(id: 'karaoke',     label: 'Karaoke',     emoji: '🎤', mode: DateMode.virtual),
    DateType(id: 'dessert_v',   label: 'Dessert',     emoji: '🍰', mode: DateMode.virtual),
    DateType(id: 'art_paint',   label: 'Art & Paint', emoji: '🎨', mode: DateMode.virtual),
    DateType(id: 'book_chat',   label: 'Book Chat',   emoji: '📚', mode: DateMode.virtual),
  ];

  static final List<DateType> _offlineTypes = const [
    DateType(id: 'dinner_o',    label: 'Dinner',      emoji: '🍽️', mode: DateMode.offline),
    DateType(id: 'coffee_o',    label: 'Coffee',      emoji: '☕', mode: DateMode.offline),
    DateType(id: 'movie_o',     label: 'Movie Night', emoji: '🎬', mode: DateMode.offline),
    DateType(id: 'park_walk_o', label: 'Park Walk',   emoji: '🌳', mode: DateMode.offline),
    DateType(id: 'dessert_o',   label: 'Dessert',     emoji: '🍰', mode: DateMode.offline),
    DateType(id: 'live_music',  label: 'Live Music',  emoji: '🎸', mode: DateMode.offline),
    DateType(id: 'bowling',     label: 'Bowling',     emoji: '🎳', mode: DateMode.offline),
    DateType(id: 'art_paint_o', label: 'Art & Paint', emoji: '🎨', mode: DateMode.offline),
    DateType(id: 'picnic',      label: 'Picnic',      emoji: '🧺', mode: DateMode.offline),
  ];

  @override
  Future<List<DateType>> getDateTypes(DateMode mode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return mode == DateMode.virtual ? _virtualTypes : _offlineTypes;
  }

  @override
  Future<PlanDate> proposePlanDate(PlanDate plan) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return plan.copyWith(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      status: DateStatus.proposed,
    );
  }

  @override
  Future<Memory> saveMemory(Memory memory) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return memory;
  }

  @override
  Future<String> uploadPhoto(String localPath, void Function(double) onProgress) async {
    // Simulate chunked upload with progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      onProgress(i / 10.0);
    }
    return 'https://cdn.younme.app/memories/${localPath.split('/').last}';
  }
}

