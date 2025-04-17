import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart';
import '../models/product.dart'; // Đảm bảo import đúng Product và dummyProducts từ đây

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --- Dữ liệu giỏ hàng giả lập ---
  final List<CartItem> _cartItems = [
    // Sử dụng dummyProducts được import
    if (dummyProducts.length > 1) CartItem(product: dummyProducts[1], quantity: 2),
    if (dummyProducts.length > 3) CartItem(product: dummyProducts[3], quantity: 1),
  ];

  // Hàm tính tổng tiền
  double get _totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Hàm tăng số lượng
  void _incrementQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  // Hàm giảm số lượng
  void _decrementQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        // Nếu giảm xuống 0 thì xóa khỏi giỏ hàng
        _removeItem(item);
      }
    });
  }

  // Hàm xóa item khỏi giỏ hàng
  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.product.name} removed from cart.'), duration: Duration(seconds: 1),)
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        centerTitle: true,
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.delete_sweep_outlined)) // Có thể thêm nút xóa tất cả
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItemWidget(_cartItems[index]);
                    },
                  ),
          ),
          // Phần tổng tiền và checkout
          if (_cartItems.isNotEmpty)
             _buildSummaryAndCheckout(context),
        ],
      ),
    );
  }

  // Widget hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            'Looks like you haven\'t added anything yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), // Quay lại
            child: Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12)
            ),
          )
        ],
      ),
    );
  }

  // Widget hiển thị một item trong giỏ hàng
  Widget _buildCartItemWidget(CartItem item) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset( // Sử dụng Image.asset vì dummy data dùng path local
                  item.product.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                     width: 70,
                     height: 70,
                     color: Colors.grey[200],
                     child: Icon(Icons.broken_image, color: Colors.grey[400])
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Thông tin sản phẩm và số lượng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontSize: 14, color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Điều chỉnh số lượng
                    Row(
                      children: [
                        _buildQuantityButton(Icons.remove, () => _decrementQuantity(item)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            item.quantity.toString(),
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildQuantityButton(Icons.add, () => _incrementQuantity(item)),
                      ],
                    )
                  ],
                ),
              ),
              // Nút xóa
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                onPressed: () => _removeItem(item),
                tooltip: 'Remove item',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho nút +/- số lượng
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  // Widget hiển thị tổng tiền và nút Checkout
  Widget _buildSummaryAndCheckout(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // Màu nền dựa theo theme
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${_cartItems.length} items):',
                style: GoogleFonts.poppins(fontSize: 15, color: theme.textTheme.bodyMedium?.color),
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Proceeding to Checkout...'))
                 );
                 // Điều hướng đến màn hình thanh toán thực tế
              },
              child: Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                // Màu sắc nút lấy từ theme chính
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- XÓA ĐỊNH NGHĨA PRODUCT VÀ DUMMYDATA THỪA Ở ĐÂY ---
/*
class Product { ... }
final List<Product> dummyProducts = [ ... ];
*/ 