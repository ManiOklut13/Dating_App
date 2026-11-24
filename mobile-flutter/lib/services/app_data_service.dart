import 'package:flutter/material.dart';

import '../data/chat_conversations.dart';
import '../models/chat_profile_models.dart';

class AppDataService extends ChangeNotifier {
  static final AppDataService instance = AppDataService._internal();
  AppDataService._internal();

  UserProfileModel _userProfile = const UserProfileModel(
    id: 'user-alex-me',
    name: 'Alex',
    age: 25,
    city: 'Hyderabad, India',
    bio:
        'Product designer obsessed with minimalist architecture, vintage mechanical keyboards, and finding the best filter coffee in Hyderabad. Always down for spontaneous sunset drives.',
    profession: 'Senior Product Designer',
    company: 'Aura Studio',
    education: 'B.Des in Visual Design, NID',
    isVerified: true,
    isOnline: true,
    coinBalance: 250,
    photos: [
      'assets/images/aditya.jpg',
      'assets/images/ananya.jpg',
      'assets/images/riya.jpg',
      'assets/images/rohit.jpg',
    ],
    interests: ['Music', 'Travel', 'Photography', 'Art', 'Fitness', 'Coffee'],
    personalPrompt: {
      'question': 'The key to my heart is...',
      'answer': 'A curated Spotify indie playlist and secret cafe spots',
    },
  );

  UserProfileModel get userProfile => _userProfile;

  void updateUserProfile(UserProfileModel updated) {
    _userProfile = updated;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(_userProfile.interests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }
    _userProfile = _userProfile.copyWith(interests: currentInterests);
    notifyListeners();
  }

  List<ChatConversationModel> _conversations =
      List<ChatConversationModel>.from(mockChatConversations);

  List<ChatConversationModel> get conversations => _conversations;

  void setConversations(List<ChatConversationModel> conversations) {
    _conversations = List<ChatConversationModel>.from(conversations);
    notifyListeners();
  }

  void markAsRead(String conversationId) {
    _conversations = _conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();
    notifyListeners();
  }

  void sendMessage(
    String conversationId,
    String text, {
    String type = 'text',
    String? mediaUrl,
  }) {
    if (text.trim().isEmpty && mediaUrl == null) return;

    final newMsg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      body: text.trim(),
      timestamp: 'Just now',
      isMe: true,
      type: type,
      mediaUrl: mediaUrl,
    );

    _conversations = _conversations.map((c) {
      if (c.id == conversationId) {
        final updatedMsgs = List<ChatMessageModel>.from(c.messages)..add(newMsg);
        return c.copyWith(
          messages: updatedMsgs,
          lastMessage: type == 'sticker'
              ? 'Sticker sent'
              : (type == 'image'
                  ? 'Photo sent'
                  : (type == 'date_plan'
                      ? 'Date Invitation sent'
                      : text.trim())),
          timestamp: 'Just now',
        );
      }
      return c;
    }).toList();
    notifyListeners();
  }
}
