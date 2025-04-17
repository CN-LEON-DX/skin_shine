import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import painter từ auth_screen để tái sử dụng
import 'auth_screen.dart' show GoogleLogoPainter;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

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
                  'Wellcome to be our members !', // Đổi text chào mừng
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 40),

              // --- Full Name Field ---
              _buildShadowTextField(
                child: _buildTextField(
                  hintText: 'Full Name',
                  icon: Icons.person_outline, // Icon người
                  keyboardType: TextInputType.name,
                ),
              ),
              SizedBox(height: 20),

              // --- Email Field ---
              _buildShadowTextField(
                child: _buildTextField(
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
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
    return _buildTextField(
      hintText: 'Password',
      icon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey[500],
          size: 20,
        ),
        onPressed: _togglePasswordVisibility,
        splashRadius: 20,
      ),
    );
  }

   Widget _buildPasswordConfirmField() {
    return _buildTextField(
      hintText: 'Password Confirm',
      icon: Icons.lock_outline,
      obscureText: _obscurePasswordConfirm,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePasswordConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey[500],
          size: 20,
        ),
        onPressed: _togglePasswordConfirmVisibility,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildGradientRegisterButton(Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          print('Register button pressed');
          // Xử lý logic đăng ký
          // Ví dụ: chuyển về trang login sau khi đăng ký thành công
          Navigator.pop(context); // Quay lại màn hình trước đó (Login)
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration Successful! Please Login.'))
           );
        },
        child: Text(
          'REGISTER',
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
        side: BorderSide(color: Colors.grey.shade200, width: 1.0),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 24,
            width: 24,
            child: CustomPaint(painter: GoogleLogoPainter()), // Tái sử dụng Painter
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

  // Link để quay lại trang Login
  Widget _buildLoginNowLink(BuildContext context, Color highlightColor) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        children: <TextSpan>[
          TextSpan(text: "Already have an account? "),
          TextSpan(
            text: 'Login Now',
            style: GoogleFonts.poppins(
              color: highlightColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print('Login Now tapped');
                Navigator.pop(context); // Quay lại màn hình Login
              },
          ),
        ],
      ),
    );
  }
} 