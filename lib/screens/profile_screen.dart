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
  // TextControllers for edit profile dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // TextControllers for change password dialog
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
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

  // Initialize controllers in initState
  @override
  void initState() {
    super.initState();
    _nameController.text = userName;
    _emailController.text = userEmail;
    _phoneController.text = '+84 123 456 789'; // Example default value
  }

  // Clean up controllers in dispose
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                  onTap: () {
                    _showChangePasswordDialog(context, primaryColor);
                  },
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
               onPressed: () {
                 _showEditProfileDialog(context, primaryColor);
               },
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

  // Show Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context, Color primaryColor) {
    // Variable to track if user has selected a new image
    bool hasSelectedNewImage = false;
    // Temp variable to hold the current image URL
    String tempProfileImageUrl = profileImageUrl;
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(Icons.person_outline, color: primaryColor),
                  SizedBox(width: 10),
                  Text('Edit Profile', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Image Section
                    Center(
                      child: Stack(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: hasSelectedNewImage 
                              ? AssetImage('assets/images/placeholder.png') // Replace with actual image handling
                              : NetworkImage(tempProfileImageUrl) as ImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              print("Error loading profile image: $exception");
                            },
                          ),
                          // Edit Icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Here you would implement image picker
                                setState(() {
                                  hasSelectedNewImage = true;
                                  // In a real app, you would update tempProfileImageUrl with the new image
                                  // For demo, we just toggle a flag
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Image picker would open here'))
                                );
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Form Fields
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  onPressed: () {
                    // Reset controllers to original values
                    _nameController.text = userName;
                    _emailController.text = userEmail;
                    _phoneController.text = '+84 123 456 789';
                    Navigator.of(ctx).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Here you would save the changes to your database
                    print('Profile updated with: ${_nameController.text}, ${_emailController.text}, ${_phoneController.text}');
                    // Also save the new profile picture if selected
                    if (hasSelectedNewImage) {
                      print('New profile picture would be saved');
                    }
                    
                    // For demo just show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile information updated successfully!'))
                    );
                    
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Show Change Password Dialog
  void _showChangePasswordDialog(BuildContext context, Color primaryColor) {
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(Icons.lock_outline, color: primaryColor),
                  SizedBox(width: 10),
                  Text('Change Password', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  onPressed: () {
                    // Clear password fields
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    Navigator.of(ctx).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Validate password inputs
                    if (_currentPasswordController.text.isEmpty ||
                        _newPasswordController.text.isEmpty ||
                        _confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all password fields'))
                      );
                      return;
                    }
                    
                    // Check if new passwords match
                    if (_newPasswordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('New passwords do not match'))
                      );
                      return;
                    }
                    
                    // Here you would verify the current password and update it in your database
                    print('Password changed successfully');
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully!'))
                    );
                    
                    // Clear fields and close dialog
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }
} 