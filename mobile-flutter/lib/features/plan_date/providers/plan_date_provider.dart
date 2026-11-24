import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_profile_models.dart';
import '../../../services/chat_list_provider.dart';
import '../models/date_invite.dart';
import '../models/plan_date_model.dart';

/// Holds a single Plan a Date draft shared by every planner widget.
@immutable
class PlanDateDraft {
  final ChatConversationModel? partner;
  final DateMode mode;
  final DateTypeOption type;
  final DateTime dateTime;
  final int durationMinutes;
  final List<TodoItem> todos;
  final bool todosEdited;
  final bool todoEditMode;
  final bool isSubmitting;

  const PlanDateDraft({
    this.partner,
    this.mode = DateMode.virtual,
    this.type = DateTypeOption.movie,
    required this.dateTime,
    this.durationMinutes = 60,
    this.todos = const [],
    this.todosEdited = false,
    this.todoEditMode = false,
    this.isSubmitting = false,
  });

  PlanDateDraft copyWith({
    ChatConversationModel? partner,
    DateMode? mode,
    DateTypeOption? type,
    DateTime? dateTime,
    int? durationMinutes,
    List<TodoItem>? todos,
    bool? todosEdited,
    bool? todoEditMode,
    bool? isSubmitting,
  }) {
    return PlanDateDraft(
      partner: partner ?? this.partner,
      mode: mode ?? this.mode,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      todos: todos ?? this.todos,
      todosEdited: todosEdited ?? this.todosEdited,
      todoEditMode: todoEditMode ?? this.todoEditMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  int get doneCount => todos.where((todo) => todo.done).length;

  String get todoProgress => '$doneCount of ${todos.length} done';

  String get summary {
    final formatted = DateFormat('EEE, d MMM · h:mm a').format(dateTime);
    final modeLabel = mode == DateMode.virtual ? 'Virtual' : 'Offline';
    return '$formatted · $durationMinutes min · $modeLabel';
  }

  bool get canSend => partner != null && dateTime.isAfter(DateTime.now());
}

/// Riverpod notifier for the active Plan a Date draft.
class PlanDateNotifier extends FamilyNotifier<PlanDateDraft, String> {
  @override
  PlanDateDraft build(String chatId) {
    return _draftFor(chatId);
  }

  PlanDateDraft _draftFor(String id) {
    final chats = ref.read(chatConversationsProvider);
    ChatConversationModel? partner;
    for (final chat in chats) {
      if (chat.id == id) {
        partner = chat;
        break;
      }
    }
    partner ??= chats.isNotEmpty ? chats.first : null;

    final type = DateTypeOption.movie;
    return PlanDateDraft(
      partner: partner,
      mode: DateMode.virtual,
      type: type,
      dateTime: _validTime(DateTime.now()),
      todos: defaultDateTodos(DateMode.virtual, type),
    );
  }

  void reset() => state = _draftFor(arg);

  static DateTime _validTime(DateTime input) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (input.isBefore(today)) {
      return _validTime(DateTime(today.year, today.month, today.day, 19, 30));
    }
    if (input.isAfter(now)) return input;

    final soon = now.add(const Duration(minutes: 1));
    final roundedMinute = ((soon.minute + 4) ~/ 5) * 5;
    final adjusted = soon.add(Duration(minutes: roundedMinute - soon.minute));
    return DateTime(
      adjusted.year,
      adjusted.month,
      adjusted.day,
      adjusted.hour,
      adjusted.minute,
    );
  }

  void setPartner(ChatConversationModel partner) {
    state = state.copyWith(partner: partner);
  }

  void setMode(DateMode mode) {
    var type = state.type;
    if (!type.modes.contains(mode)) {
      type = DateTypeOption.optionsFor(mode).first;
    }
    state = state.copyWith(
      mode: mode,
      type: type,
      todos: state.todosEdited ? state.todos : defaultDateTodos(mode, type),
    );
  }

  void setType(DateTypeOption type) {
    state = state.copyWith(
      type: type,
      todos: state.todosEdited ? state.todos : defaultDateTodos(state.mode, type),
    );
  }

  void setDateTime(DateTime dateTime) {
    state = state.copyWith(dateTime: _validTime(dateTime));
  }

  void setDate(DateTime day) {
    final current = state.dateTime;
    setDateTime(
      DateTime(day.year, day.month, day.day, current.hour, current.minute),
    );
  }

  void jumpToToday() {
    final now = DateTime.now();
    setDateTime(DateTime(now.year, now.month, now.day, now.hour, now.minute));
  }

  void stepHour(int amount) {
    setDateTime(state.dateTime.add(Duration(hours: amount)));
  }

  void stepMinute(int amount) {
    setDateTime(state.dateTime.add(Duration(minutes: amount * 5)));
  }

  void toggleAmPm() {
    setDateTime(state.dateTime.add(const Duration(hours: 12)));
  }

  void setDuration(int minutes) {
    state = state.copyWith(durationMinutes: minutes.clamp(15, 480));
  }

  void stepDuration(int amount) {
    setDuration(state.durationMinutes + amount * 15);
  }

  void setTodoEditMode(bool enabled) {
    state = state.copyWith(todoEditMode: enabled);
  }

  void toggleTodo(String id) {
    state = state.copyWith(
      todos: state.todos
          .map((todo) =>
              todo.id == id ? todo.copyWith(done: !todo.done) : todo)
          .toList(),
      todosEdited: true,
    );
  }

  void addTodo(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final todo = TodoItem(
      id: 'todo-${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
    );
    state = state.copyWith(
      todos: [...state.todos, todo],
      todosEdited: true,
    );
  }

  void deleteTodo(String id) {
    state = state.copyWith(
      todos: state.todos.where((todo) => todo.id != id).toList(),
      todosEdited: true,
    );
  }

  void reorderTodo(int oldIndex, int newIndex) {
    final todos = List<TodoItem>.from(state.todos);
    if (oldIndex < 0 || oldIndex >= todos.length) return;
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (target < 0 || target >= todos.length) return;
    final moved = todos.removeAt(oldIndex);
    todos.insert(target, moved);
    state = state.copyWith(todos: todos, todosEdited: true);
  }

  DateInvite? buildInvite() {
    final draft = state;
    if (!draft.canSend || draft.partner == null) return null;
    final now = DateTime.now();
    return DateInvite(
      id: 'invite-${now.microsecondsSinceEpoch}',
      partner: draft.partner!,
      mode: draft.mode,
      type: draft.type,
      dateTime: draft.dateTime,
      durationMinutes: draft.durationMinutes,
      todos: List<TodoItem>.from(draft.todos),
      createdAt: now,
    );
  }
}

/// The active draft, keyed by the chat id chosen in the chooser.
final planDateProvider =
    NotifierProvider.family<PlanDateNotifier, PlanDateDraft, String>(
  PlanDateNotifier.new,
);

/// Sent date invites, shared with the Requests tab counters.
final dateInvitesProvider =
    NotifierProvider<DateInvitesNotifier, List<DateInvite>>(
  DateInvitesNotifier.new,
);

/// Stores sent invites for the current session.
class DateInvitesNotifier extends Notifier<List<DateInvite>> {
  @override
  List<DateInvite> build() => const [];

  void add(DateInvite invite) => state = [...state, invite];
}
