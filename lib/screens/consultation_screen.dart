import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'expert_profile_screen.dart';
import 'chat_screen.dart';

// Enum để xác định loại bài đăng
enum PostType { userQuestion, expertAdvice, beforeAfter }

// Model cho bài đăng
class ConsultationPost {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final List<String> images;
  final PostType type;
  final bool isExpert;
  final String? expertTitle;
  int likes;
  int comments;
  int shares;
  List<String> hashtags;
  bool isLiked;
  bool showComments = false;
  List<Comment> commentsList = [];

  ConsultationPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.images = const [],
    required this.type,
    this.isExpert = false,
    this.expertTitle,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.hashtags = const [],
    this.isLiked = false,
  });
}

// Model cho comment
class Comment {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final bool isExpert;
  final String? expertTitle;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.isExpert = false,
    this.expertTitle,
    this.likes = 0,
    this.isLiked = false,
  });
}

// Model cho chuyên gia
class Expert {
  final String id;
  final String name;
  final String avatar;
  final String title;
  final bool isOnline;
  final int followers;

  Expert({
    required this.id,
    required this.name,
    required this.avatar,
    required this.title,
    this.isOnline = false,
    this.followers = 0,
  });
}

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({Key? key}) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingExpanded = false;
  bool _isSearching = false;
  
  // Danh sách bài đăng mẫu
  final List<ConsultationPost> _posts = [
    ConsultationPost(
      id: 'p1',
      userName: 'Phượt Luân',
      userAvatar: 'assets/avatars/avatar1.png',
      content: 'Hành trình 8 năm đầy ý nghĩa!!!\nChân chất, đĩnh đạc, nội dung ý nghĩa, giọng nói ngọt như mía lùi và về ngoại diện trải là những yếu tố tạo nên một Khoai Lang Thang tuyệt vời!',
      timestamp: DateTime.now().subtract(Duration(hours: 17)),
      type: PostType.beforeAfter,
      images: ['assets/images/before.jpg', 'assets/images/after.jpg'],
      likes: 324,
      comments: 120,
      shares: 44,
      hashtags: ['Phuotluon'],
    ),
    ConsultationPost(
      id: 'p2',
      userName: 'Dr. Sarah Williams',
      userAvatar: 'assets/avatars/avatar2.png',
      content: 'Tips for dealing with maskne: 1. Use a gentle cleanser 2. Apply oil-free moisturizer 3. Take mask breaks when possible 4. Wash your mask regularly',
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      type: PostType.expertAdvice,
      isExpert: true,
      expertTitle: 'Dermatologist, MD',
      likes: 45,
      comments: 7,
      shares: 3,
    ),
    ConsultationPost(
      id: 'p3',
      userName: 'Michael Chen',
      userAvatar: 'assets/avatars/avatar3.png',
      content: 'Hành trình 8 tuần sử dụng retinol của tôi. Giai đoạn purging thực sự khó khăn, nhưng kết quả thật xứng đáng!',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      type: PostType.beforeAfter,
      images: [
        'assets/images/skin_before.jpg',
        'assets/images/skin_after.jpg'
      ],
      likes: 126,
      comments: 32,
      shares: 11,
      hashtags: ['retinol', 'skincare', 'beforeafter'],
    ),
    ConsultationPost(
      id: 'p4',
      userName: 'Dr. James Peterson',
      userAvatar: 'assets/avatars/avatar4.png',
      content: 'Hiểu về hàng rào bảo vệ da: Hàng rào bảo vệ da là tuyến phòng thủ đầu tiên của cơ thể chống lại các tác nhân môi trường. Khi bị tổn thương, bạn có thể gặp tình trạng khô da, kích ứng và nhạy cảm tăng cao. Hãy tập trung vào các sản phẩm nhẹ nhàng với ceramides, axit béo và axit hyaluronic để phục hồi và duy trì hàng rào bảo vệ khỏe mạnh.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      type: PostType.expertAdvice,
      isExpert: true,
      expertTitle: 'Bác sĩ da liễu thẩm mỹ',
      likes: 89,
      comments: 15,
      shares: 21,
      hashtags: ['skinbarrier', 'ceramides', 'skinhealth'],
    ),
  ];

  // Sample comments
  final List<Comment> _sampleComments = [
    Comment(
      id: 'c1',
      userName: 'Lê Thị Thu Trang',
      userAvatar: 'assets/avatars/avatar7.png',
      content: 'anh đẹp trai ấk chỉ nhưng nhìn hết tế mà tự tỉ em cái e gét lắm lường :)( xin lỗi a :(((',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      likes: 3,
    ),
    Comment(
      id: 'c2',
      userName: 'Dr. Sarah Williams',
      userAvatar: 'assets/avatars/avatar2.png',
      content: 'Bí quyết cho da khô: Sử dụng sản phẩm có chứa ceramide và hyaluronic acid, kết hợp với kem dưỡng ẩm dạng rich cream vào buổi tối.',
      timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      isExpert: true,
      expertTitle: 'Bác sĩ da liễu',
      likes: 5,
    ),
  ];

  // Danh sách chuyên gia mẫu
  final List<Expert> _experts = [
    Expert(
      id: 'e1',
      name: 'Dr. Sarah Williams',
      avatar: 'assets/avatars/avatar2.png',
      title: 'Dermatologist, MD',
      isOnline: true,
      followers: 12500,
    ),
    Expert(
      id: 'e2',
      name: 'Dr. James Peterson',
      avatar: 'assets/avatars/avatar4.png',
      title: 'Cosmetic Dermatologist',
      followers: 8700,
    ),
    Expert(
      id: 'e3',
      name: 'Dr. Lisa Thompson',
      avatar: 'assets/avatars/avatar5.png',
      title: 'Dermatologist Nurse',
      isOnline: true,
      followers: 5300,
    ),
    Expert(
      id: 'e4',
      name: 'Dr. Robert Chen',
      avatar: 'assets/avatars/avatar6.png',
      title: 'Esthetician',
      followers: 4100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize posts with sample comments
    _posts[0].commentsList = List.from(_sampleComments);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Precache placeholder images here instead, after dependencies are available
    precacheImage(AssetImage('assets/images/placeholder.png'), context);
  }

  @override
  void dispose() {
    _postController.dispose();
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike(String postId) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index].isLiked = !_posts[index].isLiked;
        _posts[index].isLiked ? _posts[index].likes + 1 : _posts[index].likes - 1;
      }
    });
  }

  void _toggleCommentLike(String postId, String commentId) {
    setState(() {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final commentIndex = _posts[postIndex].commentsList.indexWhere((comment) => comment.id == commentId);
        if (commentIndex != -1) {
          final comment = _posts[postIndex].commentsList[commentIndex];
          comment.isLiked = !comment.isLiked;
          comment.likes += comment.isLiked ? 1 : -1;
        }
      }
    });
  }

  void _toggleComments(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].showComments = !_posts[postIndex].showComments;
      }
    });
  }

  void _addComment(String postId) {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final newComment = Comment(
          id: 'c${DateTime.now().millisecondsSinceEpoch}',
          userName: 'Me',
          userAvatar: 'assets/avatars/avatar_me.png',
          content: _commentController.text.trim(),
          timestamp: DateTime.now(),
        );
        
        _posts[postIndex].commentsList.add(newComment);
        _posts[postIndex].comments++;
        _commentController.clear();
      }
    });
  }

  void _addNewPost() {
    if (_postController.text.trim().isEmpty) return;
    
    setState(() {
      _posts.insert(
        0,
        ConsultationPost(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          userAvatar: 'assets/avatars/avatar_me.png',
          content: _postController.text.trim(),
          timestamp: DateTime.now(),
          type: PostType.userQuestion,
        ),
      );
      _postController.clear();
      _isPostingExpanded = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your question has been posted!'))
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Post',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple[100],
                    child: Text('ME', style: TextStyle(color: Colors.purple[800])),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Me',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _postController,
                decoration: InputDecoration(
                  hintText: 'What skin concern do you have?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gallery option would open here'))
                        );
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text('Add Photo'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _addNewPost();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.send),
                      label: Text('Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  List<ConsultationPost> _getFilteredPosts() {
    if (_searchController.text.isEmpty) {
      return _posts;
    }
    
    final query = _searchController.text.toLowerCase();
    return _posts.where((post) {
      return post.userName.toLowerCase().contains(query) || 
             post.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _getFilteredPosts();
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users or posts...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.black87),
              autofocus: true,
              onChanged: (value) {
                setState(() {});
              },
            )
          : Text('Skin Consultation'),
        centerTitle: !_isSearching,
        leading: _isSearching 
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          : null,
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
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildExpertsList(),
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(child: Text('No posts found.'))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(filteredPosts[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Colors.purple[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpertsList() {
    return Container(
      height: 86,
      padding: EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, bottom: 2),
            child: Text(
              'Skin Experts',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: _experts.length,
              itemBuilder: (context, index) {
                return _buildExpertAvatar(_experts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertAvatar(Expert expert) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertProfileScreen(expertId: expert.id),
          ),
        );
      },
      child: Container(
        width: 55,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 37,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      'Dr',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (expert.isOnline)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(
              height: 14,
              child: Text(
                _getShortSpecialty(expert.title),
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getShortSpecialty(String specialty) {
    final Map<String, String> specialtyMap = {
      'Dermatologist, MD': 'Dermatologist',
      'Cosmetic Dermatologist': 'Cosmetic',
      'Dermatologist Nurse': 'Derm Nurse',
      'Esthetician': 'Esthetician',
      'Bác sĩ da liễu thẩm mỹ': 'Da liễu',
      'Bác sĩ da liễu': 'Da liễu',
    };
    
    return specialtyMap[specialty] ?? specialty;
  }

  Widget _buildPostCard(ConsultationPost post) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(post.timestamp);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar
                GestureDetector(
                  onTap: post.isExpert ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpertProfileScreen(
                          expertId: _experts.firstWhere((e) => e.name == post.userName, orElse: () => _experts.first).id,
                        ),
                      ),
                    );
                  } : null,
                  child: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    radius: 20,
                    child: Text(
                      post.userName.substring(0, 2),
                      style: TextStyle(color: Colors.purple[800]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Name, verification, timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (post.isExpert) ...[
                            SizedBox(width: 4),
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (post.isExpert && post.expertTitle != null)
                            Text(
                              post.expertTitle!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (post.isExpert && post.expertTitle != null)
                            Text(
                              ' • ',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          Text(
                            timeAgo,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More options button
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    // Show options
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post options')),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Post content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post text
                Text(
                  post.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                // Hashtags if any
                if (post.content.contains('#'))
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '#skincare #beauty',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Post images (handle before/after case specially)
          if (post.images.isNotEmpty) ...[
            if (post.type == PostType.beforeAfter && post.images.length >= 2)
              // Before and after layout
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    // Before image
                    Expanded(
                      child: Column(
                        children: [
                          _getImageWidget(post.images[0]),
                          SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '8 NĂM TRƯỚC:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Sinh viên ngành kỹ thuật',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // After image
                    Expanded(
                      child: Column(
                        children: [
                          _getImageWidget(post.images[1]),
                          SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HIỆN TẠI:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Chuyên gia da liễu',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Regular image
              Padding(
                padding: EdgeInsets.all(16),
                child: _getImageWidget(post.images[0]),
              ),
          ],
          
          // Reactions count and comments count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reactions
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite, color: Colors.white, size: 12),
                    ),
                    SizedBox(width: 5),
                    Text(
                      post.likes.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Comments and shares count
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleComments(post.id),
                      child: Text(
                        '${post.comments} bình luận',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      '12 lượt chia sẻ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          
          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => _toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: post.isLiked ? Colors.blue[700] : Colors.grey[600],
                    size: 20,
                  ),
                  label: Text(
                    'Thích',
                    style: GoogleFonts.poppins(
                      color: post.isLiked ? Colors.blue[700] : Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _toggleComments(post.id),
                  icon: Icon(Icons.mode_comment_outlined, color: Colors.grey[600], size: 20),
                  label: Text(
                    'Bình luận',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                if (post.isExpert)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            expertId: _experts.firstWhere((e) => e.name == post.userName, orElse: () => _experts.first).id,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.share_outlined, color: Colors.grey[600], size: 20),
                    label: Text(
                      'Chia sẻ',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
              ],
            ),
          ),
          
          // Comments section
          if (post.showComments) ...[
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            // List of comments
            ...post.commentsList.map((comment) => _buildCommentItem(post.id, comment)).toList(),
            
            // Add comment input
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.purple[100],
                    child: Text('ME', style: TextStyle(color: Colors.purple[800], fontSize: 12)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600], size: 20),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.photo_camera_outlined, color: Colors.grey[600], size: 20), 
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.blue[600], size: 20),
                              onPressed: () => _addComment(post.id),
                            ),
                          ],
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentItem(String postId, Comment comment) {
    final timeAgo = _getTimeAgo(comment.timestamp);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.purple[100],
            child: Text(
              comment.userName.substring(0, comment.userName.length > 2 ? 2 : 1),
              style: TextStyle(color: Colors.purple[800], fontSize: 12),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.userName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (comment.isExpert) ...[
                            SizedBox(width: 5),
                            Icon(Icons.verified, color: Colors.blue, size: 14),
                          ],
                        ],
                      ),
                      if (comment.isExpert && comment.expertTitle != null)
                        Text(
                          comment.expertTitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _toggleCommentLike(postId, comment.id),
                        child: Text(
                          'Thích',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: comment.isLiked ? Colors.blue[700] : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (comment.likes > 0) ...[
                        SizedBox(width: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 10,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${comment.likes}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(width: 12),
                      Text(
                        'Phản hồi',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      final formatter = DateFormat('dd MMM');
      return formatter.format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get image widget with error handling
  Widget _getImageWidget(String imageUrl, {double? height, BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Container(
        height: height ?? 160,
        color: Colors.grey[200],
        child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[300]!),
                    value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  ),
                );
              },
            )
          : Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
            ),
      ),
    );
  }
} 