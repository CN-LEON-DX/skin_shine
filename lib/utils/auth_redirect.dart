import 'package:flutter/material.dart';
import 'package:skin_shine/services/supabase_service.dart';

class AuthRedirect extends StatefulWidget {
  final Widget child;
  
  const AuthRedirect({
    Key? key, 
    required this.child,
  }) : super(key: key);

  @override
  _AuthRedirectState createState() => _AuthRedirectState();
}

class _AuthRedirectState extends State<AuthRedirect> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    // Kiểm tra xem người dùng đã đăng nhập chưa
    final isAuthenticated = await SupabaseService.isAuthenticated();
    
    // Nếu đã đăng nhập, chuyển hướng đến trang chính
    if (isAuthenticated) {
      // Kiểm tra thêm bằng cách lấy thông tin người dùng
      final user = await SupabaseService.getUserDetails();
      
      if (user != null && mounted) {
        Future.microtask(() => 
          Navigator.of(context).pushReplacementNamed('/home')
        );
        return;
      }
    }
    
    // Nếu chưa đăng nhập, cho phép hiển thị màn hình con (login/register)
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
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
    
    // Nếu đã kiểm tra xong và người dùng chưa đăng nhập, hiển thị màn hình con
    return widget.child;
  }
} 