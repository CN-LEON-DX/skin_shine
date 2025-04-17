import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/bottom_bar.dart';

class SkinAnalysisScreen extends StatefulWidget {
  final File? capturedImage;
  
  const SkinAnalysisScreen({Key? key, this.capturedImage}) : super(key: key);

  @override
  _SkinAnalysisScreenState createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen> {
  // --- Dữ liệu giả lập cho kết quả phân tích ---
  // Trong ứng dụng thực tế, dữ liệu này sẽ đến từ API hoặc logic phân tích
  final double overallHealth = 0.85; // 85%
  final String acneLevel = 'Good';
  final String pigmentationLevel = 'Moderate';
  final String poreSizeLevel = 'Excellent';
  bool _isAnalyzing = false;
  bool _hasResults = false;

  @override
  void initState() {
    super.initState();
    // Nếu có ảnh, bắt đầu phân tích
    if (widget.capturedImage != null) {
      _startAnalysis();
    }
  }

  // Giả lập quá trình phân tích
  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _hasResults = false;
    });
    
    // Giả lập đợi phân tích 3 giây
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
        _hasResults = true;
      });
    });
  }

  // Helper để lấy màu dựa trên mức độ
  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
      case 'good':
        return Colors.green.shade600;
      case 'moderate':
        return Colors.orange.shade600;
      case 'fair':
      case 'poor':
        return Colors.red.shade600;
      default:
        return Colors.grey; // Màu mặc định
    }
  }

   // Helper để lấy giá trị progress dựa trên mức độ
  double _getProgressForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'excellent': return 0.9;
      case 'good': return 0.7;
      case 'moderate': return 0.5;
      case 'fair': return 0.3;
      case 'poor': return 0.1;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu chính từ theme
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Skin Analysis',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[600]),
            tooltip: 'Analysis Info',
            onPressed: () {
              // Hiển thị dialog trợ giúp
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('About Skin Analysis'),
                        content: Text(
                            'Upload a clear photo in good lighting for the most accurate results. The analysis provides insights into various skin aspects and recommendations based on the findings.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('OK'))
                        ],
                      ));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Phần Chụp/Tải Ảnh ---
                _buildPhotoSection(context, primaryColor),
                const SizedBox(height: 20),

                // --- Phần Hướng dẫn Chụp Ảnh ---
                if (!_hasResults) _buildGuidelinesSection(context),
                
                // --- Hiển thị trạng thái phân tích ---
                if (_isAnalyzing) _buildAnalyzingSection(),
                
                // --- Phần Kết quả Phân tích ---
                if (_hasResults) ...[
                  _buildSectionTitle(context, 'Analysis Results'),
                  _buildAnalysisResultCard(
                    context,
                    title: 'Overall Skin Health',
                    valueText: '${(overallHealth * 100).toInt()}%',
                    progress: overallHealth,
                    progressColor: primaryColor,
                  ),
                  _buildAnalysisResultCard(
                    context,
                    title: 'Acne Analysis',
                    valueText: acneLevel,
                    progress: _getProgressForLevel(acneLevel),
                    progressColor: _getColorForLevel(acneLevel),
                    valueColor: _getColorForLevel(acneLevel),
                  ),
                  _buildAnalysisResultCard(
                    context,
                    title: 'Pigmentation',
                    valueText: pigmentationLevel,
                    progress: _getProgressForLevel(pigmentationLevel),
                    progressColor: _getColorForLevel(pigmentationLevel),
                    valueColor: _getColorForLevel(pigmentationLevel),
                  ),
                  _buildAnalysisResultCard(
                    context,
                    title: 'Pore Size',
                    valueText: poreSizeLevel,
                    progress: _getProgressForLevel(poreSizeLevel),
                    progressColor: _getColorForLevel(poreSizeLevel),
                    valueColor: _getColorForLevel(poreSizeLevel),
                  ),
                  const SizedBox(height: 20),

                  // --- Phần Gợi ý ---
                  _buildSectionTitle(context, 'Recommendations'),
                  _buildRecommendationsSection(context),
                ],

                const SizedBox(height: 100), // Khoảng trống cho bottom bar
              ],
            ),
          ),
          
          // Bottom navigation bar (shared)
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: BottomBar(
              onCameraPressed: () {
                // Navigate to camera
                _navigateToCamera(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Điều hướng đến màn hình chụp ảnh và quay lại với ảnh mới
  void _navigateToCamera(BuildContext context) async {
    // Ở đây sẽ điều hướng sang màn hình chụp ảnh
    // Đây là code mẫu, bạn có thể thay thế bằng plugin camera thực tế
    
    // Mẫu hiển thị thông báo khi tính năng chưa hoàn thiện
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera functionality would be implemented here'))
    );
    
    // Khi có ảnh rồi sẽ bắt đầu phân tích
    // _startAnalysis();
  }

  // --- Widget Builders ---
  
  // Hiển thị trạng thái đang phân tích
  Widget _buildAnalyzingSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Analyzing your skin...',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please wait while our AI analyzes your skin condition',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Hiển thị ảnh nếu có, nếu không hiển thị icon
            if (widget.capturedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  widget.capturedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(Icons.image_search_outlined, size: 50, color: primaryColor.withOpacity(0.8)),
            
            const SizedBox(height: 15),
            Text(
              widget.capturedImage != null ? 'Your Skin Photo' : 'Take or Upload Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'For best results, ensure good lighting and no makeup',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt_outlined, size: 20),
              label: Text(widget.capturedImage != null ? 'Take Another Photo' : 'Take Photo'),
              onPressed: () => _navigateToCamera(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45), // Đảm bảo nút rộng và cao đủ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: Icon(Icons.upload_file_outlined, size: 20),
              label: Text('Upload from Gallery'),
              onPressed: () {
                // Logic tải ảnh từ thư viện
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gallery picker would be implemented here'))
                );
              },
              style: OutlinedButton.styleFrom(
                 foregroundColor: primaryColor,
                 side: BorderSide(color: primaryColor.withOpacity(0.7)),
                 minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                 textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildGuidelinesSection(BuildContext context) {
    return Card(
       elevation: 2,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Photo Guidelines',
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 12),
             _buildGuidelineItem(context, 'Good lighting, preferably natural'),
             _buildGuidelineItem(context, 'Clean face without makeup'),
             _buildGuidelineItem(context, 'Face directly towards camera'),
          ],
        ),
      ),
    );
   }

  Widget _buildGuidelineItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600], size: 18),
          const SizedBox(width: 10),
          Expanded( // Để text dài tự xuống dòng
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildAnalysisResultCard(
     BuildContext context, {
     required String title,
     required String valueText,
     required double progress,
     required Color progressColor,
     Color? valueColor, // Màu tùy chọn cho giá trị text
   }) {
    return Card(
       elevation: 2,
       margin: const EdgeInsets.only(bottom: 12), // Khoảng cách giữa các card kết quả
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.9)),
                ),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? progressColor, // Dùng màu progress nếu không có màu riêng
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect( // Bo tròn thanh progress
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                 value: progress,
                 backgroundColor: Colors.grey[200],
                 valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                 minHeight: 8, // Độ dày thanh progress
              ),
            ),
          ],
        ),
      ),
    );
   }

   Widget _buildRecommendationsSection(BuildContext context) {
      return Card(
       elevation: 2,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Không cần title riêng nếu đã có _buildSectionTitle ở ngoài
             _buildRecommendationItem(context, 'Use a gentle cleanser twice daily to maintain clear pores'),
             _buildRecommendationItem(context, 'Apply sunscreen SPF 30+ to prevent pigmentation'),
             _buildRecommendationItem(context, 'Consider using vitamin C serum for even skin tone'),
             // Thêm nút xem sản phẩm gợi ý (liên kết với màn hình product_suggestions_screen)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TextButton(
                  onPressed: () {
                    // Điều hướng đến màn hình gợi ý sản phẩm
                    Navigator.pushNamed(context, '/product_suggestions');
                  },
                  child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text('See Product Suggestions', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                       SizedBox(width: 5),
                       Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).primaryColor),
                     ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
   }

   Widget _buildRecommendationItem(BuildContext context, String text) {
     return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
         crossAxisAlignment: CrossAxisAlignment.start, // Căn icon và text theo dòng đầu
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0), // Dịch icon xuống chút cho thẳng hàng
            child: Icon(Icons.star_border_purple500_outlined, color: Colors.amber[700], size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
   }
} 