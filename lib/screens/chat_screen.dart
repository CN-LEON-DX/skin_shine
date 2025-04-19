import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSentByMe = false,
  });
}

class ChatScreen extends StatefulWidget {
  final String? expertId;

  const ChatScreen({Key? key, this.expertId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
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
        title: _currentExpert == null
            ? Text('Messages')
            : Row(
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
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _currentExpert!.isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _currentExpert!.isOnline ? Colors.green[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        centerTitle: _currentExpert == null,
        actions: [
          if (_currentExpert != null)
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Show expert info/profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_currentExpert!.name}\'s profile would show here')),
                );
              },
            ),
        ],
      ),
      body: _currentExpert == null
          ? _buildChatList()
          : Column(
              children: [
                Expanded(
                  child: _buildChatMessages(_currentExpert!.id),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }
  
  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: _experts.length,
      itemBuilder: (context, index) {
        final expert = _experts[index];
        final expertChats = _chats[expert.id] ?? [];
        final lastMessage = expertChats.isNotEmpty
            ? expertChats.last
            : null;
        final unreadCount = expertChats.where((msg) => !msg.isRead && !msg.isSentByMe).length;
        
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(expert.avatar),
                radius: 24,
              ),
              if (expert.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            expert.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: lastMessage != null
              ? Text(
                  lastMessage.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                    fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                )
              : Text(
                  expert.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lastMessage != null)
                Text(
                  _formatMessageTime(lastMessage.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              if (unreadCount > 0)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            setState(() {
              _currentExpert = expert;
            });
          },
        );
      },
    );
  }
  
  Widget _buildChatMessages(String expertId) {
    final messages = _chats[expertId] ?? [];
    
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with ${_currentExpert?.name.split(' ').first}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final showTimestamp = previousMessage == null ||
            !_isSameDay(message.timestamp, previousMessage.timestamp) ||
            message.timestamp.difference(previousMessage.timestamp).inHours > 1;
            
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTimestamp)
              _buildTimestampDivider(message.timestamp),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }
  
  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _formatMessageDate(timestamp),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isSentByMe = message.isSentByMe;
    final alignment = isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isSentByMe ? Colors.purple[100] : Colors.grey[100];
    final textColor = Colors.black87;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: isSentByMe ? 60 : 0,
        right: isSentByMe ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: isSentByMe ? Radius.circular(18) : Radius.circular(5),
                bottomRight: isSentByMe ? Radius.circular(5) : Radius.circular(18),
              ),
            ),
            child: Text(
              message.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatMessageTime(message.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              if (isSentByMe) ...[
                SizedBox(width: 5),
                Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 14,
                  color: message.isRead ? Colors.blue[300] : Colors.grey[400],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.grey[600]),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              // Image upload functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gallery option would open here')),
              );
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple[600],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  String _formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day of week
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime); // Month day, year
    }
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 