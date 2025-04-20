import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'register_screen.dart'; // Import RegisterScreen
import 'forgot_password_screen.dart'; // Import ForgotPasswordScreen
import '../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _obscureText = true; // Trạng thái ẩn/hiện mật khẩu
  bool _isLoading = false; // Trạng thái loading
  String _errorMessage = ''; // Thông báo lỗi
  
  // Controllers cho các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  
  // Xử lý đăng nhập bằng email/password
  Future<void> _handleEmailLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Email and password cannot be empty';
          _isLoading = false;
        });
        return;
      }
      
      final user = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (user != null) {
        // Đăng nhập thành công, chuyển đến trang chính
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }
  
  // Xử lý đăng nhập bằng Google
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final user = await SupabaseService.signInWithGoogle(context);
      
      setState(() {
        _isLoading = false;
      });
      
      // Có thể user là null nếu chưa hoàn tất quá trình đăng nhập Google
      if (user != null) {
        // Đăng nhập thành công, chuyển đến trang chính
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  'Welcome back !', // Đổi chữ theo ảnh mẫu
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 40),
              
              // Hiển thị thông báo lỗi nếu có
              if (_errorMessage.isNotEmpty) 
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.poppins(
                        color: Colors.red[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              // --- Email Field với Shadow ---
              _buildShadowTextField(
                child: _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: SvgPicture.asset(
                    'assets/images/icon_email.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                  ),
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
    IconData? icon,
    Widget? prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: prefixIcon ?? (icon != null ? Icon(icon, color: Colors.grey[500], size: 20) : null),
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
        contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
        isDense: true,
      ),
    );
  }

  // Widget xây dựng trường nhập mật khẩu với khả năng ẩn/hiện
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscureText,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/images/icon_lock.svg',
            width: 20,
            height: 20,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        filled: false,
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
        contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
        isDense: true,
      ),
    );
  }

  // Widget tạo nút Login với Gradient
  Widget _buildGradientLoginButton(Color startColor, Color endColor) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleEmailLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Bỏ màu nền mặc định
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withOpacity(0.8),
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.zero, // Reset padding để sử dụng Ink
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading 
                ? [Colors.grey[400]!, Colors.grey[500]!] 
                : [startColor, endColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Container(
          height: 55.0, // Chiều cao cố định
          alignment: Alignment.center,
          child: _isLoading 
            ? SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ))
            : Text(
                'Login',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }

  // Widget tạo nút đăng nhập Google
  Widget _buildGoogleButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleLogin,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        height: 55.0,
        alignment: Alignment.center,
        child: _isLoading 
          ? SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[700],
              ))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/icon_google.svg',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'Sign in with Google',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // Widget xây dựng link Register Now
  Widget _buildRegisterNowLink(BuildContext context, Color accentColor) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        children: [
          TextSpan(text: 'Don\'t have an account? '),
          TextSpan(
            text: 'Register now',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Điều hướng đến màn hình Register
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