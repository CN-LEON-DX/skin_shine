import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'providers/theme_provider.dart'; // Import ThemeProvider
import 'screens/skin_progress_screen.dart';
import 'widgets/bottom_bar.dart';
import 'screens/product_suggestions_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/consultation_screen.dart'; // Thêm import trang Consultation
import 'package:google_fonts/google_fonts.dart'; // Thêm import Google Fonts
import '../models/daily_content.dart';
import '../screens/content_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/auth_guard.dart';
import 'utils/activity_observer.dart';
import 'screens/otp_verification_screen.dart';
// import 'package:flutter/ui/painting/hsl_color.dart'; // Đã xóa dòng này

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Supabase
  await SupabaseService.initialize();
  
  // Kiểm tra xác thực khi khởi động
  await SupabaseService.checkAuthSessionOnStart();
  
  // Kiểm tra trạng thái đăng nhập
  final isAuthenticated = await SupabaseService.isAuthenticated();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(isUserAuthenticated: isAuthenticated), 
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserAuthenticated;
  
  const MyApp({
    super.key, 
    required this.isUserAuthenticated,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppMaterial(isUserAuthenticated: isUserAuthenticated);
  }
}

class AppMaterial extends StatelessWidget {
  final bool isUserAuthenticated;
  
  const AppMaterial({
    super.key,
    required this.isUserAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy theme provider Ở ĐÂY (context này nằm dưới Provider)
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Định nghĩa ThemeData cho light mode
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.apply(bodyColor: Colors.black87, displayColor: Colors.black87)), // Đảm bảo màu chữ mặc định
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[200],
      iconTheme: IconThemeData(color: Colors.grey[600]),
       textButtonTheme: TextButtonThemeData(
         style: TextButton.styleFrom(foregroundColor: Colors.black87)
       ),
       outlinedButtonTheme: OutlinedButtonThemeData(
         style: OutlinedButton.styleFrom(
           foregroundColor: Colors.black87,
           side: BorderSide(color: Colors.grey[300]!)
         )
       ),
      // ... các cấu hình khác cho light theme
    );

    // Định nghĩa ThemeData cho dark mode
    final darkTheme = ThemeData(
       brightness: Brightness.dark,
       primarySwatch: Colors.purple,
       visualDensity: VisualDensity.adaptivePlatformDensity,
       scaffoldBackgroundColor: Colors.grey[900],
       textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.apply(bodyColor: Colors.white70, displayColor: Colors.white70)),
       appBarTheme: AppBarTheme(
         backgroundColor: Colors.grey[850],
         elevation: 1,
         iconTheme: IconThemeData(color: Colors.white70),
         titleTextStyle: GoogleFonts.poppins(
           fontSize: 18,
           fontWeight: FontWeight.w600,
           color: Colors.white70,
         ),
       ),
       cardColor: Colors.grey[800],
       dividerColor: Colors.grey[700],
       iconTheme: IconThemeData(color: Colors.white70),
       textButtonTheme: TextButtonThemeData(
         style: TextButton.styleFrom(foregroundColor: Colors.white70)
       ),
       outlinedButtonTheme: OutlinedButtonThemeData(
         style: OutlinedButton.styleFrom(
           foregroundColor: Colors.white70,
           side: BorderSide(color: Colors.grey[700]!)
         )
       ),
       // ... các cấu hình khác cho dark theme
    );

    return MaterialApp(
      title: 'Skin Shine',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: isUserAuthenticated ? '/home' : '/login',
      navigatorObservers: [
        ActivityObserver(), // Thêm observer để theo dõi hoạt động
      ],
      routes: {
        '/login': (context) => AuthScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/otp-verification': (context) {
          // Nhận tham số từ arguments
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpVerificationScreen(
            userId: args['userId'],
            email: args['email'],
          );
        },
        '/home': (context) => UserActivityDetector(
          child: AuthGuard(child: HomeScreen())
        ),
        '/cart': (context) => UserActivityDetector(
          child: AuthGuard(child: CartScreen())
        ),
      },
      // Thêm onGenerateRoute để xử lý các route không có trong danh sách routes
      onGenerateRoute: (settings) {
        // Danh sách các route không cần xác thực
        final unprotectedRoutes = ['/login', '/register', '/forgot-password'];
        
        // Nếu route không cần xác thực, cho phép truy cập
        if (unprotectedRoutes.contains(settings.name)) {
          return null;
        }
        
        // Các route khác đều yêu cầu xác thực
        Widget page;
        
        switch (settings.name) {
          case '/camera':
            page = CameraScreen();
            break;
          case '/profile':
            page = ProfileScreen();
            break;
          case '/consultation':
            page = ConsultationScreen();
            break;
          case '/product-suggestions':
            page = ProductSuggestionsScreen();
            break;
          case '/skin-progress':
            page = SkinProgressScreen();
            break;
          default:
            page = HomeScreen();
        }
        
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => UserActivityDetector(
            child: AuthGuard(
              child: page,
              emailVerificationRequired: true,
            ),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- HomeScreen --- (Không thay đổi logic trong state)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Dữ liệu giả lập cho Daily Content ---
  final List<DailyContent> _dailyContents = [
    DailyContent(
      title: 'Morning Routine Skincare',
      shortDescription: 'Start your day with a fresh glow!',
      type: DailyContentType.tip,
      fullContent: 'A good morning routine sets the tone for your skin all day. Start with a gentle cleanser suitable for your skin type. Follow up with a hydrating toner to balance pH levels. Apply a Vitamin C serum for antioxidant protection and brightening. Don\'t forget a moisturizer to lock in hydration, and finish with a broad-spectrum sunscreen (SPF 30 or higher) - this is the most crucial step!',
      imageUrl: 'https://via.placeholder.com/300/FFE0B2/000000?text=Morning+Routine' // Ảnh minh họa
    ),
    DailyContent(
      title: 'New Product Alert: HydraBoost Serum',
      shortDescription: 'Intense hydration for thirsty skin.',
      type: DailyContentType.product,
      fullContent: 'Introducing HydraBoost Serum! Packed with hyaluronic acid and natural botanicals, this serum deeply hydrates and plumps the skin, reducing the appearance of fine lines. Suitable for all skin types. Apply after cleansing and toning, before moisturizer. Find it now in our Products section!',
      imageUrl: 'https://via.placeholder.com/300/81D4FA/FFFFFF?text=HydraBoost+Serum'
    ),
    DailyContent(
      title: 'Expert Advice: Importance of Exfoliation',
      shortDescription: 'Dr. Evelyn Reed explains why exfoliation matters.',
      type: DailyContentType.expert,
      expertName: 'Dr. Evelyn Reed',
      fullContent: 'Dr. Evelyn Reed, a renowned dermatologist, emphasizes the importance of regular exfoliation. \"Exfoliation removes dead skin cells, unclogs pores, and allows better absorption of skincare products,\" she explains. \"However, over-exfoliation can damage the skin barrier. Choose the right method (chemical or physical) for your skin type and limit it to 1-3 times per week.\" Listen to your skin and adjust accordingly.',
      imageUrl: 'https://via.placeholder.com/300/CE93D8/FFFFFF?text=Dr.+Reed'
    ),
     DailyContent(
      title: 'Tip: Don\'t Neglect Your Neck!',
      shortDescription: 'Extend your skincare routine downwards.',
      type: DailyContentType.tip,
      fullContent: 'The skin on your neck is delicate and often shows signs of aging sooner than the face. Remember to apply your cleanser, serum, moisturizer, and sunscreen to your neck and décolletage area as well to keep it looking youthful and healthy.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: _buildGreetingSection(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildSkinScoreCard(),
                        const SizedBox(height: 25),
                        _buildActionButtonsGrid(),
                        const SizedBox(height: 30),
                        _buildDailyInsightsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: BottomBar(
                onCameraPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng phần Chào hỏi
  Widget _buildGreetingSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final IconData timeIcon = isDarkMode ? Icons.nightlight_round_outlined : Icons.wb_sunny_outlined;
    final Color iconBgColor = isDarkMode ? Colors.blueGrey[700]! : Colors.orange[100]!;
    final Color iconColor = isDarkMode ? Colors.yellow[200]! : Colors.orange[800]!;
    final String greetingText = isDarkMode ? 'Good evening !' : 'Good morning !';
    final Color textColor = theme.textTheme.bodyLarge?.color ?? (isDarkMode ? Colors.white70 : Colors.black87);
    final Color subTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey[600]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(timeIcon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Sarah!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  greetingText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[isDarkMode ? 700 : 300],
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

 // Widget xây dựng thẻ Điểm Số Da
  Widget _buildSkinScoreCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? Colors.purple[900]?.withOpacity(0.5) : Colors.purple[50]?.withOpacity(0.5);
    final borderColor = isDarkMode ? Colors.purple.shade700 : Colors.purple.shade100;
    final scoreColor = isDarkMode ? Colors.purple[200] : Colors.purple[800];
    final titleColor = isDarkMode ? Colors.purple[300] : Colors.purple[700];
    final iconBg = isDarkMode ? Colors.purple[700] : Colors.purple[100];

     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Skin Score:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '8.5/10',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_upward,
              color: titleColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng lưới các nút chức năng
  Widget _buildActionButtonsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildActionButton(
          icon: Icons.camera_alt_outlined,
          label: 'Analyze skin',
          baseColor: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.show_chart_outlined,
          label: 'Track progress',
          baseColor: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SkinProgressScreen())
            );
          },
        ),
        _buildActionButton(
          icon: Icons.science_outlined,
          label: 'Products',
          baseColor: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductSuggestionsScreen()),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.people_outline,
          label: 'Consultation',
          baseColor: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConsultationScreen()),
            );
          },
        ),
      ],
    );
  }

  // Widget trợ giúp để xây dựng một nút chức năng trong GridView
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color baseColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color lightShade = HSLColor.fromColor(baseColor).withLightness(0.95).toColor();
    final Color darkShade = HSLColor.fromColor(baseColor).withLightness(0.3).toColor();
    final Color darkIconShade = HSLColor.fromColor(baseColor).withLightness(0.8).toColor();

    final Color bgColor = isDarkMode ? darkShade : lightShade;
    final Color iconColor = isDarkMode ? darkIconShade : baseColor;
    final Color labelColor = theme.textTheme.bodyLarge?.color ?? (isDarkMode ? Colors.white70 : Colors.black87);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Widget xây dựng phần Daily Insights
  Widget _buildDailyInsightsSection() {
     final theme = Theme.of(context);
     final sectionTitleColor = theme.textTheme.titleLarge?.color ?? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87);

     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Insights',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: sectionTitleColor,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _dailyContents.length,
          itemBuilder: (context, index) {
            return _buildContentCard(_dailyContents[index]);
          },
        ),
      ],
    );
  }

  // Widget xây dựng một card nội dung
  Widget _buildContentCard(DailyContent content) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final titleColor = theme.textTheme.titleMedium?.color ?? (isDarkMode ? Colors.white : Colors.black87);
    final subTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey[isDarkMode ? 400 : 700]!;
    final iconColor = _getIconColorForType(content.type, theme);
    final iconData = _getIconDataForType(content.type);

    return Card(
       margin: const EdgeInsets.only(bottom: 15.0),
       color: cardColor,
       elevation: 1.5,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
       child: InkWell(
         borderRadius: BorderRadius.circular(15),
         onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => ContentDetailScreen(content: content),
             ),
           );
         },
         child: Padding(
           padding: const EdgeInsets.all(15.0),
           child: Row(
             children: [
               Container(
                 padding: EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: iconColor.withOpacity(0.15),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(iconData, color: iconColor, size: 28),
               ),
               const SizedBox(width: 15),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    Text(
                      content.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      content.shortDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
               ),
               )
             ],
           ),
         ),
       ),
    );
  }

  // Hàm helper để lấy IconData dựa trên type
  IconData _getIconDataForType(DailyContentType type) {
    switch (type) {
      case DailyContentType.tip:
        return Icons.lightbulb_outline;
      case DailyContentType.product:
        return Icons.shopping_bag_outlined;
      case DailyContentType.expert:
        return Icons.person_pin_outlined;
    }
  }

  // Hàm helper để lấy màu Icon dựa trên type và theme
  Color _getIconColorForType(DailyContentType type, ThemeData theme) {
    // Có thể điều chỉnh màu sắc cho dark theme nếu muốn
    switch (type) {
      case DailyContentType.tip:
        return Colors.orange.shade600;
      case DailyContentType.product:
        return Colors.blue.shade600;
      case DailyContentType.expert:
        return Colors.green.shade600;
    }
  }

  Widget _buildBottomBar() {
    return BottomBar();
  }
}