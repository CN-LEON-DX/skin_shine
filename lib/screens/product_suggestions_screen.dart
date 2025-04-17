import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/bottom_bar.dart';
import 'product_details_screen.dart';

class ProductSuggestionsScreen extends StatefulWidget {
  @override
  _ProductSuggestionsScreenState createState() => _ProductSuggestionsScreenState();
}

class _ProductSuggestionsScreenState extends State<ProductSuggestionsScreen> {
  String? _selectedSkinType = 'All Skin Types';
  String? _selectedConcern = 'All Concerns';
  String _searchQuery = '';
  
  // Controller cho thanh tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // Biến lưu số lượng trong giỏ hàng
  int cartItemCount = 2; // Số lượng mẫu, thực tế sẽ lấy từ state quản lý giỏ hàng

  // Hàm để cập nhật trạng thái yêu thích
  void _toggleFavorite(String productId) {
    setState(() {
      final productIndex = dummyProducts.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        dummyProducts[productIndex].isFavorite = !dummyProducts[productIndex].isFavorite;
      }
    });
  }

  // Lọc sản phẩm dựa trên tìm kiếm và bộ lọc
  List<Product> get _filteredProducts {
    return dummyProducts.where((product) {
      // Lọc theo từ khóa tìm kiếm
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.keyIngredients.toLowerCase().contains(_searchQuery.toLowerCase());

      // Lọc theo loại da (có thể mở rộng logic sau)
      final matchesSkinType = _selectedSkinType == 'All Skin Types' || 
          product.description.toLowerCase().contains(_selectedSkinType!.toLowerCase());

      // Lọc theo vấn đề da (có thể mở rộng logic sau)
      final matchesConcern = _selectedConcern == 'All Concerns' || 
          product.description.toLowerCase().contains(_selectedConcern!.toLowerCase());

      return matchesSearch && matchesSkinType && matchesConcern;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header với nút Back, tiêu đề và giỏ hàng
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Row(
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
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Product Suggestions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Icon giỏ hàng với badge số lượng
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined, size: 26),
                            onPressed: () {
                              // Điều hướng đến trang giỏ hàng
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Navigating to cart...'))
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
                ),

                // Thanh tìm kiếm
                _buildSearchBar(),

                // Filter Row
                _buildFilterRow(),

                // Product List
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(child: Text('No products found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15.0),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (ctx, index) {
                            final product = _filteredProducts[index];
                            return _ProductCard(
                              product: product,
                              onFavoriteToggle: () => _toggleFavorite(product.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            
            
          ],
        ),
      ),
    );
  }

  // Widget xây dựng thanh tìm kiếm
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // Widget xây dựng hàng Filter
  Widget _buildFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown('Skin Type', _selectedSkinType, 
              ['All Skin Types', 'Oily', 'Dry', 'Combination', 'Sensitive'], 
              (value) {
                setState(() => _selectedSkinType = value);
              }
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildFilterDropdown('Concern', _selectedConcern, 
              ['All Concerns', 'Acne', 'Aging', 'Hydration', 'Pigmentation'], 
              (value) {
                setState(() => _selectedConcern = value);
              }
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng một Dropdown Filter
  Widget _buildFilterDropdown(String hintPrefix, String? currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
          style: TextStyle(color: Colors.black87, fontSize: 13),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Widget cho một thẻ sản phẩm
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _ProductCard({
    Key? key,
    required this.product,
    required this.onFavoriteToggle,
    required this.onTap,
  }) : super(key: key);

  // Helper method to display product image with fallback
  Widget _buildProductImage(String imagePath) {
    try {
      return Image.asset(
        imagePath,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading product image: $error');
          return Container(
            width: 80, 
            height: 100, 
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
          );
        },
      );
    } catch (e) {
      print('Exception when loading product image: $e');
      return Container(
        width: 80, 
        height: 100, 
        color: Colors.grey[200],
        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _buildProductImage(product.imageUrl),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Favorite Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: onFavoriteToggle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                            child: Icon(
                              product.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: product.isFavorite ? Colors.redAccent : Colors.grey[400],
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.keyIngredients,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price & Buy Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Buy Now: ${product.name}');
                            // Thêm logic mua hàng
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to cart!'))
                            );
                          },
                          child: Text('Buy Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            minimumSize: Size(0, 36)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 