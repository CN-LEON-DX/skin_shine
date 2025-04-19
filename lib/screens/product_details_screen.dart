import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/comment.dart';
import '../widgets/bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import '../models/cart_item.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Controller cho input bình luận
  final TextEditingController _commentController = TextEditingController();
  
  // Biến lưu số lượng trong giỏ hàng
  int cartItemCount = 2; // Số lượng mẫu, thực tế sẽ lấy từ state quản lý giỏ hàng
  
  // Flag hiển thị bàn phím emoji
  bool _showEmojiKeyboard = false;
  
  // Lấy bình luận cho sản phẩm hiện tại
  List<Comment> get productComments {
    return dummyComments[widget.product.id] ?? [];
  }
  
  // Thêm bình luận mới
  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      if (dummyComments[widget.product.id] == null) {
        dummyComments[widget.product.id] = [];
      }
      
      dummyComments[widget.product.id]!.add(
        Comment(
          id: 'c${DateTime.now().millisecondsSinceEpoch}',
          userId: 'current_user',
          userName: 'You',
          userAvatar: 'https://placehold.co/50x50/png',
          text: text.trim(),
          timestamp: DateTime.now(),
        )
      );
      
      _commentController.clear();
    });
  }
  
  // Toggle like cho bình luận
  void _toggleLike(Comment comment) {
    setState(() {
      if (comment.isLiked) {
        comment.likes--;
      } else {
        comment.likes++;
      }
      comment.isLiked = !comment.isLiked;
    });
  }

  // Helper method to display product image with fallback
  Widget _buildProductImage() {
    try {
      return Image.network(
        widget.product.imageUrl,
        height: 250,
        fit: BoxFit.contain,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return _buildImagePlaceholder();
        },
      );
    } catch (e) {
      print('Exception when loading network image: $e');
      return _buildImagePlaceholder();
    }
  }

  // Placeholder for images
  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: 250,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: Colors.grey[400], size: 50),
            SizedBox(height: 10),
            Text(
              'Product Image',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to display user avatar with fallback
  Widget _buildUserAvatar(String avatarUrl, double radius) {
    try {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: Colors.grey[300],
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading avatar: $exception');
        },
        child: avatarUrl.isEmpty
          ? Icon(Icons.person, color: Colors.grey[400], size: radius * 1.5)
          : null,
      );
    } catch (e) {
      print('Exception when handling avatar: $e');
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.grey[400], size: radius * 1.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and cart
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    // Product Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: _buildProductImage(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title, Brand, Expert Badge
                    _buildTitleAndBrand(),
                    const SizedBox(height: 15),

                    // Price
                    _buildPrice(),
                    const SizedBox(height: 20),

                    // Description
                    _buildSectionTitle('Description'),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // Key Ingredients
                    _buildSectionTitle('Key Ingredients'),
                    Text(
                      widget.product.keyIngredients.replaceAll('With ', '').replaceAll(' & ', '\n• '),
                      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // Reviews Section with Rating
                    _buildSectionTitle('Ratings & Reviews'),
                    _buildReviewsSection(context),
                    const SizedBox(height: 20),

                    // Comments Section
                    _buildSectionTitle('Customer Comments'),
                    _buildCommentsSection(),

                    // Comment input (placeholder inside scroll)
                    _buildVisibleCommentInput(),
                    const SizedBox(height: 20),

                    // How to Use
                    _buildSectionTitle('How to Use'),
                    Text(
                      'Apply a few drops to cleansed face morning and night before moisturizer. Gently pat into skin.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                    ),

                    const SizedBox(height: 100), // Space for the fixed bottom bar
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar (Add to Cart / Buy Now)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActionBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the header with back button, share and cart
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.share_outlined, color: Colors.grey[600]),
              onPressed: () {
                // Thực hiện chức năng chia sẻ
                Share.share(
                  'Check out this product: ${widget.product.name} - Find it on SkinShine! #skincare', // Nội dung chia sẻ
                  subject: 'Look what I found on SkinShine!' // Tiêu đề cho email
                );
              },
            ),
            // Icon giỏ hàng với badge số lượng
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, size: 26),
                  onPressed: () {
                    // Điều hướng đến trang giỏ hàng
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()), // Điều hướng đến CartScreen
                    );
                  },
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Tách phần Title và Brand ra widget riêng cho rõ ràng
  Widget _buildTitleAndBrand() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.product.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Chip(
          avatar: Icon(Icons.verified_outlined, color: Colors.green[700], size: 16),
          label: Text('Expert Pick'),
          labelStyle: TextStyle(fontSize: 11, color: Colors.green[800], fontWeight: FontWeight.w600),
          backgroundColor: Colors.green[100]?.withOpacity(0.8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // Tách phần Price ra widget riêng
  Widget _buildPrice() {
    return Text(
      '\$${widget.product.price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.purple[800]),
    );
  }

  // Widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget for reviews section
  Widget _buildReviewsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 20),
            const SizedBox(width: 4),
            Text(
              '${widget.product.rating.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.product.reviewCount} reviews)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Review page not implemented yet.'))
            );
          },
          child: Text(
            'See All',
            style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.w600),
          ),
        )
      ],
    );
  }
  
  // Widget for comments section
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments count
        Text(
          '${productComments.length} comments',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        
        // List of comments
        if (productComments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                'Be the first to comment!',
                style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ...productComments.map((comment) => _buildCommentItem(comment)).toList(),
      ],
    );
  }
  
  // Widget for a single comment
  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          _buildUserAvatar(comment.userAvatar, 20),
          const SizedBox(width: 10),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment bubble
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        comment.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      
                      // Comment text
                      Text(
                        comment.text,
                        style: TextStyle(fontSize: 14),
                      ),
                      
                      // Comment image if any
                      if (comment.images.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildCommentImage(comment.images.first),
                      ],
                    ],
                  ),
                ),
                
                // Like button and timestamp
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                  child: Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: () => _toggleLike(comment),
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: comment.isLiked ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likes}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Timestamp
                      Text(
                        _getFormattedDate(comment.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
  
  // Helper to build comment images with fallback
  Widget _buildCommentImage(String imageUrl) {
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              color: Colors.grey[200],
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network comment image: $error');
            return Container(
              height: 150,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                    SizedBox(height: 4),
                    Text('Image Error', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('Exception when loading network comment image: $e');
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: Icon(Icons.error_outline, color: Colors.grey),
      );
    }
  }
  
  // Widget for comment input
  Widget _buildVisibleCommentInput() {
    return GestureDetector(
      onTap: () {
        // Khi người dùng nhấp vào phần này, hiển thị bàn phím đầy đủ
        FocusScope.of(context).requestFocus(FocusNode());
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildFullCommentInput(),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildUserAvatar('https://placehold.co/50x50/png', 18),
            ),
            
            // Text field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment hint
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                    child: Text(
                      'Add a comment...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Emoji button
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Icon(Icons.emoji_emotions_outlined, 
                          color: Colors.grey[600], size: 20),
                      ),
                      const SizedBox(width: 10),
                      
                      // Camera button
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Icon(Icons.photo_camera, 
                          color: Colors.grey[600], size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Post button
            Padding(
              padding: const EdgeInsets.only(top: 2.0, right: 10.0),
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.purple[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for full comment input modal
  Widget _buildFullCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add a comment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            // Divider
            Divider(),
            
            // User info
            Row(
              children: [
                _buildUserAvatar('https://placehold.co/50x50/png', 20),
                SizedBox(width: 10),
                Text(
                  'You',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            
            // Comment text field
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple[300]!),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 15),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - media options
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo_library_outlined),
                      color: Colors.grey[700],
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gallery picker would open here'))
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined),
                      color: Colors.grey[700],
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Emoji picker would open here'))
                        );
                      },
                    ),
                  ],
                ),
                
                // Right side - post button
                ElevatedButton(
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _addComment(_commentController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for bottom action bar
  Widget _buildActionBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart Button
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.add_shopping_cart_outlined, size: 20),
              label: Text('Add to Cart'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.product.name} added to cart!'), duration: Duration(seconds: 2))
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple[700],
                side: BorderSide(color: Colors.purple[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Buy Now Button
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.shopping_bag_outlined, size: 20),
              label: Text('Buy Now'),
              onPressed: () {
                // Create a temporary cart item list with the current product
                final List<CartItem> buyNowItems = [
                  CartItem(
                    product: widget.product, 
                    quantity: 1
                  )
                ];
                final double buyNowTotal = widget.product.price;

                // Navigate to CheckoutScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      cartItems: buyNowItems,
                      totalPrice: buyNowTotal,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper to format date
  String _getFormattedDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      final formatter = DateFormat('dd/MM/yyyy');
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
} 