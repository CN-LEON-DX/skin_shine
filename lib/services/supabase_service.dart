import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skin_shine/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model cho thông tin OTP
class OtpRegistrationInfo {
  final String userId;
  final String otpCode;
  final String email;
  
  OtpRegistrationInfo({
    required this.userId,
    required this.otpCode,
    required this.email,
  });
}

class SupabaseService {
  static final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  // Hằng số cho thời gian hết hạn (15 phút = 15 * 60 giây)
  static const int SESSION_EXPIRY_SECONDS = 15 * 60;
  static const String LAST_ACTIVITY_KEY = 'last_activity_timestamp';

  // Khởi tạo Supabase
  static Future<void> initialize() async {
    await dotenv.load();
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  // Kiểm tra session xác thực khi khởi động ứng dụng
  static Future<void> checkAuthSessionOnStart() async {
    try {
      // Kiểm tra xem session hiện tại có hợp lệ hay không
      final session = _supabaseClient.auth.currentSession;
      
      if (session != null) {
        // Kiểm tra thời gian hoạt động cuối cùng
        final isSessionExpired = await _isSessionExpired();
        
        if (isSessionExpired) {
          // Nếu phiên đã hết hạn, đăng xuất người dùng
          await signOut();
          debugPrint('Session expired due to inactivity (15 minutes)');
          return;
        }
        
        // Lấy thời gian hết hạn của token
        final expiresAt = session.expiresAt;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        
        // Nếu token hết hạn, hoặc thời gian còn lại < 1 giờ 
        // mà không có thiết lập "nhớ đăng nhập", thì đăng xuất
        if (expiresAt != null && (expiresAt < now || (expiresAt - now < 3600))) {
          try {
            // Kiểm tra xem token có thể làm mới được không
            await _supabaseClient.auth.refreshSession();
            debugPrint('Session refreshed successfully');
            
            // Cập nhật thời gian hoạt động
            await _updateLastActivity();
          } catch (e) {
            // Nếu không thể làm mới token, đăng xuất người dùng
            await signOut();
            debugPrint('Session invalid, user signed out');
          }
        }
      }
    } catch (e) {
      // Nếu có lỗi, đảm bảo người dùng được đăng xuất
      await signOut();
      debugPrint('Auth check error: $e');
    }
  }

  // Cập nhật thời gian hoạt động cuối cùng
  static Future<void> _updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(LAST_ACTIVITY_KEY, now);
    } catch (e) {
      debugPrint('Error updating last activity: $e');
    }
  }

  // Kiểm tra xem phiên có hết hạn chưa (15 phút không hoạt động)
  static Future<bool> _isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(LAST_ACTIVITY_KEY);
      
      if (lastActivity == null) {
        return true; // Nếu không có hoạt động nào được ghi lại, coi như đã hết hạn
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (now - lastActivity) ~/ 1000;
      
      return elapsedSeconds > SESSION_EXPIRY_SECONDS;
    } catch (e) {
      debugPrint('Error checking session expiry: $e');
      return true; // Nếu có lỗi, coi như đã hết hạn
    }
  }

  // Đăng ký với email/password và trả về thông tin OTP
  static Future<OtpRegistrationInfo?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? redirectUrl,
  }) async {
    try {
      // Register auth user
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'email_confirm': false,
        },
        emailRedirectTo: redirectUrl,
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed: Unable to create auth user');
      }

      // Allow time for auth user creation
      await Future.delayed(Duration(seconds: 2));

      // Create profile and get OTP
      final result = await _supabaseClient.rpc(
        'register_user',
        params: {
          'p_auth_id': authResponse.user!.id,
          'p_email': email,
          'p_provider': 'email',
          'p_full_name': fullName,
          'p_username': username,
        },
      );

      if (result != null) {
        final userId = result['user_id'];
        final otpCode = result['otp_code'];
        
        // Send OTP email via Edge Function
        await _supabaseClient.functions.invoke(
          'send-otp-email',
          body: {'email': email, 'otp': otpCode, 'userId': userId},
        );

        return OtpRegistrationInfo(
          userId: userId,
          otpCode: otpCode,
          email: email,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Registration error: $e');
      throw Exception('Registration error: $e');
    }
  }

  // Đăng nhập với email/password
  static Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login failed');
      }

      // Cập nhật thời gian hoạt động sau khi đăng nhập thành công
      await _updateLastActivity();

      final userDetails = await getUserDetails();
      return userDetails;
    } on AuthException catch (e) {
      throw Exception('Login error: ${e.message}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Gửi email xác thực
  static Future<void> sendEmailVerification() async {
    try {
      await _supabaseClient.auth.resend(
        type: OtpType.email,
        email: _supabaseClient.auth.currentUser?.email,
      );
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Kiểm tra xem email đã được xác thực chưa
  static bool isEmailVerified() {
    return _supabaseClient.auth.currentUser?.emailConfirmedAt != null;
  }

  // Đăng nhập với Google
  static Future<UserModel?> signInWithGoogle(BuildContext context) async {
    try {
      // Đăng nhập với Google OAuth
      final authResponse = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: dotenv.env['OAUTH_REDIRECT_URL'],
      );

      if (!authResponse) {
        throw Exception('Google login failed');
      }

      // Kiểm tra đăng nhập thành công
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        // Đăng nhập chưa hoàn tất (có thể đang trong quá trình chuyển hướng)
        return null;
      }

      // Cập nhật thời gian hoạt động sau khi đăng nhập thành công
      await _updateLastActivity();

      // Gọi function handle_login để xử lý đăng nhập
      final result = await _supabaseClient.rpc(
        'handle_login',
        params: {
          'p_auth_id': user.id,
          'p_email': user.email,
          'p_provider': 'google',
          'p_provider_id': user.userMetadata?['sub'],
          'p_full_name': user.userMetadata?['full_name'],
          'p_avatar_url': user.userMetadata?['avatar_url'],
        },
      );

      final userDetails = await getUserDetails();
      return userDetails;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } on AuthException catch (e) {
      throw Exception('Auth error: ${e.message}');
    } catch (e) {
      throw Exception('Google login error: $e');
    }
  }

  // Lấy thông tin người dùng hiện tại
  static Future<UserModel?> getUserDetails() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Cập nhật thời gian hoạt động khi lấy thông tin người dùng
      await _updateLastActivity();

      // Gọi hàm get_user_details để lấy thông tin đầy đủ
      final response = await _supabaseClient.rpc(
        'get_user_details',
        params: {'p_auth_id': user.id},
      );

      if (response == null || response.isEmpty) return null;
      
      return UserModel.fromJson(response[0]);
    } catch (e) {
      debugPrint('Error getting user details: $e');
      return null;
    }
  }
  
  // Đăng xuất
  static Future<void> signOut() async {
    try {
      // Xóa thời gian hoạt động cuối
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LAST_ACTIVITY_KEY);
      
      // Đăng xuất khỏi Supabase
      await _supabaseClient.auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  // Tải lên avatar
  static Future<String?> uploadAvatar(Uint8List fileBytes, String fileExt) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final userData = await getUserDetails();
      if (userData == null) return null;

      // Cập nhật thời gian hoạt động
      await _updateLastActivity();

      final path = '${user.id}/avatar.$fileExt';
      await _supabaseClient.storage.from('avatars').uploadBinary(path, fileBytes);
      
      final avatarUrl = _supabaseClient.storage.from('avatars').getPublicUrl(path);
      
      // Cập nhật avatar URL trong profile bằng function
      final result = await _supabaseClient.rpc(
        'update_user_profile',
        params: {
          'p_user_id': userData.userId,
          'p_avatar_url': avatarUrl,
        },
      );
      
      return avatarUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }
  
  // Kiểm tra trạng thái đăng nhập
  static Future<bool> isAuthenticated() async {
    final user = _supabaseClient.auth.currentUser;
    final session = _supabaseClient.auth.currentSession;
    
    if (user == null || session == null) {
      return false;
    }
    
    // Kiểm tra xem phiên có hết hạn do không hoạt động không
    final isSessionExpired = await _isSessionExpired();
    if (isSessionExpired) {
      // Nếu phiên đã hết hạn, đăng xuất người dùng
      await signOut();
      debugPrint('Session expired due to inactivity (15 minutes)');
      return false;
    }
    
    // Kiểm tra thời gian hết hạn của token
    final expiresAt = session.expiresAt;
    if (expiresAt == null) {
      return false;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Nếu token vẫn còn hiệu lực, cập nhật thời gian hoạt động
    if (expiresAt > now) {
      await _updateLastActivity();
      return true;
    }
    
    return false;
  }
  
  // Phương thức này được gọi khi người dùng tương tác với ứng dụng
  static Future<void> updateUserActivity() async {
    // Chỉ cập nhật nếu người dùng đã đăng nhập
    if (_supabaseClient.auth.currentUser != null) {
      await _updateLastActivity();
    }
  }

  // Xác thực OTP
  static Future<bool> verifyOtp({
    required String userId,
    required String otpCode,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'verify_otp',
        params: {
          'p_user_id': userId,
          'p_otp_code': otpCode,
        },
      );
      
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  // Gửi lại OTP
  static Future<String?> resendOtp({
    required String userId,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'resend_otp',
        params: {
          'p_user_id': userId,
        },
      );
      
      if (response != null && response['success'] == true) {
        return response['otp_code'] as String?;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error resending OTP: $e');
      return null;
    }
  }

  // Add to SupabaseService
  static Future<bool> doesAccountExist(String userId) async {
    try {
      final response = await _supabaseClient.rpc(
        'check_user_exists',
        params: {'p_user_id': userId},
      );
      
      return response != null && response == true;
    } catch (e) {
      debugPrint('Error checking if account exists: $e');
      return false;
    }
  }
} 