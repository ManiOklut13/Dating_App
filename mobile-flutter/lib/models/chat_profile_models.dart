class ChatMessageModel {
  final String id;
  final String senderId;
  final String body;
  final String timestamp;
  final bool isMe;
  final bool isRead;
  final String type; // 'text', 'image', 'sticker', 'date_plan'
  final String? mediaUrl;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.body,
    required this.timestamp,
    required this.isMe,
    this.isRead = true,
    this.type = 'text',
    this.mediaUrl,
  });
}

class ChatConversationModel {
  final String id;
  final String name;
  final String? avatarAsset;
  final String city;
  final int age;
  final String occupation;
  final String bio;
  final List<String> interests;
  final bool isVerified;
  final bool isOnline;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final List<ChatMessageModel> messages;

  const ChatConversationModel({
    required this.id,
    required this.name,
    this.avatarAsset,
    required this.city,
    required this.age,
    required this.occupation,
    required this.bio,
    required this.interests,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    required this.messages,
  });

  ChatConversationModel copyWith({
    int? unreadCount,
    List<ChatMessageModel>? messages,
    String? lastMessage,
    String? timestamp,
  }) {
    return ChatConversationModel(
      id: id,
      name: name,
      avatarAsset: avatarAsset,
      city: city,
      age: age,
      occupation: occupation,
      bio: bio,
      interests: interests,
      isVerified: isVerified,
      isOnline: isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final int age;
  final String city;
  final String bio;
  final String profession;
  final String company;
  final String education;
  final bool isVerified;
  final bool isOnline;
  final int coinBalance;
  final List<String> photos;
  final List<String> interests;
  final Map<String, String> personalPrompt;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.bio,
    required this.profession,
    required this.company,
    required this.education,
    this.isVerified = true,
    this.isOnline = true,
    this.coinBalance = 250,
    required this.photos,
    required this.interests,
    required this.personalPrompt,
  });

  UserProfileModel copyWith({
    String? name,
    int? age,
    String? city,
    String? bio,
    String? profession,
    String? company,
    String? education,
    bool? isVerified,
    int? coinBalance,
    List<String>? photos,
    List<String>? interests,
    Map<String, String>? personalPrompt,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      company: company ?? this.company,
      education: education ?? this.education,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline,
      coinBalance: coinBalance ?? this.coinBalance,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      personalPrompt: personalPrompt ?? this.personalPrompt,
    );
  }
}
