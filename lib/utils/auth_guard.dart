import 'package:flutter/material.dart';
import 'package:skin_shine/services/supabase_service.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool emailVerificationRequired;
  
  const AuthGuard({
    Key? key, 
    required this.child,
    this.emailVerificationRequired = false,
  }) : super(key: key);

  @override
  _AuthGuardState createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _initialized = false;
  bool _authenticated = false;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Kiểm tra trạng thái xác thực hiện tại
    final isAuthenticated = await SupabaseService.isAuthenticated();
    
    // Nếu người dùng đã đăng nhập, kiểm tra thêm các điều kiện khác
    if (isAuthenticated) {
      // Kiểm tra tính hợp lệ của session bằng cách thử lấy thông tin người dùng
      final user = await SupabaseService.getUserDetails();
      final isEmailVerified = SupabaseService.isEmailVerified();
      
      setState(() {
        _initialized = true;
        _authenticated = user != null; // Chỉ coi là đã xác thực nếu lấy được thông tin người dùng
        _emailVerified = isEmailVerified;
      });
      
      // Nếu không lấy được thông tin người dùng, session không hợp lệ
      if (user == null) {
        debugPrint('Auth session invalid: could not get user details');
        // Đăng xuất và chuyển hướng đến trang đăng nhập
        await SupabaseService.signOut();
        if (mounted) {
          Future.microtask(() => 
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false)
          );
        }
        return;
      }
      
      // Nếu cần xác thực email nhưng email chưa được xác thực
      if (widget.emailVerificationRequired && !isEmailVerified) {
        if (mounted) {
          Future.microtask(() => _showVerificationNeededDialog());
        }
        return;
      }
    } else {
      // Nếu chưa đăng nhập, cập nhật trạng thái và chuyển hướng
      setState(() {
        _initialized = true;
        _authenticated = false;
        _emailVerified = false;
      });
      
      if (mounted) {
        Future.microtask(() => 
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false)
        );
      }
    }
  }
  
  void _showVerificationNeededDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Verification Required'),
        content: Text('Please verify your email address before accessing this page. Check your inbox for a verification link.'),
        actions: [
          TextButton(
            onPressed: () async {
              await SupabaseService.sendEmailVerification();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification email sent again'))
              );
            },
            child: Text('Resend Verification'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading trong khi đang kiểm tra trạng thái xác thực
    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Nếu đã xác thực và không cần xác thực email hoặc email đã được xác thực
    if (_authenticated && (!widget.emailVerificationRequired || _emailVerified)) {
      return widget.child;
    }
    
    // Nếu chưa xác thực hoặc cần xác thực email nhưng email chưa được xác thực
    // Hiển thị trang loading trong khi chờ điều hướng
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 