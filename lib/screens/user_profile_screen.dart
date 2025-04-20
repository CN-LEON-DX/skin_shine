import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'consultation_screen.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? username;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    this.username,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _userData = {};
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // Simulate API call delay
    Future.delayed(Duration(milliseconds: 800), () {
      final random = math.Random();
      
      // Mock user data
      _userData = {
        'id': widget.userId,
        'username': widget.username ?? 'user_${widget.userId}',
        'fullName': _generateRandomName(),
        'profileImage': 'assets/images/profile_placeholder.png',
        'bio': 'Skincare enthusiast and beauty advisor. Helping people achieve healthy, glowing skin.',
        'followersCount': random.nextInt(1000) + 100,
        'followingCount': random.nextInt(500) + 50,
        'postsCount': random.nextInt(50) + 5,
        'website': 'www.skinshine.com',
        'location': 'New York, USA',
        'joinDate': DateTime.now().subtract(Duration(days: random.nextInt(365) + 30)),
      };
      
      // Generate mock posts
      _userPosts = List.generate(
        _userData['postsCount'],
        (index) {
          final isBeforeAfter = random.nextBool();
          final hasDescription = random.nextBool();
          
          return {
            'id': 'post_$index',
            'userId': widget.userId,
            'username': _userData['username'],
            'content': hasDescription
                ? _generateRandomPostContent()
                : '',
            'images': isBeforeAfter
                ? ['assets/images/before.png', 'assets/images/after.png']
                : ['assets/images/post_${index % 5 + 1}.png'],
            'likesCount': random.nextInt(200),
            'commentsCount': random.nextInt(50),
            'sharesCount': random.nextInt(30),
            'date': DateTime.now().subtract(Duration(days: random.nextInt(30))),
            'isLiked': random.nextBool(),
            'isSaved': random.nextBool(),
          };
        },
      );
      
      // Sort posts by date, newest first
      _userPosts.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      setState(() {
        _isLoading = false;
      });
    });
  }

  String _generateRandomName() {
    final firstNames = [
      'Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia',
      'Liam', 'Noah', 'William', 'James', 'Oliver',
    ];
    final lastNames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
      'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    ];
    
    final random = math.Random();
    return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
  }

  String _generateRandomPostContent() {
    final contents = [
      'Just started a new skincare routine and I\'m already seeing results! #SkinCare #Glow',
      'Before and after using the new @SkinShine facial cleanser for 2 weeks. What do you think?',
      'The secret to great skin is consistency and quality products. Here\'s my current routine...',
      'Got a professional facial today and my skin feels amazing! Highly recommend @SkinShineClinic',
      'My 3-month progress after following the advice from my dermatologist. So happy with the results!',
      'Just received my new products from SkinShine! Can\'t wait to try them out.',
      'Quick tip: Don\'t forget to apply sunscreen even on cloudy days! UV rays still affect your skin.',
      'What\'s your favorite moisturizer? Looking for recommendations for dry, sensitive skin.',
      'Sharing my nighttime skincare routine for those who requested it. Hope this helps!',
      'Is anyone else obsessed with sheet masks? I use them twice a week and my skin loves them!',
    ];
    
    final random = math.Random();
    return contents[random.nextInt(contents.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 0,
                    floating: true,
                    pinned: true,
                    title: Text(_userData['username']),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          // Show options menu
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildOptionsMenu(),
                          );
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Posts'),
                          Tab(text: 'About'),
                        ],
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
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
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(_userData['profileImage']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['fullName'],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${_userData['username']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    if (_userData['bio'] != null && _userData['bio'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _userData['bio'],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Posts', _userData['postsCount'].toString()),
              _buildStatColumn('Followers', _userData['followersCount'].toString()),
              _buildStatColumn('Following', _userData['followingCount'].toString()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.grey[200] : Theme.of(context).primaryColor,
                    foregroundColor: _isFollowing ? Colors.black : Colors.white,
                  ),
                  child: Text(_isFollowing ? 'Following' : 'Follow'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  // Navigate to chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Messaging ${_userData['username']}')),
                  );
                },
                child: Text('Message'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_userPosts.isEmpty) {
      return Center(
        child: Text(
          'No posts yet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(_userData['profileImage']),
            ),
            title: Text(
              _userData['fullName'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormat.yMMMd().format(post['date']),
              style: TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                // Show post options
              },
            ),
          ),
          if (post['content'] != null && post['content'].isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post['content']),
            ),
          if (post['images'] != null && post['images'].isNotEmpty)
            post['images'].length > 1
                ? _buildBeforeAfterImages(post['images'])
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/placeholder_image.png',
                        fit: BoxFit.cover,
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
                    Icon(
                      post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                      color: post['isLiked'] ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text('${post['likesCount']}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text('${post['commentsCount']}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text('${post['sharesCount']}'),
                  ],
                ),
                Icon(
                  post['isSaved'] ? Icons.bookmark : Icons.bookmark_border,
                  color: post['isSaved'] ? Theme.of(context).primaryColor : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterImages(List<dynamic> images) {
    return Container(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/placeholder_image.png',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BEFORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/placeholder_image.png',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'AFTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
          _buildInfoSection('About', [
            if (_userData['location'] != null)
              _buildInfoRow(Icons.location_on, _userData['location']),
            if (_userData['website'] != null)
              _buildInfoRow(Icons.link, _userData['website']),
            _buildInfoRow(
              Icons.calendar_today,
              'Joined ${DateFormat.yMMMM().format(_userData['joinDate'])}',
            ),
          ]),
          Divider(),
          _buildInfoSection('Skin Concerns', [
            _buildChip('Acne'),
            _buildChip('Dryness'),
            _buildChip('Anti-aging'),
          ]),
          Divider(),
          _buildInfoSection('Favorite Products', [
            _buildProductItem('SkinShine Gentle Cleanser'),
            _buildProductItem('Hydrating Toner'),
            _buildProductItem('Ultra Moisturizing Cream'),
            _buildProductItem('SPF 50 Sunscreen'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductItem(String productName) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.spa, color: Theme.of(context).primaryColor),
      ),
      title: Text(productName),
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      dense: true,
    );
  }

  Widget _buildOptionsMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Report user'),
            onTap: () {
              Navigator.pop(context);
              // Show report dialog
            },
          ),
          ListTile(
            leading: Icon(Icons.block),
            title: Text('Block user'),
            onTap: () {
              Navigator.pop(context);
              // Show block confirmation
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share profile'),
            onTap: () {
              Navigator.pop(context);
              // Share profile
            },
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
} 