import 'package:flutter/material.dart';

import '../../../models/chat_profile_models.dart';
import 'plan_date_model.dart';

/// A selectable date category shared by the carousel and the invite model.
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

  static const List<DateTypeOption> all = [
    movie,
    dinner,
    coffee,
    games,
    music,
    walk,
    artGallery,
  ];

  /// Returns the carousel options in the reference order for a given mode.
  static List<DateTypeOption> optionsFor(DateMode mode) {
    switch (mode) {
      case DateMode.virtual:
        return const [movie, games, coffee, dinner, music];
      case DateMode.offline:
        return const [dinner, coffee, walk, artGallery, movie];
    }
  }

  bool get isVirtual => modes.contains(DateMode.virtual);
  bool get isOffline => modes.contains(DateMode.offline);
}

/// The invite produced when the Plan a Date draft is confirmed.
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

  String get modeLabel =>
      mode == DateMode.virtual ? 'Virtual' : 'Offline';
}

/// Builds the default checklist for a mode/type combination.
List<TodoItem> defaultDateTodos(DateMode mode, DateTypeOption type) {
  final texts = <String>[];
  switch (type.id) {
    case 'movie-night':
      if (mode == DateMode.virtual) {
        texts.addAll(['Pick a movie', 'Order popcorn', 'Set up online game']);
      } else {
        texts.addAll(['Book tickets', 'Pick snacks', 'Check show timings']);
      }
      break;
    case 'games':
      texts.addAll(['Choose games', 'Test the connection', 'Share invite link']);
      break;
    case 'coffee':
      if (mode == DateMode.virtual) {
        texts.addAll(['Pick a brew', 'Set up video', 'Send a playlist']);
      } else {
        texts.addAll(['Pick a cafe', 'Check the menu', 'Bring a book']);
      }
      break;
    case 'dinner':
      if (mode == DateMode.virtual) {
        texts.addAll(['Pick a recipe', 'Shop ingredients', 'Set the table']);
      } else {
        texts.addAll(['Pick a restaurant', 'Book a table', 'Check dietary needs']);
      }
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
      TodoItem(
        id: '${type.id}-$mode-$i',
        text: texts[i],
        done: i == 0 && type.id == 'movie-night' && mode == DateMode.virtual,
      ),
  ];
}
