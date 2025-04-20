import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_shine/services/supabase_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;
  
  const OtpVerificationScreen({
    Key? key,
    required this.userId,
    required this.email,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6, 
    (index) => TextEditingController()
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, 
    (index) => FocusNode()
  );
  
  bool _isLoading = false;
  String _errorMessage = '';
  int _resendCounter = 180; // 3 phút in seconds
  Timer? _resendTimer;
  
  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }
  
  @override
  void dispose() {
    _otpControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCounter > 0) {
          _resendCounter--;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
  }
  
  String _formatTimeLeft() {
    int minutes = _resendCounter ~/ 60;
    int seconds = _resendCounter % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _verifyOtp() async {
    // Tạo chuỗi OTP từ các controller
    final otp = _otpControllers.map((c) => c.text).join();
    
    // Kiểm tra nếu OTP chưa đủ 6 chữ số
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final isVerified = await SupabaseService.verifyOtp(
        userId: widget.userId, 
        otpCode: otp
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (isVerified) {
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP code. Please check and try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
  
  Future<void> _resendOtp() async {
    if (_resendCounter > 0) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final newOtp = await SupabaseService.resendOtp(userId: widget.userId);
      
      setState(() {
        _isLoading = false;
      });
      
      if (newOtp != null) {
        // Reset counter and start timer again
        setState(() {
          _resendCounter = 180; // 3 minutes
          _startResendTimer();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New OTP code sent to ${widget.email}'),
            backgroundColor: Colors.green,
          )
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to resend OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Account Verified!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your account has been successfully verified.',
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 8),
              Text(
                'You can now login to your account.',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Chuyển hướng đến trang đăng nhập
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Go to Login',
                style: GoogleFonts.poppins(
                  color: Color(0xFFFF5722),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryOrange = Color(0xFFFF5722);
    final Color lightOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'OTP Verification',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verification instructions
              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              
              Text(
                'We have sent a 6-digit verification code to:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              
              Text(
                widget.email,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              
              // OTP Input Fields
              _buildOtpInputRow(),
              SizedBox(height: 20),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 30),
              
              // Verify Button
              _buildGradientVerifyButton(primaryOrange, lightOrange),
              SizedBox(height: 25),
              
              // Resend OTP option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  _resendCounter > 0 
                    ? Text(
                        _formatTimeLeft(),
                        style: GoogleFonts.poppins(
                          color: primaryOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )
                    : GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: GoogleFonts.poppins(
                            color: primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOtpInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => _buildOtpDigitBox(index),
      ),
    );
  }
  
  Widget _buildOtpDigitBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Auto jump to next or previous field
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
  
  Widget _buildGradientVerifyButton(Color startColor, Color endColor) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _verifyOtp,
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
                'Verify',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }
} 