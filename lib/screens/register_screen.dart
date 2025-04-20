import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Controllers cho các trường nhập liệu
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _togglePasswordConfirmVisibility() {
    setState(() {
      _obscurePasswordConfirm = !_obscurePasswordConfirm;
    });
  }
  
  // Xử lý đăng ký bằng email/password
  Future<void> _handleEmailRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final passwordConfirm = _passwordConfirmController.text;
      
      // Kiểm tra dữ liệu đầu vào
      if (fullName.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
        setState(() {
          _errorMessage = 'All fields are required';
          _isLoading = false;
        });
        return;
      }
      
      if (password != passwordConfirm) {
        setState(() {
          _errorMessage = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }
      
      if (password.length < 6) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters';
          _isLoading = false;
        });
        return;
      }
      
      // Tạo username từ email
      final username = email.split('@')[0];
      
      // Lấy redirect URL từ .env nếu cần
      final redirectUrl = dotenv.env['BASE_URL'] != null
          ? '${dotenv.env['BASE_URL']}/auth/callback'
          : null;
      
      // Hiển thị đang đăng ký
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      // Gọi service để đăng ký
      final registrationInfo = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
        redirectUrl: redirectUrl,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (registrationInfo != null) {
        // Chuyển hướng sang màn hình OTP verification
        Navigator.pushReplacementNamed(
          context, 
          '/otp-verification',
          arguments: {
            'userId': registrationInfo.userId,
            'email': registrationInfo.email,
          }
        );
      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again later.';
        });
      }
    } catch (e) {
      final errorMsg = e.toString();
      String userFriendlyError = 'Registration failed. Please try again.';
      
      // Xử lý các trường hợp lỗi phổ biến
      if (errorMsg.contains('already exists')) {
        userFriendlyError = 'This email is already registered. Please try another email or login.';
      } else if (errorMsg.contains('foreign key constraint')) {
        userFriendlyError = 'Registration error: Unable to create account. Please try again later.';
      } else if (errorMsg.contains('value too long')) {
        userFriendlyError = 'One of the provided values is too long. Please shorten your input.';
      } else if (errorMsg.contains('network')) {
        userFriendlyError = 'Network error. Please check your internet connection and try again.';
      } else if (errorMsg.contains('auth_id')) {
        userFriendlyError = 'Authentication error. Please try again after a few moments.';
      }
      
      setState(() {
        _errorMessage = userFriendlyError;
        _isLoading = false;
      });
      
      // Log lỗi chi tiết để debug
      print('Registration error detail: $errorMsg');
    }
  }
  
  // Xử lý đăng ký bằng Google
  Future<void> _handleGoogleRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final user = await SupabaseService.signInWithGoogle(context);
      
      setState(() {
        _isLoading = false;
      });
      
      if (user != null) {
        // Đăng nhập/đăng ký Google thành công, chuyển đến trang chính
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryOrange = Color(0xFFFF5722);
    final Color lightOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Title Section ---
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register', // Đổi tiêu đề
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
                  'Welcome to be our members !', // Đổi text chào mừng
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

              // --- Full Name Field ---
              _buildShadowTextField(
                child: _buildNameField(),
              ),
              SizedBox(height: 20),

              // --- Email Field ---
              _buildShadowTextField(
                child: _buildEmailField(),
              ),
              SizedBox(height: 20),

              // --- Password Field ---
               _buildShadowTextField(
                 child: _buildPasswordField(),
               ),
              SizedBox(height: 20),

              // --- Password Confirm Field ---
              _buildShadowTextField(
                 child: _buildPasswordConfirmField(),
              ),
              SizedBox(height: 30),

              // --- Register Button ---
              _buildGradientRegisterButton(primaryOrange, lightOrange),
              SizedBox(height: 25),

              // --- "Or register with" Separator ---
              Text(
                'Or register with', // Đổi text separator
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

              // --- Login Now Link (thay vì Register Now) ---
              _buildLoginNowLink(context, primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Tương tự AuthScreen nhưng điều chỉnh) ---

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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Full Name',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/images/icon_person.svg',
            width: 20,
            height: 20,
          ),
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

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/images/icon_email.svg',
            width: 20,
            height: 20,
          ),
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
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
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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

  Widget _buildPasswordConfirmField() {
    return TextField(
      controller: _passwordConfirmController,
      obscureText: _obscurePasswordConfirm,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Confirm Password',
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
            _obscurePasswordConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: _togglePasswordConfirmVisibility,
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

  // Nút đăng ký với gradient
  Widget _buildGradientRegisterButton(Color startColor, Color endColor) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleEmailRegistration,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withOpacity(0.8),
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.zero,
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
          height: 55.0,
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
                'Register',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }

  // Nút đăng ký với Google
  Widget _buildGoogleButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleRegistration,
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
                  'Register with Google',
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

  // Link quay lại trang đăng nhập
  Widget _buildLoginNowLink(BuildContext context, Color accentColor) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        children: [
          TextSpan(text: 'Already have an account? '),
          TextSpan(
            text: 'Login now',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Quay lại màn hình đăng nhập
                Navigator.pop(context);
              },
          ),
        ],
      ),
    );
  }
} 