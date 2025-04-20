import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'expert_profile_screen.dart';
import 'user_profile_screen.dart';

class Expert {
  final String id;
  final String name;
  final String avatar;
  final String title;
  final bool isOnline;

  Expert({
    required this.id,
    required this.name,
    required this.avatar,
    required this.title,
    this.isOnline = false,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSentByMe;
  final MessageType type;
  final String? mediaUrl;
  final String? mediaThumb;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSentByMe = false,
    this.type = MessageType.text,
    this.mediaUrl,
    this.mediaThumb,
  });
}

enum MessageType { text, image, video, document }

class ChatScreen extends StatefulWidget {
  final String? expertId;

  const ChatScreen({Key? key, this.expertId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<ChatMessage> _searchResults = [];
  bool _showMediaGallery = false;
  
  // Danh sách các chuyên gia mẫu
  final List<Expert> _experts = [
    Expert(
      id: 'e1',
      name: 'Dr. Sarah Williams',
      avatar: 'https://placehold.co/50x50/E0F7FA/000?text=SW',
      title: 'Dermatologist, MD',
      isOnline: true,
    ),
    Expert(
      id: 'e2',
      name: 'Dr. James Peterson',
      avatar: 'https://placehold.co/50x50/FFF9C4/000?text=JP',
      title: 'Cosmetic Dermatologist',
    ),
    Expert(
      id: 'e3',
      name: 'Dr. Lisa Thompson',
      avatar: 'https://placehold.co/50x50/F3E5F5/000?text=LT',
      title: 'Dermatologist Nurse',
      isOnline: true,
    ),
    Expert(
      id: 'e4',
      name: 'Dr. Robert Chen',
      avatar: 'https://placehold.co/50x50/E8F5E9/000?text=RC',
      title: 'Esthetician',
    ),
  ];
  
  // Các cuộc trò chuyện của người dùng
  Map<String, List<ChatMessage>> _chats = {};
  
  // Expert hiện tại đang trò chuyện
  Expert? _currentExpert;
  
  @override
  void initState() {
    super.initState();
    
    // Khởi tạo dữ liệu chat mẫu
    _initializeSampleChats();
    
    // Nếu có expertId được truyền vào, chọn expert đó
    if (widget.expertId != null) {
      _currentExpert = _experts.firstWhere(
        (expert) => expert.id == widget.expertId,
        orElse: () => _experts.first,
      );
    }
    
    // Cuộn xuống tin nhắn mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initializeSampleChats() {
    // Tạo các tin nhắn mẫu cho Dr. Sarah Williams
    _chats['e1'] = [
      ChatMessage(
        id: 'm1',
        senderId: 'e1',
        content: 'Hello! How can I help you with your skin concerns today?',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'user',
        content: 'Hi Dr. Williams, I\'ve been having some redness and irritation around my nose and cheeks.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 45)),
        isRead: true,
        isSentByMe: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'e1',
        content: 'I understand. Could you tell me a bit more about your current skincare routine?',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm4',
        senderId: 'user',
        content: 'I cleanse morning and night with a foaming cleanser, then use a vitamin C serum and moisturizer. At night I add retinol cream.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 15)),
        isRead: true,
        isSentByMe: true,
      ),
      ChatMessage(
        id: 'm5',
        senderId: 'e1',
        content: 'The irritation might be due to the combination of vitamin C and retinol, or your skin barrier might be compromised. I recommend simplifying your routine for a week - just use a gentle cleanser and moisturizer. Avoid the retinol and vitamin C temporarily.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm6',
        senderId: 'user',
        content: 'That makes sense, I\'ll try that. Should I add any soothing products?',
        timestamp: DateTime.now().subtract(Duration(days: 1, minutes: 45)),
        isRead: true,
        isSentByMe: true,
      ),
      ChatMessage(
        id: 'm7',
        senderId: 'e1',
        content: 'Yes, products with ceramides, centella asiatica or niacinamide would be helpful. Avoid any fragranced products as well.',
        timestamp: DateTime.now().subtract(Duration(hours: 12)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm8',
        senderId: 'user',
        content: 'Here\'s a photo of the redness I mentioned.',
        timestamp: DateTime.now().subtract(Duration(hours: 10)),
        isRead: true,
        isSentByMe: true,
        type: MessageType.image,
        mediaUrl: 'https://via.placeholder.com/500x500/ffcccc/000000?text=Skin+Photo',
        mediaThumb: 'https://via.placeholder.com/100x100/ffcccc/000000?text=Skin+Photo',
      ),
      ChatMessage(
        id: 'm9',
        senderId: 'e1',
        content: 'I can see the irritation. Thank you for sharing this. Based on the photo, I recommend using a gentle cleanser with ceramides.',
        timestamp: DateTime.now().subtract(Duration(hours: 9)),
        isRead: true,
        type: MessageType.text,
      ),
      ChatMessage(
        id: 'm10',
        senderId: 'e1',
        content: 'Here\'s a product recommendation',
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        isRead: true,
        type: MessageType.image,
        mediaUrl: 'https://via.placeholder.com/500x500/f0f8ff/000000?text=Product+Recommendation',
        mediaThumb: 'https://via.placeholder.com/100x100/f0f8ff/000000?text=Product+Recommendation',
      ),
    ];
    
    // Tạo các tin nhắn mẫu cho Dr. James Peterson
    _chats['e2'] = [
      ChatMessage(
        id: 'm1',
        senderId: 'e2',
        content: 'Welcome! I specialize in anti-aging treatments. How can I assist you?',
        timestamp: DateTime.now().subtract(Duration(days: 3)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'user',
        content: 'I\'m interested in learning more about peptides in skincare. Are they worth it?',
        timestamp: DateTime.now().subtract(Duration(days: 2)),
        isRead: true,
        isSentByMe: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'e2',
        content: 'Peptides are excellent for stimulating collagen production and can help with fine lines. They\'re gentler than retinoids but work gradually. They\'re definitely worth incorporating into an anti-aging routine!',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        isRead: false,
      ),
    ];
    
    // Chat trống cho các chuyên gia khác
    _chats['e3'] = [];
    _chats['e4'] = [];
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentExpert == null) return;
    
    final expertId = _currentExpert!.id;
    
    setState(() {
      _chats[expertId]!.add(
        ChatMessage(
          id: 'm${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user',
          content: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isSentByMe: true,
        ),
      );
      _messageController.clear();
    });
    
    // Tự động cuộn xuống tin nhắn mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Mô phỏng phản hồi từ chuyên gia sau 1-2 giây
    Future.delayed(Duration(seconds: 1 + (DateTime.now().millisecond % 2)), () {
      if (mounted) {
        setState(() {
          _chats[expertId]!.add(
            ChatMessage(
              id: 'm${DateTime.now().millisecondsSinceEpoch + 1}',
              senderId: expertId,
              content: 'Thanks for your message. I\'ll review and get back to you shortly.',
              timestamp: DateTime.now(),
            ),
          );
        });
        
        // Cuộn xuống tin nhắn mới nhất
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in conversation',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: _searchMessages,
              autofocus: true,
            ) 
          : Row(
              children: [
                if (_currentExpert != null)
                  GestureDetector(
                    onTap: () {
                      // Navigate to expert profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          ExpertProfileScreen(expertId: _currentExpert!.id)
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_currentExpert!.avatar),
                          radius: 16,
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentExpert!.name,
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              _currentExpert!.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                color: _currentExpert!.isOnline 
                                  ? Colors.green.shade400 
                                  : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResults = [];
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Media gallery
          if (_showMediaGallery)
            _buildMediaGallery(),
          
          // Search results
          if (_isSearching && _searchResults.isNotEmpty)
            _buildSearchResults(),
            
          // Chat messages
          if (!_isSearching || _searchResults.isEmpty)
            Expanded(
              child: _currentExpert == null
                ? Center(child: Text('Select a conversation to start chatting'))
                : _buildChatMessages(),
            ),
          
          // Message input
          if (_currentExpert != null)
            _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildMediaGallery() {
    final mediaMessages = _getMediaMessages();
    
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Media',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _showMediaGallery = false;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: mediaMessages.isEmpty
              ? Center(child: Text('No media shared in this conversation'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mediaMessages.length,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final message = mediaMessages[index];
                    return GestureDetector(
                      onTap: () {
                        _showFullMediaView(message);
                      },
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(message.mediaThumb ?? message.mediaUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: _searchResults.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final message = _searchResults[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  if (message.senderId == 'user') {
                    // Navigate to user profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        UserProfileScreen(userId: 'current-user-id', username: 'You')
                      ),
                    );
                  } else {
                    // Navigate to expert profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        ExpertProfileScreen(expertId: message.senderId)
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    message.senderId == 'user'
                      ? 'https://placehold.co/50x50/E1BEE7/000?text=ME'
                      : _experts.firstWhere((e) => e.id == message.senderId).avatar
                  ),
                  radius: 20,
                ),
              ),
              title: Text(
                message.senderId == 'user'
                  ? 'You'
                  : _experts.firstWhere((e) => e.id == message.senderId).name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Scroll to the message in chat
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  
                  // Find the index of the message in the chat
                  final expertId = _currentExpert!.id;
                  final chat = _chats[expertId]!;
                  final messageIndex = chat.indexWhere((m) => m.id == message.id);
                  
                  // Highlight the message
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && messageIndex >= 0) {
                      // Calculate position in the list
                      final itemPosition = messageIndex * 70.0; // Approximate height
                      _scrollController.animateTo(
                        itemPosition,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                });
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildChatMessages() {
    final expertId = _currentExpert!.id;
    final messages = _chats[expertId] ?? [];
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showAvatar = !message.isSentByMe;
        final isConsecutive = index > 0 && 
          messages[index - 1].senderId == message.senderId &&
          message.timestamp.difference(messages[index - 1].timestamp).inMinutes < 2;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: 8,
            top: isConsecutive ? 0 : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              if (showAvatar && !isConsecutive)
                GestureDetector(
                  onTap: () {
                    // Navigate to expert profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        ExpertProfileScreen(expertId: expertId)
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_currentExpert!.avatar),
                    radius: 16,
                  ),
                ),
              if (showAvatar && isConsecutive)
                SizedBox(width: 32),
              if (!showAvatar)
                GestureDetector(
                  onTap: () {
                    // Navigate to user profile when their avatar is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        UserProfileScreen(userId: 'current-user-id', username: 'You')
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('https://placehold.co/50x50/E1BEE7/000?text=ME'),
                    radius: 16,
                  ),
                ),
              
              SizedBox(width: 8),
              
              // Message content
              GestureDetector(
                onLongPress: () {
                  _showMessageOptions(message);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: message.type == MessageType.text
                    ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    : EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                      ? Colors.purple[100]
                      : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: message.type == MessageType.text
                    ? Text(message.content)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.content.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
                              child: Text(message.content),
                            ),
                          GestureDetector(
                            onTap: () {
                              _showFullMediaView(message);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                message.mediaUrl!,
                                height: 180,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[700]),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: 120,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.photo_library_outlined),
                          title: Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            // Here you would implement image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gallery picker would open here'))
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.camera_alt_outlined),
                          title: Text('Camera'),
                          onTap: () {
                            Navigator.pop(context);
                            // Here you would implement camera
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Camera would open here'))
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.purple),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
  
  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text('View Media & Files'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _showMediaGallery = true;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search in Conversation'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  if (_currentExpert != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        ExpertProfileScreen(expertId: _currentExpert!.id)
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('Copy Text'),
                onTap: () {
                  Navigator.pop(context);
                  // Here you would implement copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message copied to clipboard'))
                  );
                },
              ),
              if (message.type == MessageType.image)
                ListTile(
                  leading: Icon(Icons.save_alt_outlined),
                  title: Text('Save Image'),
                  onTap: () {
                    Navigator.pop(context);
                    // Here you would implement save image
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Image would be saved to gallery'))
                    );
                  },
                ),
              if (message.isSentByMe)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete Message', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    // Here you would implement delete message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message deleted'))
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _showFullMediaView(ChatMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                // Navigate to appropriate profile when clicking on name in media view
                Navigator.pop(context);
                if (message.senderId == 'user') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => 
                      UserProfileScreen(userId: 'current-user-id', username: 'You')
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => 
                      ExpertProfileScreen(expertId: message.senderId)
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      message.senderId == 'user' 
                        ? 'https://placehold.co/50x50/E1BEE7/000?text=ME'
                        : _experts.firstWhere((e) => e.id == message.senderId).avatar
                    ),
                    radius: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    message.senderId == 'user' 
                      ? 'You'
                      : _experts.firstWhere((e) => e.id == message.senderId).name
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_alt),
                onPressed: () {
                  // Save image logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image would be saved to gallery'))
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // Share image logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing options would open'))
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                message.mediaUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey[500], size: 100),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Search in messages
  void _searchMessages(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    final expertId = _currentExpert?.id;
    if (expertId == null) return;
    
    final messages = _chats[expertId] ?? [];
    final results = messages.where((message) => 
      message.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    setState(() {
      _searchResults = results;
    });
  }

  // Get all media messages from the current chat
  List<ChatMessage> _getMediaMessages() {
    final expertId = _currentExpert?.id;
    if (expertId == null) return [];
    
    final messages = _chats[expertId] ?? [];
    return messages.where((message) => 
      message.type == MessageType.image || message.type == MessageType.video
    ).toList();
  }
} 