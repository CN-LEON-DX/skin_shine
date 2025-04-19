import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';

class SkinProgressScreen extends StatefulWidget {
  @override
  _SkinProgressScreenState createState() => _SkinProgressScreenState();
}

class _SkinProgressScreenState extends State<SkinProgressScreen> {
  String _selectedTimeRange = 'Last 30 Days'; // Giá trị mặc định cho dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Không cần AppBar nếu header là một phần của body cuộn
      body: SafeArea(
        child: Stack(
          children: [
            // Content area with scrolling
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: Back Button, Title and Dropdown ---
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // --- Chart Area Placeholder ---
                  _buildChartArea(),
                  const SizedBox(height: 15),

                  // --- Chart Legend ---
                  _buildChartLegend(),
                  const SizedBox(height: 30),

                  // --- Before & After Section ---
                  _buildBeforeAfterSection(),
                  const SizedBox(height: 30),

                  // --- Update Prompt ---
                  _buildUpdatePrompt(),
                  const SizedBox(height: 30),

                  // --- Recent Improvements Section ---
                  _buildRecentImprovements(),
                  const SizedBox(height: 100), // Extra spacing for the bottom bar
                ],
              ),
            ),
            
            // Bottom bar positioned at the bottom
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng Header with back button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 20, color: Colors.black87),
              ),
            ),
            SizedBox(width: 15),
            // Title
            Text(
              'Skin Health\nProgress', // Xuống dòng nếu cần
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3, // Điều chỉnh khoảng cách dòng
              ),
            ),
          ],
        ),
        // Dropdown giả lập (thay bằng DropdownButton thật nếu cần)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline( // Ẩn đường gạch dưới mặc định
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              isDense: true, // Làm cho dropdown nhỏ gọn hơn
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              style: TextStyle(color: Colors.black87, fontSize: 13),
              items: <String>['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'All Time']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeRange = newValue!;
                });
                // Thêm logic xử lý khi thay đổi lựa chọn ở đây
                print('Selected: $newValue');
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget xây dựng thanh dưới cùng tùy chỉnh (tương tự trong HomeScreen)
  Widget _buildBottomBar() {
    return BottomBar(
      // Có thể tùy chỉnh hành động của các nút nếu cần
      onCameraPressed: () {
        print('Camera pressed in Progress Screen');
        // Thêm logic chụp ảnh so sánh nếu cần
      },
    );
  }

  // Widget chart area
  Widget _buildChartArea() {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.purple[50]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jan 1', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text('Jan 15', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text('Jan 30', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                'Chart Placeholder', // Hoặc để trống
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng phần chú thích biểu đồ
  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Phân bố đều
      children: [
        _buildLegendItem(Colors.purple, 'Hydration'),
        _buildLegendItem(Colors.blue, 'Acne'),
        _buildLegendItem(Colors.green, 'Wrinkles'),
      ],
    );
  }

  // Widget trợ giúp cho một mục trong chú thích
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // Widget xây dựng phần Before & After
  Widget _buildBeforeAfterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Before & After',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            // --- Before Image ---
            Expanded(child: _buildImageWithLabel('Before', 'https://via.placeholder.com/300x400/ddeeff/000000?text=Before+Image')), // Placeholder URL
            // --- Slider Icon ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                padding: EdgeInsets.all(4),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, spreadRadius: 1)
                   ]
                 ),
                child: Icon(Icons.compare_arrows_outlined, color: Colors.grey[600], size: 20)
              ),
            ),
            // --- After Image ---
            Expanded(child: _buildImageWithLabel('After', 'https://via.placeholder.com/300x400/eeddee/000000?text=After+Image')), // Placeholder URL
          ],
        ),
      ],
    );
  }

  // Widget trợ giúp để hiển thị ảnh với nhãn "Before"/"After"
  Widget _buildImageWithLabel(String label, String imageUrl) {
    // Bạn nên thay thế placeholder URL bằng Image.asset hoặc URL thực tế
    // Sử dụng `CachedNetworkImage` nếu ảnh từ mạng để có caching
    return ClipRRect( // Để bo góc cho ảnh
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio( // Duy trì tỷ lệ khung hình
        aspectRatio: 3/4, // Tỷ lệ ví dụ, điều chỉnh nếu cần
        child: Stack(
          fit: StackFit.expand, // Làm cho ảnh và nhãn chiếm hết không gian
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover, // Đảm bảo ảnh che phủ toàn bộ không gian
              // Hiển thị loading trong khi tải ảnh
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ));
              },
              // Hiển thị lỗi nếu không tải được
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
            // Nhãn "Before" / "After"
            Positioned(
              top: 10,
              left: 10, // Hoặc căn giữa nếu muốn
              child: Chip(
                label: Text(label),
                backgroundColor: Colors.black.withOpacity(0.5),
                labelStyle: TextStyle(color: Colors.white, fontSize: 11),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                visualDensity: VisualDensity.compact, // Làm chip nhỏ gọn hơn
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng phần nhắc nhở cập nhật
  Widget _buildUpdatePrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Icon Chuông
          Container(
             padding: EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.blue[100],
               shape: BoxShape.circle,
             ),
            child: Icon(Icons.notifications_active_outlined, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 15),
          // Phần Text và Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time for an Update!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Take a new photo to track your progress',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[700]?.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    print('Take Photo button pressed');
                    // Thêm hành động chụp ảnh ở đây
                  },
                  child: Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600], // Màu nút đậm hơn
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng phần cải thiện gần đây
  Widget _buildRecentImprovements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Improvements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        // Mục cải thiện 1
        _buildImprovementItem(
          icon: Icons.water_drop_outlined, // Icon giọt nước/hydration
          iconColor: Colors.green[700]!,
          bgColor: Colors.green[50]!,
          text: 'Hydration increased by 15% in the past two weeks',
          highlightColor: Colors.green[800]!,
        ),
        const SizedBox(height: 10),
        // Mục cải thiện 2
        _buildImprovementItem(
          icon: Icons.trending_down_outlined, // Icon xu hướng giảm/acne reduced
          iconColor: Colors.purple[700]!,
          bgColor: Colors.purple[50]!,
          text: 'Acne reduced by 30% since last month',
          highlightColor: Colors.purple[800]!,
        ),
      ],
    );
  }

  // Widget trợ giúp cho một mục cải thiện
  Widget _buildImprovementItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    required Color highlightColor, // Màu cho phần trăm/số liệu
  }) {
    // Tách văn bản để làm nổi bật phần số liệu (ví dụ: 15% hoặc 30%)
    // Đây là cách đơn giản, bạn có thể cần logic phức tạp hơn nếu cấu trúc câu thay đổi
    RegExp regex = RegExp(r'(\d+%?)'); // Tìm số có hoặc không có %
    Match? match = regex.firstMatch(text);
    String firstPart = text;
    String numberPart = '';
    String lastPart = '';

    if (match != null) {
       numberPart = match.group(0)!;
       int startIndex = match.start;
       int endIndex = match.end;
       firstPart = text.substring(0, startIndex);
       lastPart = text.substring(endIndex);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            // Sử dụng RichText để tạo kiểu khác nhau cho các phần của văn bản
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13.5, color: Colors.black87.withOpacity(0.9), height: 1.4), // Kiểu mặc định
                children: <TextSpan>[
                  TextSpan(text: firstPart), // Phần đầu của câu
                  TextSpan(
                    text: numberPart, // Phần số liệu
                    style: TextStyle(fontWeight: FontWeight.bold, color: highlightColor), // Làm đậm và đổi màu
                  ),
                   TextSpan(text: lastPart), // Phần cuối của câu
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 