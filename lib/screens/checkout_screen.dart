import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  const CheckoutScreen({Key? key, required this.cartItems, required this.totalPrice}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedShippingMethod = 'Standard';
  String _selectedPaymentMethod = 'Credit Card';

  // Controllers for form fields (ví dụ)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Giả sử phí ship
  double get _shippingFee {
    return _selectedShippingMethod == 'Standard' ? 5.0 : 10.0;
  }

  double get _finalTotal {
    return widget.totalPrice + _shippingFee;
  }

 @override
  void dispose() {
    // Dispose controllers khi widget bị hủy
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Shipping Address', theme),
              _buildTextFormField(_nameController, 'Full Name', Icons.person_outline),
              _buildTextFormField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextFormField(_addressController, 'Street Address', Icons.home_outlined),
              _buildTextFormField(_cityController, 'City / Province', Icons.location_city_outlined),
              // Thêm các trường khác nếu cần (quận/huyện, zip code...)
              const SizedBox(height: 24),

              _buildSectionTitle('Shipping Method', theme),
              _buildShippingMethodSelector(theme),
              const SizedBox(height: 24),

              _buildSectionTitle('Payment Method', theme),
              _buildPaymentMethodSelector(theme),
              // Hiển thị trường nhập thẻ nếu chọn Credit Card
              if (_selectedPaymentMethod == 'Credit Card')
                _buildCreditCardFields(),
              const SizedBox(height: 24),

              _buildSectionTitle('Order Summary', theme),
              _buildOrderSummary(theme),
              const SizedBox(height: 30),

              // Nút Place Order
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Xử lý đặt hàng
                      print('Placing order...');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order placed successfully!'))
                      );
                      // TODO: Chuyển đến màn hình xác nhận đơn hàng hoặc trang chủ
                      // Ví dụ: xóa giỏ hàng và về home
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Helper Widgets cho các section ----

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: theme.textTheme.titleLarge?.color
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, bool obscureText = false, String? Function(String?)? validator}) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 12.0),
       child: TextFormField(
         controller: controller,
         keyboardType: keyboardType,
         obscureText: obscureText,
         style: TextStyle(fontSize: 15),
         decoration: InputDecoration(
           labelText: label,
           prefixIcon: Icon(icon, size: 20),
           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
           contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
           isDense: true,
         ),
         validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            // Thêm các validation khác nếu cần (email, phone...)
            return null;
          },
       ),
     );
  }

  Widget _buildShippingMethodSelector(ThemeData theme) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(value: 'Standard', label: Text('Standard (5-7 days)'), icon: Icon(Icons.local_shipping_outlined, size: 18)),
        ButtonSegment<String>(value: 'Express', label: Text('Express (1-2 days)'), icon: Icon(Icons.airplanemode_active_outlined, size: 18)),
      ],
      selected: {_selectedShippingMethod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedShippingMethod = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        selectedForegroundColor: theme.colorScheme.onPrimary,
        selectedBackgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
     // Có thể dùng RadioListTile hoặc widget tương tự
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('Credit Card'),
          secondary: Icon(Icons.credit_card),
          value: 'Credit Card',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
         RadioListTile<String>(
          title: Text('Cash on Delivery (COD)'),
          secondary: Icon(Icons.money_outlined),
          value: 'COD',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        // Thêm các phương thức khác nếu cần (PayPal...)
      ],
    );
  }

  Widget _buildCreditCardFields() {
    return Column(
      children: [
         const SizedBox(height: 12),
         _buildTextFormField(_cardNumberController, 'Card Number', Icons.credit_card, keyboardType: TextInputType.number),
         Row(
           children: [
             Expanded(
               child: _buildTextFormField(_expiryDateController, 'MM/YY', Icons.calendar_today_outlined, keyboardType: TextInputType.datetime),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: _buildTextFormField(_cvvController, 'CVV', Icons.lock_outline, keyboardType: TextInputType.number, obscureText: true),
             ),
           ],
         ),
      ],
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
     return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal:', '\$${widget.totalPrice.toStringAsFixed(2)}', theme),
          _buildSummaryRow('Shipping ($_selectedShippingMethod):', '\$${_shippingFee.toStringAsFixed(2)}', theme),
          const Divider(height: 20, thickness: 1),
          _buildSummaryRow('Total:', '\$${_finalTotal.toStringAsFixed(2)}', theme, isTotal: true),
          // Thêm phần nhập mã giảm giá nếu cần
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    final style = GoogleFonts.poppins(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: theme.textTheme.bodyMedium?.color
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: isTotal ? 17 : 15,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
       color: theme.textTheme.titleLarge?.color
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
} 