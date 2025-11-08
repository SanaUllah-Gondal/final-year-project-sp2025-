import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class ChatScreen extends StatefulWidget {
  final String otherUserEmail;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    required this.otherUserEmail,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _showEmojiPicker = false;
  bool _isLoadingImage = false;
  String? _currentUserEmail;

  // User data state
  String? _otherUserName;
  String? _otherUserImage;
  String? _contactNumber;
  bool _isLoadingUserData = true;

  // Cache for user data
  static final Map<String, Map<String, dynamic>> _userDataCache = {};

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _auth.currentUser?.email;
    _loadUserData();
    _markMessagesAsRead();
    _setupChatDocument();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final userData = await _getUserData(widget.otherUserEmail);

      setState(() {
        _otherUserName = userData['fullName'] ??
            userData['name'] ??
            widget.otherUserName;
        _otherUserImage = userData['profileImage'] ??
            widget.otherUserImage;
        _contactNumber = userData['contactNumber'];
        _isLoadingUserData = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _otherUserName = widget.otherUserName;
        _otherUserImage = widget.otherUserImage;
        _isLoadingUserData = false;
      });
    }
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

  void _setupChatDocument() async {
    if (_currentUserEmail == null) return;

    // Use updated user data for chat document
    final otherUserName = _otherUserName ?? widget.otherUserName;
    final otherUserImage = _otherUserImage ?? widget.otherUserImage;

    // Create/update chat document for current user
    await _firestore
        .collection('messages')
        .doc(_currentUserEmail)
        .collection('chats')
        .doc(widget.otherUserEmail)
        .set({
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
      'lastMessage': '',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'unreadCount': 0,
      'isOnline': false,
    }, SetOptions(merge: true));

    // Create/update chat document for other user
    await _firestore
        .collection('messages')
        .doc(widget.otherUserEmail)
        .collection('chats')
        .doc(_currentUserEmail!)
        .set({
      'otherUserName': _auth.currentUser?.displayName ?? 'User',
      'otherUserImage': _auth.currentUser?.photoURL,
      'lastMessage': '',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'unreadCount': 0,
      'isOnline': false,
    }, SetOptions(merge: true));
  }

  void _markMessagesAsRead() async {
    if (_currentUserEmail == null) return;

    final messages = await _firestore
        .collection('messages')
        .doc(_currentUserEmail)
        .collection(widget.otherUserEmail)
        .where('isRead', isEqualTo: false)
        .where('sender', isEqualTo: widget.otherUserEmail)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }

    // Update unread count
    await _firestore
        .collection('messages')
        .doc(_currentUserEmail)
        .collection('chats')
        .doc(widget.otherUserEmail)
        .update({'unreadCount': 0});
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserEmail == null) {
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _showEmojiPicker = false;
    });

    // Send to current user's collection
    await _firestore
        .collection('messages')
        .doc(_currentUserEmail)
        .collection(widget.otherUserEmail)
        .add({
      'message': messageText,
      'sender': _currentUserEmail,
      'receiver': widget.otherUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': true,
      'type': 'text',
    });

    // Send to other user's collection
    await _firestore
        .collection('messages')
        .doc(widget.otherUserEmail)
        .collection(_currentUserEmail!)
        .add({
      'message': messageText,
      'sender': _currentUserEmail,
      'receiver': widget.otherUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'text',
    });

    // Update chat documents with latest user data
    final otherUserName = _otherUserName ?? widget.otherUserName;
    final otherUserImage = _otherUserImage ?? widget.otherUserImage;

    final updateData = {
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
      'lastMessage': messageText,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
    };

    await _firestore
        .collection('messages')
        .doc(_currentUserEmail)
        .collection('chats')
        .doc(widget.otherUserEmail)
        .update(updateData);

    await _firestore
        .collection('messages')
        .doc(widget.otherUserEmail)
        .collection('chats')
        .doc(_currentUserEmail!)
        .update({
      ...updateData,
      'unreadCount': FieldValue.increment(1),
    });

    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null || _currentUserEmail == null) return;

      setState(() {
        _isLoadingImage = true;
        _showEmojiPicker = false;
      });

      final bytes = await File(image.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Send image to current user's collection
      await _firestore
          .collection('messages')
          .doc(_currentUserEmail)
          .collection(widget.otherUserEmail)
          .add({
        'message': base64Image,
        'sender': _currentUserEmail,
        'receiver': widget.otherUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'image',
      });

      // Send image to other user's collection
      await _firestore
          .collection('messages')
          .doc(widget.otherUserEmail)
          .collection(_currentUserEmail!)
          .add({
        'message': base64Image,
        'sender': _currentUserEmail,
        'receiver': widget.otherUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'image',
      });

      // Update chat documents with latest user data
      final otherUserName = _otherUserName ?? widget.otherUserName;
      final otherUserImage = _otherUserImage ?? widget.otherUserImage;

      final updateData = {
        'otherUserName': otherUserName,
        'otherUserImage': otherUserImage,
        'lastMessage': '📷 Image',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('messages')
          .doc(_currentUserEmail)
          .collection('chats')
          .doc(widget.otherUserEmail)
          .update(updateData);

      await _firestore
          .collection('messages')
          .doc(widget.otherUserEmail)
          .collection('chats')
          .doc(_currentUserEmail!)
          .update({
        ...updateData,
        'unreadCount': FieldValue.increment(1),
      });

      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          if (_showEmojiPicker) {
            setState(() {
              _showEmojiPicker = false;
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            if (_showEmojiPicker) _buildEmojiPicker(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        alignment: Alignment.centerLeft,
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoadingUserData
                    ? Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
                    : Text(
                  _otherUserName ?? widget.otherUserName,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('messages')
                      .doc(widget.otherUserEmail)
                      .collection('chats')
                      .doc(_currentUserEmail)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final isOnline = snapshot.data?.get('isOnline') ?? false;
                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: AppTextStyles.caption.copyWith(
                        color: isOnline ? AppColors.successColor : AppColors.greyColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_contactNumber != null && _contactNumber!.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              _showContactOptions();
            },
          ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            // Implement video call functionality
          },
        ),
      ],
    );
  }

  void _showContactOptions() {
    if (_contactNumber == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${_otherUserName ?? widget.otherUserName}',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.phone, color: AppColors.primaryColor),
              title: Text('Call ${_contactNumber!}'),
              onTap: () {
                Get.back();
                _makePhoneCall(_contactNumber!);
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: AppColors.primaryColor),
              title: Text('Message ${_contactNumber!}'),
              onTap: () {
                Get.back();
                _sendSMS(_contactNumber!);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // Implement phone call functionality
    Get.snackbar(
      'Call',
      'Calling $phoneNumber',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _sendSMS(String phoneNumber) {
    // Implement SMS functionality
    Get.snackbar(
      'Message',
      'Opening messages for $phoneNumber',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildProfileAvatar() {
    final imageData = _otherUserImage ?? widget.otherUserImage;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: ClipOval(
        child: _isLoadingUserData
            ? Container(
          color: AppColors.lightGrey,
          child: Icon(
            Icons.person,
            color: AppColors.greyColor,
          ),
        )
            : imageData != null && imageData.isNotEmpty
            ? _buildImageWidget(imageData)
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildImageWidget(String imageData) {
    // Check if it's a base64 image
    if (imageData.startsWith('data:image/') || imageData.length > 100) {
      try {
        return Image.memory(
          _decodeBase64Image(imageData),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildFallbackAvatar();
      }
    }
    // Check if it's a URL
    else if (imageData.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageData,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.lightGrey,
          child: Icon(
            Icons.person,
            color: AppColors.greyColor,
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(),
      );
    }
    // Fallback
    else {
      return _buildFallbackAvatar();
    }
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

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_currentUserEmail == null) {
      return const Center(child: Text('Please sign in to view messages'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .doc(_currentUserEmail)
          .collection(widget.otherUserEmail)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingMessages();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyMessages();
        }

        final messages = snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            return _MessageBubble(
              message: message,
              isMe: message['sender'] == _currentUserEmail,
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingMessages() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${_otherUserName ?? widget.otherUserName}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: _showEmojiPicker ? AppColors.primaryColor : AppColors.greyColor,
            ),
            onPressed: () {
              setState(() {
                _showEmojiPicker = !_showEmojiPicker;
              });
            },
          ),

          // Image Button
          IconButton(
            icon: Icon(
              Icons.image_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: _isLoadingImage ? null : _sendImage,
          ),

          // Message Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
                maxLines: null,
                onChanged: (value) {
                  setState(() {});
                },
                onTap: () {
                  if (_showEmojiPicker) {
                    setState(() {
                      _showEmojiPicker = false;
                    });
                  }
                },
              ),
            ),
          ),

          // Send Button
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? AppColors.primaryColor
                  : AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isLoadingImage
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: _messageController.text.trim().isNotEmpty && !_isLoadingImage
                  ? _sendMessage
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 256,
      child: EmojiPicker(
        onEmojiSelected: (category, Emoji emoji) {
          _messageController.text = _messageController.text + emoji.emoji;
        },
        onBackspacePressed: () {
          if (_messageController.text.isNotEmpty) {
            _messageController.text = _messageController.text
                .substring(0, _messageController.text.length - 1);
          }
        },
        textEditingController: _messageController,
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS
                    ? 1.20
                    : 1.0),
          ),
          viewOrderConfig: const ViewOrderConfig(
            top: EmojiPickerItem.categoryBar,
            middle: EmojiPickerItem.emojiView,
            bottom: EmojiPickerItem.searchBar,
          ),
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(),
          bottomActionBarConfig: const BottomActionBarConfig(),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final messageText = message['message'] ?? '';
    final timestamp = message['timestamp'] != null
        ? (message['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final messageType = message['type'] ?? 'text';
    final isRead = message['isRead'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageType == 'image')
                    _buildImageMessage(messageText)
                  else
                    _buildTextMessage(messageText),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: isMe ? Colors.white70 : AppColors.greyColor,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: isRead ? Colors.white70 : Colors.white54,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildTextMessage(String messageText) {
    return Text(
      messageText,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isMe ? Colors.white : AppColors.darkColor,
      ),
    );
  }

  Widget _buildImageMessage(String base64Image) {
    try {
      if (base64Image.startsWith('data:image/')) {
        final base64Data = base64Image.split(',').last;
        final bytes = base64.decode(base64Data);

        return GestureDetector(
          onTap: () {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: AppColors.lightGrey,
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.greyColor,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error loading image: $e');
    }

    return Container(
      width: 200,
      height: 200,
      color: AppColors.lightGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.greyColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: AppTextStyles.caption.copyWith(color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }
}