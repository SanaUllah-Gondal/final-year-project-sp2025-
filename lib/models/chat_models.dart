import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  system
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String userType; // 'user', 'plumber', 'electrician', 'cleaner'
  final String? profileImage;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? contactNumber;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.profileImage,
    this.isOnline = false,
    this.lastSeen,
    this.contactNumber,
  });

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? 'user',
      profileImage: map['profileImage'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? (map['lastSeen'] as Timestamp).toDate() : null,
      contactNumber: map['contactNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'contactNumber': contactNumber,
    };
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? mediaData; // Base64 encoded media data
  final int? audioDuration;
  final String? fileExtension;
  final int? fileSize;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.mediaData,
    this.audioDuration,
    this.fileExtension,
    this.fileSize,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      type: _parseMessageType(map['type']),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      mediaData: map['mediaData'],
      audioDuration: map['audioDuration'],
      fileExtension: map['fileExtension'],
      fileSize: map['fileSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isRead': isRead,
      'mediaData': mediaData,
      'audioDuration': audioDuration,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
    };
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  // Helper method to get media URL for display
  String get mediaUrl {
    if (mediaData == null) return '';
    if (type == MessageType.image) {
      return 'data:image/$fileExtension;base64,$mediaData';
    } else if (type == MessageType.audio) {
      return 'data:audio/$fileExtension;base64,$mediaData';
    }
    return '';
  }
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatMessage? lastMessage;
  final String serviceType; // 'plumber', 'electrician', 'cleaner'

  ChatRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    required this.serviceType,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'] != null ? ChatMessage.fromMap(map['lastMessage']) : null,
      serviceType: map['serviceType'] ?? 'electrician',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessage': lastMessage?.toMap(),
      'serviceType': serviceType,
    };
  }
}