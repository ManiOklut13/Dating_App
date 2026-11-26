import 'package:flutter/material.dart';

import '../../models/chat_profile_models.dart';

/// Where the date happens: a video call or meeting in person.
enum DateMode { virtual, offline }

/// A single checklist entry for a planned date.
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
}

/// A selectable date category used by the type carousel.
@immutable
class DateTypeOption {
  final String id;
  final String label;
  final IconData icon;
  final Set<DateMode> modes;

  const DateTypeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.modes,
  });

  static const movie = DateTypeOption(
    id: 'movie-night',
    label: 'Movie Night',
    icon: Icons.movie_outlined,
    modes: {DateMode.virtual, DateMode.offline},
  );
  static const dinner = DateTypeOption(
    id: 'dinner',
    label: 'Dinner',
    icon: Icons.restaurant_outlined,
    modes: {DateMode.virtual, DateMode.offline},
  );
  static const coffee = DateTypeOption(
    id: 'coffee',
    label: 'Coffee',
    icon: Icons.local_cafe_outlined,
    modes: {DateMode.virtual, DateMode.offline},
  );
  static const games = DateTypeOption(
    id: 'games',
    label: 'Games',
    icon: Icons.sports_esports_outlined,
    modes: {DateMode.virtual},
  );
  static const music = DateTypeOption(
    id: 'music',
    label: 'Music',
    icon: Icons.music_note_outlined,
    modes: {DateMode.virtual},
  );
  static const walk = DateTypeOption(
    id: 'walk',
    label: 'Walk',
    icon: Icons.directions_walk_outlined,
    modes: {DateMode.offline},
  );
  static const artGallery = DateTypeOption(
    id: 'art-gallery',
    label: 'Art Gallery',
    icon: Icons.museum_outlined,
    modes: {DateMode.offline},
  );

  static const parkWalk = DateTypeOption(
    id: 'park-walk',
    label: 'Park Walk',
    icon: Icons.park_outlined,
    modes: {DateMode.offline},
  );
  static const dessert = DateTypeOption(
    id: 'dessert',
    label: 'Dessert',
    icon: Icons.cake_outlined,
    modes: {DateMode.offline},
  );

  /// Carousel entries shown for the active mode.
  static List<DateTypeOption> optionsFor(DateMode mode) {
    switch (mode) {
      case DateMode.virtual:
        return const [movie, games, coffee, dinner, music];
      case DateMode.offline:
        return const [movie, parkWalk, dessert, dinner, coffee, walk, artGallery];
    }
  }
}

/// The invitation produced when the planner is confirmed.
@immutable
class DateInvite {
  final String id;
  final ChatConversationModel partner;
  final DateMode mode;
  final DateTypeOption type;
  final DateTime dateTime;
  final int durationMinutes;
  final List<TodoItem> todos;
  final DateTime createdAt;

  const DateInvite({
    required this.id,
    required this.partner,
    required this.mode,
    required this.type,
    required this.dateTime,
    required this.durationMinutes,
    required this.todos,
    required this.createdAt,
  });

  String get modeLabel => mode == DateMode.virtual ? 'Virtual' : 'Offline';
}

/// Builds the default checklist for a mode/type combination.
List<TodoItem> defaultDateTodos(DateMode mode, DateTypeOption type) {
  final texts = <String>[];
  switch (type.id) {
    case 'movie-night':
      if (mode == DateMode.offline) {
        return const [
          TodoItem(id: 'todo-0', text: 'Book a table', done: false),
          TodoItem(id: 'todo-1', text: 'Choose a place', done: false),
          TodoItem(id: 'todo-2', text: 'Pick a movie', done: true),
          TodoItem(id: 'todo-3', text: 'Order popcorn', done: false),
        ];
      }
      texts.addAll(['Pick a movie', 'Order popcorn', 'Set up online game']);
      break;
    case 'games':
      texts.addAll(['Choose games', 'Test the connection', 'Share invite link']);
      break;
    case 'coffee':
      texts.addAll(
        mode == DateMode.virtual
            ? ['Pick a brew', 'Set up video', 'Send a playlist']
            : ['Pick a cafe', 'Check the menu', 'Bring a book'],
      );
      break;
    case 'dinner':
      texts.addAll(
        mode == DateMode.virtual
            ? ['Pick a recipe', 'Shop ingredients', 'Set the table']
            : ['Pick a restaurant', 'Book a table', 'Check dietary needs'],
      );
      break;
    case 'music':
      texts.addAll(['Make a playlist', 'Charge the speaker', 'Pick the setlist']);
      break;
    case 'walk':
      texts.addAll(['Check the weather', 'Pick a route', 'Wear comfy shoes']);
      break;
    case 'art-gallery':
      texts.addAll(['Check timings', 'Book tickets', 'Pick an outfit']);
      break;
    default:
      texts.addAll(['Pick the plan', 'Confirm details', 'Have fun']);
  }

  return [
    for (var i = 0; i < texts.length; i++)
      TodoItem(id: '${type.id}-$mode-$i', text: texts[i]),
  ];
}
