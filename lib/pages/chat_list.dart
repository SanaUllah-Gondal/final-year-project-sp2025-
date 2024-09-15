import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  // Cache for user/provider data
  final Map<String, Map<String, dynamic>> _userDataCache = {};

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTextStyles.heading6.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: currentUserEmail == null
          ? _buildNoUserWidget()
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .doc(currentUserEmail)
            .collection('chats')
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyChatsWidget();
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserData(chats[index].id),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildChatListItem(
                      chatData: chatData,
                      chatId: chats[index].id,
                      currentUserEmail: currentUserEmail,
                      otherUserName: chatData['otherUserName'] ?? 'Unknown User',
                      profileImage: chatData['otherUserImage'],
                      isLoading: true,
                    );
                  }

                  final userData = userSnapshot.data ?? {};
                  final otherUserName = userData['fullName'] ??
                      userData['name'] ??
                      chatData['otherUserName'] ??
                      'Unknown User';
                  final profileImage = userData['profileImage'] ??
                      chatData['otherUserImage'];
                  final contactNumber = userData['contactNumber'] ?? 'Not available';

                  return _buildChatListItem(
                    chatData: chatData,
                    chatId: chats[index].id,
                    currentUserEmail: currentUserEmail,
                    otherUserName: otherUserName,
                    profileImage: profileImage,
                    contactNumber: contactNumber,
                    isLoading: false,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData(String email) async {
    // Check cache first
    if (_userDataCache.containsKey(email)) {
      return _userDataCache[email]!;
    }

    try {
      // Define collections to search
      final collections = ['cleaner', 'electrician', 'plumber', 'user'];

      for (final collection in collections) {
        final querySnapshot = await _firestore
            .collection(collection)
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();

          // Cache the data
          _userDataCache[email] = userData;

          return userData;
        }
      }

      // If no user found, return empty map
      return {};
    } catch (e) {
      print('Error fetching user data for $email: $e');
      return {};
    }
  }

  Widget _buildChatListItem({
    required Map<String, dynamic> chatData,
    required String chatId,
    required String currentUserEmail,
    required String otherUserName,
    required String? profileImage,
    String? contactNumber,
    bool isLoading = false,
  }) {
    final lastMessage = chatData['lastMessage'] ?? '';
    final lastMessageTime = chatData['lastMessageTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(chatData['lastMessageTime'])
        : DateTime.now();
    final unreadCount = chatData['unreadCount'] ?? 0;
    final isOnline = chatData['isOnline'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(
                  () => ChatScreen(
                otherUserEmail: chatId,
                otherUserName: otherUserName,
                otherUserImage: profileImage,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar with Online Status
                Stack(
                  children: [
                    _buildProfileAvatar(profileImage, otherUserName, isLoading),
                    if (isOnline && !isLoading)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.successColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: isLoading
                                ? Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                                : Text(
                              otherUserName,
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatMessageTime(lastMessageTime),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      isLoading
                          ? Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                          : Text(
                        _getLastMessagePreview(lastMessage),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.greyColor,
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (contactNumber != null && contactNumber != 'Not available' && !isLoading) ...[
                        const SizedBox(height: 4),
                        Text(
                          contactNumber,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.greyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Unread Count Badge
                if (unreadCount > 0 && !isLoading) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? imageData, String userName, bool isLoading) {
    if (isLoading) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
      );
    }

    if (imageData != null && imageData.isNotEmpty) {
      // Check if it's a base64 image
      if (imageData.startsWith('data:image/') || imageData.length > 100) {
        try {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.lightGrey,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.memory(
                _decodeBase64Image(imageData),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(userName),
              ),
            ),
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
          return _buildFallbackAvatar(userName);
        }
      }
      // Check if it's a URL
      else if (imageData.startsWith('http')) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageData,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.lightGrey,
                child: Icon(
                  Icons.person,
                  color: AppColors.greyColor,
                ),
              ),
              errorWidget: (context, url, error) => _buildFallbackAvatar(userName),
            ),
          ),
        );
      }
    }

    return _buildFallbackAvatar(userName);
  }

  Uint8List _decodeBase64Image(String base64String) {
    try {
      if (base64String.startsWith('data:image/')) {
        final base64Data = base64String.split(',').last;
        return base64.decode(base64Data);
      } else {
        return base64.decode(base64String);
      }
    } catch (e) {
      throw Exception('Invalid base64 image');
    }
  }

  Widget _buildFallbackAvatar(String userName) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.primaryColor,
        size: 24,
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  String _getLastMessagePreview(String message) {
    if (message.startsWith('data:image/')) {
      return '📷 Image';
    } else if (message.startsWith('EMOJI:')) {
      return '😊 Emoji';
    } else if (message.isEmpty) {
      return 'Start a conversation';
    } else {
      return message;
    }
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.greyColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Please sign in to view messages',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyChatsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.heading6.copyWith(color: AppColors.greyColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your service providers',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}