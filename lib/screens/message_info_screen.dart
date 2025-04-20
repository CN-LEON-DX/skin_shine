import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class MessageInfoScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const MessageInfoScreen({
    Key? key,
    required this.chatId,
    required this.chatName,
  }) : super(key: key);

  @override
  _MessageInfoScreenState createState() => _MessageInfoScreenState();
}

class _MessageInfoScreenState extends State<MessageInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _mediaItems = [];
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _filteredMessages = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredMessages = _messages;
      });
      return;
    }

    setState(() {
      _filteredMessages = _messages
          .where((message) => message['content']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _generateMockData() {
    // Generate mock media items
    final types = ['image', 'document', 'video'];
    final random = math.Random();
    
    _mediaItems = List.generate(20, (index) {
      final type = types[random.nextInt(types.length)];
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      
      return {
        'id': 'media_$index',
        'type': type,
        'name': type == 'document' 
            ? 'Document ${index + 1}.pdf' 
            : 'Media ${index + 1}',
        'url': 'https://example.com/media/$index',
        'date': date,
        'thumbnail': 'assets/images/${type}_thumbnail.png',
        'size': '${random.nextInt(10) + 1} MB',
      };
    });

    // Generate mock messages
    final messageTypes = ['text', 'media', 'voice'];
    final senders = ['You', widget.chatName];
    
    _messages = List.generate(50, (index) {
      final sender = senders[random.nextInt(senders.length)];
      final type = messageTypes[random.nextInt(messageTypes.length)];
      final date = DateTime.now().subtract(Duration(
        days: random.nextInt(10), 
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      ));
      
      String content;
      if (type == 'text') {
        final messages = [
          'Hello, how are you?',
          'I\'m doing well, thanks for asking!',
          'Have you checked the latest skin treatment?',
          'Yes, it looks promising!',
          'Let\'s schedule a consultation next week.',
          'That works for me. How about Tuesday?',
          'Tuesday is perfect. See you then!',
          'Can you share some information about the procedure?',
          'Sure, I\'ll send you a document with details.',
          'Thanks, I appreciate it!',
        ];
        content = messages[random.nextInt(messages.length)];
      } else if (type == 'media') {
        content = '[Photo]';
      } else {
        content = '[Voice message: ${random.nextInt(2) + 1}:${random.nextInt(59).toString().padLeft(2, '0')} min]';
      }
      
      return {
        'id': 'msg_$index',
        'sender': sender,
        'type': type,
        'content': content,
        'date': date,
        'isRead': random.nextBool(),
      };
    });

    _messages.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    _filteredMessages = List.from(_messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                autofocus: true,
              )
            : Text(widget.chatName),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaTab(),
          _buildMessagesTab(),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaSection('Images', 'image'),
          _buildMediaSection('Videos', 'video'),
          _buildMediaSection('Documents', 'document'),
        ],
      ),
    );
  }

  Widget _buildMediaSection(String title, String type) {
    final filteredItems = _mediaItems.where((item) => item['type'] == type).toList();
    
    if (filteredItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          type == 'document' 
              ? _buildDocumentList(filteredItems)
              : _buildMediaGrid(filteredItems),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            // TODO: Implement media viewing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing ${item['name']}')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: item['type'] == 'video'
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/placeholder_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/placeholder_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(Icons.insert_drive_file, color: Colors.blue),
          title: Text(item['name']),
          subtitle: Text('${item['size']} • ${DateFormat('MMM d, yyyy').format(item['date'])}'),
          onTap: () {
            // TODO: Implement document viewing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening ${item['name']}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    if (_filteredMessages.isEmpty) {
      return Center(
        child: Text(
          _isSearching 
              ? 'No messages match your search'
              : 'No messages yet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredMessages.length,
      itemBuilder: (context, index) {
        final message = _filteredMessages[index];
        final isFromUser = message['sender'] == 'You';
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isFromUser ? Colors.blue : Colors.pink,
            child: Text(
              message['sender'].toString().substring(0, 1),
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            message['sender'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            message['content'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat('MMM d, h:mm a').format(message['date']),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          onTap: () {
            // TODO: Navigate to the specific message in chat
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Jumping to message')),
            );
          },
        );
      },
    );
  }
} 