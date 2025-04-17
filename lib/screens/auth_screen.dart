import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart'; // Import RegisterScreen
import 'forgot_password_screen.dart'; // Import ForgotPasswordScreen

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _obscureText = true; // Trạng thái ẩn/hiện mật khẩu

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Màu sắc chủ đạo (có thể lấy từ Theme)
    final Color primaryOrange = Color(0xFFFF5722);
    final Color lightOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.white, // Đặt nền trắng
      body: SafeArea( // Đảm bảo nội dung không bị che
        child: SingleChildScrollView( // Cho phép cuộn khi bàn phím hiện lên
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo dài các widget con
            children: [
              // --- Title Section ---
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(2)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // --- Welcome Text ---
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Wellcome back !', // Đổi chữ theo ảnh mẫu
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 40),

              // --- Email Field với Shadow ---
              _buildShadowTextField(
                child: _buildTextField(
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 20),

              // --- Password Field với Shadow ---
               _buildShadowTextField(
                 child: _buildPasswordField(),
               ),
              SizedBox(height: 15),

              // --- Forgot Password ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print('Forgot Password tapped');
                    // Điều hướng đến màn hình Forgot Password
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot password ?',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                     padding: EdgeInsets.zero, // Bỏ padding mặc định
                     minimumSize: Size(50, 30), // Kích thước tối thiểu
                     alignment: Alignment.centerRight,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // --- Login Button (Gradient) ---
              _buildGradientLoginButton(primaryOrange, lightOrange),
              SizedBox(height: 25),

              // --- "Or" Separator ---
              Text(
                'Or',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 25),

              // --- Google Sign-in Button ---
              _buildGoogleButton(context),
              SizedBox(height: 40),

              // --- Register Now Link ---
              _buildRegisterNowLink(context, primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Widget bao bọc TextField để thêm đổ bóng
  Widget _buildShadowTextField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }

  // Widget xây dựng trường nhập liệu chung (không có đổ bóng)
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        suffixIcon: suffixIcon,
        filled: false, // Không fill màu nền nữa
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0), // Điều chỉnh padding
        isDense: true,
      ),
    );
  }

  // Widget xây dựng trường nhập mật khẩu (sử dụng _buildTextField)
  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: 'Password',
      icon: Icons.lock_outline,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey[500],
          size: 20,
        ),
        onPressed: _togglePasswordVisibility,
        splashRadius: 20,
      ),
    );
  }

  // Widget xây dựng nút Đăng nhập với Gradient
  Widget _buildGradientLoginButton(Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2], // Màu gradient cam -> vàng
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15.0), // Bo tròn hơn
        boxShadow: [ // Thêm đổ bóng nhẹ cho nút nổi bật
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          print('Login button pressed');
          Navigator.pushReplacementNamed(context, '/home');
        },
        child: Text(
          'LOGIN',
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 0.5
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Widget xây dựng nút Đăng nhập bằng Google
  Widget _buildGoogleButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        print('Continue with Google tapped');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        side: BorderSide(color: Colors.grey.shade200, width: 1.0), // Viền nhạt hơn
        elevation: 2, // Thêm chút bóng đổ
        shadowColor: Colors.grey.withOpacity(0.1), // Màu bóng đổ
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 24,
            width: 24,
            child: _buildGoogleLogo(),
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: GoogleFonts.poppins(
              color: Colors.black87, 
              fontWeight: FontWeight.w600, 
              fontSize: 15
            ),
          ),
        ],
      ),
    );
  }

  // Phương thức để tạo logo Google nhiều màu sắc
  Widget _buildGoogleLogo() {
    return CustomPaint(
      size: Size(24, 24),
      painter: GoogleLogoPainter(),
    );
  }

  // Widget xây dựng link "Register Now"
  Widget _buildRegisterNowLink(BuildContext context, Color highlightColor) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        children: <TextSpan>[
          TextSpan(text: "You don't have an account? "),
          TextSpan(
            text: 'Register Now',
            style: GoogleFonts.poppins(
              color: highlightColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print('Register Now tapped');
                // Điều hướng đến màn hình đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
          ),
        ],
      ),
    );
  }
}

// Custom Painter để vẽ logo Google đa màu
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    // Màu sắc của logo Google
    final Color blue = Color(0xFF4285F4);
    final Color red = Color(0xFFEA4335);
    final Color yellow = Color(0xFFFBBC05);
    final Color green = Color(0xFF34A853);
    
    final Paint paint = Paint()..style = PaintingStyle.fill;
    
    // Vẽ chữ G với các màu sắc
    final Path path = Path();
    
    // Phần màu xanh dương (bên phải)
    paint.color = blue;
    path.moveTo(width * 0.6, height * 0.5);
    path.arcTo(
      Rect.fromLTRB(width * 0.1, height * 0.1, width * 0.9, height * 0.9),
      -Math.pi / 4,
      Math.pi / 2,
      false,
    );
    path.lineTo(width * 0.9, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
    
    // Phần màu đỏ (trên cùng)
    paint.color = red;
    path.reset();
    path.moveTo(width * 0.5, height * 0.25);
    path.arcTo(
      Rect.fromLTRB(width * 0.1, height * 0.1, width * 0.9, height * 0.9),
      -5 * Math.pi / 4,
      Math.pi / 2,
      false,
    );
    path.lineTo(width * 0.5, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
    
    // Phần màu vàng (bên trái)
    paint.color = yellow;
    path.reset();
    path.moveTo(width * 0.3, height * 0.5);
    path.arcTo(
      Rect.fromLTRB(width * 0.1, height * 0.1, width * 0.9, height * 0.9),
      3 * Math.pi / 4,
      Math.pi / 2,
      false,
    );
    path.lineTo(width * 0.5, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
    
    // Phần màu xanh lá (dưới cùng)
    paint.color = green;
    path.reset();
    path.moveTo(width * 0.5, height * 0.75);
    path.arcTo(
      Rect.fromLTRB(width * 0.1, height * 0.1, width * 0.9, height * 0.9),
      Math.pi / 4,
      Math.pi / 2,
      false,
    );
    path.lineTo(width * 0.5, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
    
    // Phần trắng ở giữa
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(width * 0.5, height * 0.5),
      width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Thêm Math class để sử dụng pi
class Math {
  static const double pi = 3.1415926535897932;
} 