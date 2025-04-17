import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider
import '../providers/theme_provider.dart'; // Import ThemeProvider

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Trạng thái giả lập cho các cài đặt (ví dụ) ---
  String selectedLanguage = 'English';
  bool faceIdEnabled = true;
  bool photoRemindersEnabled = true;
  bool skincareTipsEnabled = true;
  bool consultationRemindersEnabled = false;

  // Dữ liệu người dùng giả lập
  final String userName = 'Sarah Johnson';
  final String userEmail = 'sarah.j@email.com';
  final String profileImageUrl = 'https://via.placeholder.com/150/aabbcc/000000?text=Sarah'; // Thay bằng URL ảnh thật

  // Hàm xử lý logout (hiển thị dialog xác nhận)
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
             children: [
               Icon(Icons.logout_outlined, color: Colors.redAccent),
               SizedBox(width: 10),
               Text('Confirm Logout'),
             ],
          ),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng dialog
              },
            ),
            ElevatedButton(
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // --- THỰC HIỆN LOGIC LOGOUT THỰC TẾ TẠI ĐÂY ---
                // Ví dụ: Xóa token, xóa lưu trữ đăng nhập, etc.
                print('User logged out!');
                
                // Đóng dialog
                Navigator.of(ctx).pop();
                
                // Hiện thông báo đã đăng xuất
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully!'), duration: Duration(seconds: 2))
                );
                
                // Điều hướng về màn hình login
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', 
                  (Route<dynamic> route) => false // Xóa tất cả route trước đó
                );
              },
            ),
          ],
        );
      },
    );
  }


   // Hàm xử lý xoá tài khoản (hiển thị dialog xác nhận)
   // (Giữ lại từ yêu cầu trước, có thể hữu ích)
  void _handleDeleteAccount(BuildContext context) {
     showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Account?'),
            ],
          ),
          content: Text('This action is permanent and cannot be undone. Are you absolutely sure?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // --- THỰC HIỆN LOGIC XÓA TÀI KHOẢN THỰC TẾ TẠI ĐÂY ---
                print('Account deletion initiated!');
                Navigator.of(ctx).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Account deletion process started (logic not implemented).'))
                 );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Lấy theme provider và các màu/style từ theme hiện tại
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final subtleTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey.shade600;
    final sectionTitleColor = theme.textTheme.titleLarge?.color ?? Colors.black.withOpacity(0.8);
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final iconColor = theme.iconTheme.color ?? Colors.grey[600];
    final scaffoldBgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar( // AppBar sẽ tự động cập nhật màu theo theme
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20), // Lấy màu từ AppBar theme
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Profile'), // Style tự động lấy từ AppBar theme
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Card Thông tin Tài khoản (Cập nhật màu)
            _buildProfileInfoCard(context, primaryColor, subtleTextColor, cardColor, iconColor),
            const SizedBox(height: 16),

            // --- Card Cài đặt Giao diện (THÊM MỚI) ---
             _buildSettingsCard(
              context: context,
              title: 'Appearance',
              titleColor: sectionTitleColor,
              cardColor: cardColor,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildThemeSelector(themeProvider),
                ),
              ]
            ),
            const SizedBox(height: 16),

            // --- Card Cài đặt Chung (Cập nhật màu) ---
            _buildSettingsCard(
              context: context,
              title: 'General Settings',
              titleColor: sectionTitleColor,
              cardColor: cardColor,
              children: [
                _buildNavRow(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () { print('Navigate to Change Password'); },
                  iconColor: iconColor,
                ),
                 _buildDivider(dividerColor),
                _buildNavRow(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailingText: selectedLanguage,
                  onTap: () {
                     print('Change language tapped');
                      _showLanguagePicker(context);
                  },
                   iconColor: iconColor,
                ),
              ],
            ),
            const SizedBox(height: 16),

             // --- Card Thông báo (Cập nhật màu) ---
             _buildSettingsCard(
               context: context,
               title: 'Notifications',
               titleColor: sectionTitleColor,
               cardColor: cardColor,
               children: [
                 _buildSwitchRow(
                    context,
                    icon: Icons.notifications_active_outlined,
                    title: 'Photo Reminders',
                    value: photoRemindersEnabled,
                    onChanged: (value) => setState(() => photoRemindersEnabled = value),
                    activeColor: primaryColor,
                    iconColor: iconColor,
                 ),
                  _buildDivider(dividerColor),
                 _buildSwitchRow(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: 'Skincare Tips',
                    value: skincareTipsEnabled,
                    onChanged: (value) => setState(() => skincareTipsEnabled = value),
                    activeColor: primaryColor,
                     iconColor: iconColor,
                 ),
                  _buildDivider(dividerColor),
                  _buildSwitchRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Consultation Reminders',
                    value: consultationRemindersEnabled,
                    onChanged: (value) => setState(() => consultationRemindersEnabled = value),
                    activeColor: primaryColor,
                     iconColor: iconColor,
                 ),
               ],
             ),
              const SizedBox(height: 16),


            // --- Card Bảo mật & Quyền riêng tư (Cập nhật màu) ---
            _buildSettingsCard(
              context: context,
              title: 'Privacy & Security',
              titleColor: sectionTitleColor,
              cardColor: cardColor,
              children: [
                _buildNavRow(
                  context,
                  icon: Icons.photo_library_outlined,
                  title: 'Manage Photos',
                  onTap: () { print('Navigate to Manage Photos'); },
                   iconColor: iconColor,
                ),
                 _buildDivider(dividerColor),
                _buildSwitchRow(
                  context,
                  icon: Icons.face_retouching_natural,
                  title: 'Use Face ID Login',
                  value: faceIdEnabled,
                  onChanged: (value) => setState(() => faceIdEnabled = value),
                  activeColor: primaryColor,
                   iconColor: iconColor,
                ),
                _buildDivider(dividerColor),
                _buildNavRow(
                  context,
                  icon: Icons.storage_outlined,
                  title: 'Data & Storage',
                  onTap: () { print('Navigate to Data & Storage'); },
                   iconColor: iconColor,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- Nút Logout (Style từ Theme) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: OutlinedButton.icon(
                icon: Icon(Icons.logout, size: 20),
                label: Text('Logout'),
                onPressed: () => _handleLogout(context),
                style: theme.outlinedButtonTheme.style?.copyWith(
                   foregroundColor: MaterialStateProperty.all(Colors.redAccent),
                   side: MaterialStateProperty.all(
                     BorderSide(color: Colors.redAccent.withOpacity(0.5))
                   ),
                   padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 14)),
                   shape: MaterialStateProperty.all(RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                   )),
                ),
              ),
            ),
             const SizedBox(height: 10),


            // --- Nút Delete Account (Style từ Theme) ---
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                 onPressed: () => _handleDeleteAccount(context),
                 child: Text(
                   'Delete Account',
                   style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                 ),
                 style: theme.textButtonTheme.style?.copyWith(
                   padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10)),
                   // Giữ màu xám riêng cho nút này
                   foregroundColor: MaterialStateProperty.all(Colors.grey[500]),
                 )
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders (Cập nhật để nhận màu từ theme) ---

  // Card chứa thông tin profile cơ bản
  Widget _buildProfileInfoCard(BuildContext context, Color primaryColor, Color subtleTextColor, Color cardColor, Color? iconColor) {
    return Card(
      color: cardColor,
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[200], // Giữ nền sáng cho ảnh
              backgroundImage: NetworkImage(profileImageUrl),
               onBackgroundImageError: (exception, stackTrace) {
                  print("Error loading profile image: $exception");
               },
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName, // Style lấy từ theme
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subtleTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
             const SizedBox(width: 10),
            IconButton(
               icon: Icon(Icons.edit_outlined, color: primaryColor, size: 22),
               tooltip: 'Edit Profile',
               onPressed: () { print('Edit profile info tapped'); },
               splashRadius: 24,
               constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }


  // Card chung cho các nhóm cài đặt
  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required Color? titleColor,
    required Color cardColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 1.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor),
              ),
            ),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  // Divider tùy chỉnh mỏng hơn
  Widget _buildDivider(Color? dividerColor) {
     return Divider(height: 0.5, thickness: 0.5, color: dividerColor);
  }


  // Hàng điều hướng
  Widget _buildNavRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge;
    final trailingTextStyle = theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]);
    final chevronColor = Colors.grey[400];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
             Icon(icon, color: iconColor, size: 22),
             const SizedBox(width: 15),
             Expanded(
               child: Text(title, style: textStyle),
             ),
             if (trailingText != null)
               Text(trailingText, style: trailingTextStyle),
             const SizedBox(width: 8),
             Icon(Icons.chevron_right, color: chevronColor, size: 20),
          ],
        ),
      ),
    );
  }

  // Hàng có nút Switch
  Widget _buildSwitchRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color? activeColor,
    required Color? iconColor,
  }) {
     final theme = Theme.of(context);
     final textStyle = theme.textTheme.bodyLarge;

     return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
             Icon(icon, color: iconColor, size: 22),
             const SizedBox(width: 15),
             Expanded(
               child: Text(title, style: textStyle),
             ),
             Switch(
               value: value,
               onChanged: onChanged,
               activeColor: activeColor, // Lấy từ theme chính
               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
             ),
          ],
        ),
      );
  }

   // Widget chọn Theme (THÊM MỚI)
   Widget _buildThemeSelector(ThemeProvider themeProvider) {
    // Sử dụng SegmentedButton để chọn giữa System, Light, Dark
    return SegmentedButton<ThemeMode>(
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.wb_sunny_outlined, size: 18),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.nightlight_round_outlined, size: 18),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.settings_brightness_outlined, size: 18),
        ),
      ],
      selected: <ThemeMode>{themeProvider.themeMode}, // Lấy giá trị hiện tại từ provider
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        // Cập nhật theme khi người dùng chọn
        themeProvider.setThemeMode(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        // Điều chỉnh style cho phù hợp theme
        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        // Có thể cần thêm điều chỉnh style khác
      ),
       showSelectedIcon: false,
    );
   }

   // Hiển thị dialog chọn ngôn ngữ
  void _showLanguagePicker(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text('Select Language'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  setState(() => selectedLanguage = 'English');
                  Navigator.pop(ctx);
                },
                child: Text('English'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() => selectedLanguage = 'Tiếng Việt');
                  Navigator.pop(ctx);
                },
                child: Text('Tiếng Việt'),
              ),
              SimpleDialogOption(
                onPressed: () {
                   setState(() => selectedLanguage = 'Español');
                   Navigator.pop(ctx);
                 },
                child: Text('Español'),
              ),
            ],
          );
        });
  }
} 