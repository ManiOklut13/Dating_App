import 'package:flutter/material.dart';
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

  List<ChatConversationModel> _conversations = const [
    ChatConversationModel(
      id: 'conv-ananya-1',
      name: 'Ananya Sharma',
      avatarAsset: 'assets/images/ananya.jpg',
      city: 'Bandra, Mumbai',
      age: 24,
      occupation: 'Visual Designer & Ceramicist',
      bio:
          'Analog photography, subko cold brews, and discovering secret jazz lounges. Indie cinema & vinyl records.',
      interests: ['Vinyl', 'Indie Rock', 'Coffee', 'Design', 'Ceramics'],
      isVerified: true,
      isOnline: true,
      lastMessage:
          'Subko Bandra at 6:30 PM sounds wonderful! Can not wait for the cinnamon toast',
      timestamp: '20m',
      unreadCount: 0,
      messages: [
        ChatMessageModel(
          id: 'msg-1',
          senderId: 'ananya',
          body: 'Hey Alex! Loved your profile photography shots. Are they 35mm?',
          timestamp: '6:15 PM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 'msg-2',
          senderId: 'me',
          body:
              'Thanks Ananya! Yes, shot on an old Olympus OM-1. Have you tried the new cafe in Bandra?',
          timestamp: '6:20 PM',
          isMe: true,
        ),
        ChatMessageModel(
          id: 'msg-3',
          senderId: 'ananya',
          body:
              'Subko Bandra at 6:30 PM sounds wonderful! Can not wait for the cinnamon toast',
          timestamp: '6:28 PM',
          isMe: false,
        ),
      ],
    ),
    ChatConversationModel(
      id: 'conv-riya-2',
      name: 'Riya Sen',
      avatarAsset: 'assets/images/riya.jpg',
      city: 'Hauz Khas, Delhi',
      age: 23,
      occupation: 'Electronic Music Producer',
      bio:
          'Late-night synths, rooftop gatherings, and searching for the city best matcha latte.',
      interests: ['Synthwave', 'DJing', 'Night Drives', 'Fashion', 'Art'],
      isVerified: true,
      isOnline: true,
      lastMessage:
          'Did you hear the new Fred again.. track? The vocal chops are insane!',
      timestamp: '5h',
      unreadCount: 2,
      messages: [
        ChatMessageModel(
          id: 'msg-r1',
          senderId: 'riya',
          body:
              'Did you hear the new Fred again.. track? The vocal chops are insane!',
          timestamp: '5:45 PM',
          isMe: false,
        ),
      ],
    ),
    ChatConversationModel(
      id: 'conv-meera-4',
      name: 'Meera Kapoor',
      avatarAsset: 'assets/images/riya.jpg',
      city: 'Colaba, Mumbai',
      age: 24,
      occupation: 'Art Curator & Writer',
      bio: 'Contemporary art galleries, espresso martinis, and old cinema classics.',
      interests: ['Art', 'Museums', 'Wine', 'Literature', 'Film'],
      isVerified: true,
      isOnline: true,
      lastMessage: 'Are we still on for the gallery exhibition tonight?',
      timestamp: '20h',
      unreadCount: 1,
      messages: [
        ChatMessageModel(
          id: 'msg-m1',
          senderId: 'meera',
          body:
              'Hey Alex! I managed to get two passes for the Jehangir Art Gallery opening.',
          timestamp: '4:30 PM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 'msg-m2',
          senderId: 'meera',
          body: 'Are we still on for the gallery exhibition tonight?',
          timestamp: '5:15 PM',
          isMe: false,
        ),
      ],
    ),
    ChatConversationModel(
      id: 'conv-rohit-3',
      name: 'Rohit Mehta',
      avatarAsset: 'assets/images/rohit.jpg',
      city: 'Indiranagar, Bengaluru',
      age: 26,
      occupation: 'AI Startup Founder & Runner',
      bio:
          'Building future tech by day, training for half-marathons by dawn.',
      interests: ['Running', 'Startups', 'Filter Coffee', 'Hiking', 'Sci-Fi'],
      isVerified: true,
      isOnline: false,
      lastMessage:
          'Sounds like a great plan. Let us hit Cubbon Park early Saturday morning!',
      timestamp: '1d',
      unreadCount: 0,
      messages: [
        ChatMessageModel(
          id: 'msg-ro1',
          senderId: 'rohit',
          body: 'Morning run this weekend?',
          timestamp: '9:00 AM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 'msg-ro2',
          senderId: 'me',
          body:
              'Sounds like a great plan. Let us hit Cubbon Park early Saturday morning!',
          timestamp: '9:15 AM',
          isMe: true,
        ),
      ],
    ),
  ];

  List<ChatConversationModel> get conversations => _conversations;

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
                  : (type == 'date_plan' ? 'Date Invitation sent' : text.trim())),
          timestamp: 'Just now',
        );
      }
      return c;
    }).toList();
    notifyListeners();
  }
}
