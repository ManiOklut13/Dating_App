// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Riverpod Providers
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plan_date_model.dart';
import '../models/memory_model.dart';
import '../repository/plan_date_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────────
final planDateRepositoryProvider = Provider<PlanDateRepository>(
  (_) => MockPlanDateRepository(),
);

// ── Date type list provider ────────────────────────────────────────────────────
final dateTypesProvider =
    FutureProvider.family<List<DateType>, DateMode>((ref, mode) async {
  final repo = ref.watch(planDateRepositoryProvider);
  return repo.getDateTypes(mode);
});

// ── Form state ────────────────────────────────────────────────────────────────
class PlanDateFormState {
  final DateMode mode;

  // Shared fields
  final String? partnerId;
  final String? partnerName;
  final bool isPartnerOnline;
  final String? partnerAvatar;
  final String? dateTypeId;
  final DateTime? selectedDate;
  final int selectedHour; // 1-12
  final int selectedMinute; // 0,15,30,45
  final bool isAm;
  final int durationMin;
  final List<TodoItem> todos;
  final int splitProposerPct;
  final bool todoEditMode;

  // Virtual-only
  final String proposalNote;
  final String partnerNote;

  // Offline-only
  final String? dressCode;
  final String dressNote;
  final String partnerDressNote;
  final DateSpot? meetupSpot;
  final bool dressCodeEditMode;

  // Submission state
  final bool isSubmitting;
  final String? submissionError;

  const PlanDateFormState({
    this.mode = DateMode.virtual,
    this.partnerId,
    this.partnerName,
    this.isPartnerOnline = true,
    this.partnerAvatar,
    this.dateTypeId,
    this.selectedDate,
    this.selectedHour = 7,
    this.selectedMinute = 30,
    this.isAm = false,
    this.durationMin = 60,
    this.todos = const [],
    this.splitProposerPct = 50,
    this.todoEditMode = false,
    this.proposalNote = '',
    this.partnerNote = '',
    this.dressCode,
    this.dressNote = '',
    this.partnerDressNote = '',
    this.meetupSpot,
    this.dressCodeEditMode = false,
    this.isSubmitting = false,
    this.submissionError,
  });

  PlanDateFormState copyWith({
    DateMode? mode,
    String? partnerId,
    String? partnerName,
    bool? isPartnerOnline,
    String? partnerAvatar,
    String? dateTypeId,
    DateTime? selectedDate,
    int? selectedHour,
    int? selectedMinute,
    bool? isAm,
    int? durationMin,
    List<TodoItem>? todos,
    int? splitProposerPct,
    bool? todoEditMode,
    String? proposalNote,
    String? partnerNote,
    String? dressCode,
    String? dressNote,
    String? partnerDressNote,
    DateSpot? meetupSpot,
    bool? dressCodeEditMode,
    bool? isSubmitting,
    String? submissionError,
    bool clearPartner = false,
    bool clearDateType = false,
    bool clearDate = false,
    bool clearMeetupSpot = false,
    bool clearDressCode = false,
    bool clearSubmissionError = false,
  }) {
    return PlanDateFormState(
      mode: mode ?? this.mode,
      partnerId: clearPartner ? null : (partnerId ?? this.partnerId),
      partnerName: clearPartner ? null : (partnerName ?? this.partnerName),
      isPartnerOnline: isPartnerOnline ?? this.isPartnerOnline,
      partnerAvatar: clearPartner ? null : (partnerAvatar ?? this.partnerAvatar),
      dateTypeId: clearDateType ? null : (dateTypeId ?? this.dateTypeId),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedHour: selectedHour ?? this.selectedHour,
      selectedMinute: selectedMinute ?? this.selectedMinute,
      isAm: isAm ?? this.isAm,
      durationMin: durationMin ?? this.durationMin,
      todos: todos ?? this.todos,
      splitProposerPct: splitProposerPct ?? this.splitProposerPct,
      todoEditMode: todoEditMode ?? this.todoEditMode,
      proposalNote: proposalNote ?? this.proposalNote,
      partnerNote: partnerNote ?? this.partnerNote,
      dressCode: clearDressCode ? null : (dressCode ?? this.dressCode),
      dressNote: dressNote ?? this.dressNote,
      partnerDressNote: partnerDressNote ?? this.partnerDressNote,
      meetupSpot: clearMeetupSpot ? null : (meetupSpot ?? this.meetupSpot),
      dressCodeEditMode: dressCodeEditMode ?? this.dressCodeEditMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError
          ? null
          : (submissionError ?? this.submissionError),
    );
  }

  bool get isCtaEnabled {
    if (partnerId == null || dateTypeId == null || selectedDate == null) {
      return false;
    }
    if (isSubmitting) return false;
    return startDateTime.isAfter(DateTime.now());
  }

  DateTime _resolveStartDateTime() {
    if (selectedDate == null) return DateTime(1970);
    final d = selectedDate!;
    int h = selectedHour;
    if (!isAm && h != 12) h += 12;
    if (isAm && h == 12) h = 0;
    return DateTime(d.year, d.month, d.day, h, selectedMinute);
  }

  DateTime get startDateTime => _resolveStartDateTime();
}

// ── PlanDate Form Notifier ────────────────────────────────────────────────────
class PlanDateFormNotifier extends StateNotifier<PlanDateFormState> {
  final PlanDateRepository _repo;
  int _todoCounter = 0;

  PlanDateFormNotifier(this._repo) : super(const PlanDateFormState());

  void setMode(DateMode mode) => state = state.copyWith(mode: mode);

  void setPartner({
    required String id,
    required String name,
    bool isOnline = true,
    String? avatar,
  }) {
    state = state.copyWith(
      partnerId: id,
      partnerName: name,
      isPartnerOnline: isOnline,
      partnerAvatar: avatar,
    );
  }

  void clearPartner() => state = state.copyWith(clearPartner: true);

  void setDateType(String id) => state = state.copyWith(dateTypeId: id);

  void setDate(DateTime date) =>
      state = state.copyWith(selectedDate: DateTime(date.year, date.month, date.day));

  void setHour(int h) => state = state.copyWith(selectedHour: h);
  void setMinute(int m) => state = state.copyWith(selectedMinute: m);
  void setAmPm(bool isAm) => state = state.copyWith(isAm: isAm);

  void incrementDuration() {
    final next = state.durationMin + 15;
    if (next <= 240) state = state.copyWith(durationMin: next);
  }

  void decrementDuration() {
    final next = state.durationMin - 15;
    if (next >= 15) state = state.copyWith(durationMin: next);
  }

  void setDuration(int min) => state = state.copyWith(durationMin: min.clamp(15, 240));

  void addTodo(String text) {
    if (text.trim().isEmpty) return;
    _todoCounter++;
    final updated = List<TodoItem>.from(state.todos)
      ..add(TodoItem(
        id: 'todo_${DateTime.now().microsecondsSinceEpoch}_$_todoCounter',
        text: text.trim(),
      ));
    state = state.copyWith(todos: updated);
  }

  void toggleTodo(String id) {
    final updated = state.todos
        .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList();
    state = state.copyWith(todos: updated);
  }

  void deleteTodo(String id) {
    state = state.copyWith(todos: state.todos.where((t) => t.id != id).toList());
  }

  void setTodoEditMode(bool v) => state = state.copyWith(todoEditMode: v);

  void setSplit(int proposerPct) =>
      state = state.copyWith(splitProposerPct: proposerPct.clamp(0, 100));

  void setProposalNote(String note) =>
      state = state.copyWith(proposalNote: note.length > 200 ? note.substring(0, 200) : note);

  void setPartnerNote(String note) =>
      state = state.copyWith(partnerNote: note.length > 200 ? note.substring(0, 200) : note);

  void setDressCode(String? code) =>
      state = state.copyWith(dressCode: code, clearDressCode: code == null);

  void setDressNote(String note) => state = state.copyWith(dressNote: note);
  void setPartnerDressNote(String note) => state = state.copyWith(partnerDressNote: note);
  void setDressCodeEditMode(bool v) => state = state.copyWith(dressCodeEditMode: v);

  void setMeetupSpot(DateSpot spot) => state = state.copyWith(meetupSpot: spot);
  void clearMeetupSpot() => state = state.copyWith(clearMeetupSpot: true);

  Future<PlanDate?> submit() async {
    if (!state.isCtaEnabled) return null;
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true);
    try {
      final plan = PlanDate(
        id: '',
        proposerId: 'me',
        partnerId: state.partnerId!,
        mode: state.mode,
        typeId: state.dateTypeId!,
        startAt: state.startDateTime,
        durationMin: state.durationMin,
        notes: DateNotes(proposal: state.proposalNote, partner: state.partnerNote),
        dressCode: state.dressCode,
        spot: state.meetupSpot,
        todos: state.todos,
        split: SplitBill(proposerPct: state.splitProposerPct),
        coins: PlanDateConfig.coinCost,
        status: DateStatus.proposed,
      );
      final result = await _repo.proposePlanDate(plan);
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submissionError: e.toString(),
      );
      return null;
    }
  }
}

final planDateFormProvider =
    StateNotifierProvider<PlanDateFormNotifier, PlanDateFormState>((ref) {
  return PlanDateFormNotifier(ref.watch(planDateRepositoryProvider));
});

// ── Place search (debounced) ──────────────────────────────────────────────────
class PlaceSearchNotifier extends StateNotifier<AsyncValue<List<DateSpot>>> {
  Timer? _debounce;

  PlaceSearchNotifier() : super(const AsyncValue.data([]));

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      state = const AsyncValue.data([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _doSearch(query));
  }

  Future<void> _doSearch(String query) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      state = AsyncValue.data([
        DateSpot(
          name: '$query Central Park',
          lat: 19.076 + query.length * 0.001,
          lng: 72.877 + query.length * 0.001,
          address: '123 Example St, Mumbai',
          kind: 'Park',
          distanceKm: 1.2,
        ),
        DateSpot(
          name: '$query Cafe Bloom',
          lat: 19.080 + query.length * 0.001,
          lng: 72.881 + query.length * 0.001,
          address: '45 Café Lane, Bandra',
          kind: 'Café',
          distanceKm: 2.7,
        ),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final placeSearchProvider =
    StateNotifierProvider<PlaceSearchNotifier, AsyncValue<List<DateSpot>>>(
  (_) => PlaceSearchNotifier(),
);

// ── Memory form ───────────────────────────────────────────────────────────────
class MemoryFormNotifier extends StateNotifier<Memory> {
  final PlanDateRepository _repo;

  MemoryFormNotifier(this._repo, String dateId)
      : super(Memory(dateId: dateId, rating: 0));

  void setRating(int r) => state = state.copyWith(rating: r);

  void toggleTag(String tag) {
    final current = List<String>.from(state.tags);
    current.contains(tag) ? current.remove(tag) : current.add(tag);
    state = state.copyWith(tags: current);
  }

  void addPhoto(String path) {
    if (state.photoPaths.length >= 6) return;
    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
  }

  void removePhoto(String path) {
    state = state.copyWith(
        photoPaths: state.photoPaths.where((p) => p != path).toList());
  }

  void setNote(String note) =>
      state = state.copyWith(note: note.length > 200 ? note.substring(0, 200) : note);

  void setSharedWithPartner(bool v) => state = state.copyWith(sharedWithPartner: v);

  Future<Memory?> save() async {
    try {
      return await _repo.saveMemory(state);
    } catch (_) {
      return null;
    }
  }
}

final memoryFormProvider =
    StateNotifierProvider.family<MemoryFormNotifier, Memory, String>(
  (ref, dateId) =>
      MemoryFormNotifier(ref.watch(planDateRepositoryProvider), dateId),
);
