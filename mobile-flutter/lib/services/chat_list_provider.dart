import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_profile_models.dart';
import 'app_data_service.dart';

/// Watches the app chat store so every consumer shares one live chat list.
final chatListProvider =
    ChangeNotifierProvider<AppDataService>((ref) => AppDataService.instance);

/// The ordered chat conversations used by Messages and the Plan a Date chooser.
final chatConversationsProvider = Provider<List<ChatConversationModel>>((ref) {
  return ref.watch(chatListProvider).conversations;
});

/// Looks a single conversation up by its stable chat id.
final chatByIdProvider =
    Provider.family<ChatConversationModel?, String>((ref, chatId) {
  final chats = ref.watch(chatConversationsProvider);
  for (final chat in chats) {
    if (chat.id == chatId) return chat;
  }
  return null;
});
