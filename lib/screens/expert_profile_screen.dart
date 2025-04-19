import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

// Model cho chuyên gia (giữ đồng bộ với ConsultationScreen)
class Expert {
  final String id;
  final String name;
  final String avatar;
  final String title;
  final String bio;
  final String education;
  final String specialty;
  final List<String> certifications;
  final bool isOnline;
  final int followers;
  final int posts;
  final int reviews;
  final double rating;

  Expert({
    required this.id,
    required this.name,
    required this.avatar,
    required this.title,
    required this.bio,
    required this.education,
    required this.specialty,
    required this.certifications,
    this.isOnline = false,
    this.followers = 0,
    this.posts = 0,
    this.reviews = 0,
    this.rating = 5.0,
  });
}

// Model cho bài đăng
class ExpertPost {
  final String id;
  final String content;
  final DateTime timestamp;
  final List<String> images;
  final int likes;
  final int comments;

  ExpertPost({
    required this.id,
    required this.content,
    required this.timestamp,
    this.images = const [],
    this.likes = 0,
    this.comments = 0,
  });
}

class ExpertProfileScreen extends StatefulWidget {
  final String expertId;

  const ExpertProfileScreen({Key? key, required this.expertId}) : super(key: key);

  @override
  _ExpertProfileScreenState createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  
  // Danh sách chuyên gia mẫu - cùng ID với ConsultationScreen
  final List<Expert> _experts = [
    Expert(
      id: 'e1',
      name: 'Dr. Sarah Williams',
      avatar: 'https://placehold.co/50x50/E0F7FA/000?text=SW',
      title: 'Dermatologist, MD',
      bio: 'Board-certified dermatologist specializing in acne, rosacea, and anti-aging treatments. I believe in science-based skincare that\'s also accessible and practical for everyday use.',
      education: 'University of Michigan Medical School',
      specialty: 'Medical & Cosmetic Dermatology',
      certifications: ['American Board of Dermatology', 'American Academy of Dermatology'],
      isOnline: true,
      followers: 12500,
      posts: 87,
      reviews: 342,
      rating: 4.8,
    ),
    Expert(
      id: 'e2',
      name: 'Dr. James Peterson',
      avatar: 'https://placehold.co/50x50/FFF9C4/000?text=JP',
      title: 'Cosmetic Dermatologist',
      bio: 'With over 15 years of experience in cosmetic dermatology, I focus on combining traditional practices with the latest technological innovations to deliver optimal results.',
      education: 'Harvard Medical School',
      specialty: 'Cosmetic Procedures & Anti-Aging',
      certifications: ['American Society for Dermatologic Surgery', 'American Academy of Cosmetic Surgery'],
      followers: 8700,
      posts: 54,
      reviews: 218,
      rating: 4.7,
    ),
    Expert(
      id: 'e3',
      name: 'Dr. Lisa Thompson',
      avatar: 'https://placehold.co/50x50/F3E5F5/000?text=LT',
      title: 'Dermatologist Nurse',
      bio: 'Dermatology nurse practitioner passionate about helping patients achieve healthy skin. I specialize in treating adult acne and providing customized skincare routines.',
      education: 'Johns Hopkins School of Nursing',
      specialty: 'Adult Acne & Skincare Routines',
      certifications: ['Dermatology Nursing Certification Board', 'American Nurses Association'],
      isOnline: true,
      followers: 5300,
      posts: 123,
      reviews: 185,
      rating: 4.9,
    ),
    Expert(
      id: 'e4',
      name: 'Dr. Robert Chen',
      avatar: 'https://placehold.co/50x50/E8F5E9/000?text=RC',
      title: 'Esthetician',
      bio: 'Licensed esthetician with a focus on holistic skincare approaches. I believe in treating skin conditions from both the inside and outside for long-lasting results.',
      education: 'International Dermal Institute',
      specialty: 'Holistic Skincare & Facial Treatments',
      certifications: ['National Esthetician Certification', 'International Therapy Examination Council'],
      followers: 4100,
      posts: 95,
      reviews: 156,
      rating: 4.6,
    ),
  ];

  // Bài đăng mẫu của chuyên gia
  List<ExpertPost> _expertPosts = [
    ExpertPost(
      id: 'p1',
      content: 'Understanding the basics of skin hydration: Hydrated skin isn\'t just about drinking water! Your skin barrier, environmental factors, and product ingredients all play crucial roles. Look for humectants like hyaluronic acid that draw water into the skin, and occlusives like shea butter that seal in moisture.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      images: ['https://placehold.co/400x300/E0F7FA/000?text=Skin+Hydration'],
      likes: 345,
      comments: 42,
    ),
    ExpertPost(
      id: 'p2',
      content: 'Why that popular cleansing method might be damaging your skin barrier. Remember: squeaky clean isn\'t always healthy! Your skin should feel comfortable after cleansing, not tight or dry.',
      timestamp: DateTime.now().subtract(Duration(days: 5)),
      likes: 287,
      comments: 76,
    ),
    ExpertPost(
      id: 'p3',
      content: 'Beautiful results from today\'s microneedling session! Remember that results develop over 4-6 weeks as collagen production increases. #SkinTreatment #BeforeAndAfter',
      timestamp: DateTime.now().subtract(Duration(days: 7)),
      images: [
        'https://placehold.co/400x300/F5F5F5/000?text=Before',
        'https://placehold.co/400x300/E8F5E9/000?text=After'
      ],
      likes: 521,
      comments: 54,
    ),
  ];

  late Expert _expert;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Tìm chuyên gia theo ID
    _expert = _experts.firstWhere(
      (expert) => expert.id == widget.expertId,
      orElse: () => _experts.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildCoverPhoto(),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(130),
                  child: _buildProfileHeader(),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(text: 'Posts'),
                      Tab(text: 'About'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsTab(),
              _buildAboutTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPhoto() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple[200]!,
            Colors.purple[50]!,
          ],
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(left: 140, bottom: 20, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _expert.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _expert.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: -50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(_expert.avatar),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Spacer(),
              _buildFollowButton(),
              SizedBox(width: 10),
              _buildMessageButton(),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${_expert.followers}', 'Followers'),
              _buildStatItem('${_expert.posts}', 'Posts'),
              _buildStatItem('${_expert.reviews}', 'Reviews'),
              _buildStatItem('${_expert.rating}', 'Rating'),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isFollowing = !_isFollowing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? 'Following ${_expert.name}' : 'Unfollowed ${_expert.name}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      icon: Icon(_isFollowing ? Icons.check : Icons.add),
      label: Text(_isFollowing ? 'Following' : 'Follow'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing ? Colors.grey[300] : Theme.of(context).primaryColor,
        foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildMessageButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(expertId: _expert.id),
          ),
        );
      },
      icon: Icon(Icons.chat_bubble_outline),
      label: Text('Message'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor),
        foregroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: _expertPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_expertPosts[index]);
      },
    );
  }

  Widget _buildPostCard(ExpertPost post) {
    final timeAgo = _getTimeAgo(post.timestamp);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(_expert.avatar),
              radius: 24,
            ),
            title: Text(
              _expert.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  _expert.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  ' · $timeAgo',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.more_horiz),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (post.images.isNotEmpty)
            Container(
              height: post.images.length > 1 ? 200 : 250,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: post.images.length > 1
                  ? Row(
                      children: post.images
                          .map((img) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img,
                                      fit: BoxFit.cover,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red[400], size: 16),
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
                Text(
                  '${post.comments} comments',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Like post
                  },
                  icon: Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                  label: Text(
                    'Like',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Comment
                  },
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 20),
                  label: Text(
                    'Comment',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Share
                  },
                  icon: Icon(Icons.share_outlined, color: Colors.grey[600], size: 20),
                  label: Text(
                    'Share',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection('Bio', _expert.bio),
          Divider(),
          _buildAboutSection('Education', _expert.education),
          Divider(),
          _buildAboutSection('Specialty', _expert.specialty),
          Divider(),
          _buildCertificationsList('Certifications', _expert.certifications),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCertificationsList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 60),
          SizedBox(height: 16),
          Text(
            '${_expert.rating}/5.0',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Based on ${_expert.reviews} reviews',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Reviews will be displayed here. Featured patient feedback and testimonials for ${_expert.name}\'s services.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
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
      return '${difference.inDays ~/ 7}w ago';
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
}

// Helper class for SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 