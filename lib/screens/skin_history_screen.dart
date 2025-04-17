import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng
import '../models/skin_history_entry.dart';

class SkinHistoryScreen extends StatefulWidget {
  const SkinHistoryScreen({Key? key}) : super(key: key);

  @override
  _SkinHistoryScreenState createState() => _SkinHistoryScreenState();
}

class _SkinHistoryScreenState extends State<SkinHistoryScreen> {
  // --- Dữ liệu giả lập ---
  final List<SkinHistoryEntry> _historyEntries = [
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/FFC107/000000?text=Skin+May+20',
      date: DateTime(2024, 5, 20, 9, 15),
      notes: 'Slight improvement in hydration.'
    ),
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/FF9800/FFFFFF?text=Skin+May+10',
      date: DateTime(2024, 5, 10, 8, 30),
    ),
     SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=Skin+Apr+30',
      date: DateTime(2024, 4, 30, 20, 0),
       notes: 'Trying new serum.'
    ),
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/CDDC39/000000?text=Skin+Apr+15',
      date: DateTime(2024, 4, 15, 9, 0),
    ),
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/9C27B0/FFFFFF?text=Skin+Mar+28',
      date: DateTime(2024, 3, 28, 21, 45),
    ),
     SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/673AB7/FFFFFF?text=Skin+Mar+10',
      date: DateTime(2024, 3, 10, 8, 0),
       notes: 'Initial analysis.'
    ),
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/673AB7/FFFFFF?text=Skin+Mar+10',
      date: DateTime(2024, 3, 10, 8, 0),
       notes: 'Initial analysis.'
    ),
    SkinHistoryEntry(
      imageUrl: 'https://via.placeholder.com/150/673AB7/FFFFFF?text=Skin+Mar+10',
      date: DateTime(2024, 3, 10, 8, 0),
       notes: 'Initial analysis.'
    ),
      // Thêm các mục khác nếu muốn
  ];

  // Nhóm các mục theo tháng/năm
  Map<String, List<SkinHistoryEntry>> _groupEntriesByMonth() {
    final Map<String, List<SkinHistoryEntry>> grouped = {};
    final DateFormat monthYearFormat = DateFormat('MMMM yyyy'); // Format: May 2024

    for (var entry in _historyEntries) {
      final String monthYear = monthYearFormat.format(entry.date);
      if (grouped[monthYear] == null) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(entry);
    }
    // Sắp xếp các nhóm theo tháng năm mới nhất trước
     final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
          DateTime dateA = monthYearFormat.parse(a);
          DateTime dateB = monthYearFormat.parse(b);
          return dateB.compareTo(dateA); // Sắp xếp giảm dần
      });

    final Map<String, List<SkinHistoryEntry>> sortedGrouped = {};
    for (var key in sortedKeys) {
        sortedGrouped[key] = grouped[key]!;
    }
    return sortedGrouped;

  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupEntriesByMonth();
    final months = groupedEntries.keys.toList();
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch sẽ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Thêm chút bóng đổ nhẹ
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Skin Analysis History',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        itemCount: months.length, // Số lượng tháng có dữ liệu
        itemBuilder: (context, index) {
          final month = months[index];
          final entriesInMonth = groupedEntries[month]!;
          
          // Sắp xếp ảnh trong tháng theo ngày mới nhất trước
          entriesInMonth.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Tiêu đề Tháng/Năm ---
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 10.0),
                child: Text(
                  month,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
              // --- Danh sách ảnh trong tháng --- 
              // Sử dụng GridView để hiển thị ảnh theo dạng lưới đẹp mắt
              GridView.builder(
                shrinkWrap: true, // Quan trọng để GridView hoạt động trong ListView
                physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Số cột ảnh
                  crossAxisSpacing: 8.0, // Khoảng cách ngang
                  mainAxisSpacing: 8.0, // Khoảng cách dọc
                  childAspectRatio: 1.0, // Tỷ lệ vuông cho ảnh
                ),
                itemCount: entriesInMonth.length,
                itemBuilder: (context, itemIndex) {
                  return _buildHistoryImageItem(entriesInMonth[itemIndex]);
                },
              ),
              if (index < months.length - 1)
                 Divider(height: 30, thickness: 0.8, color: Colors.grey[200]),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị một ảnh trong GridView
  Widget _buildHistoryImageItem(SkinHistoryEntry entry) {
    final DateFormat dayFormat = DateFormat('MMM d'); // Format: May 20

    return GestureDetector(
      onTap: () {
        print('Tapped on image from: ${entry.date}');
        // TODO: Thêm hành động khi nhấn vào ảnh (ví dụ: xem chi tiết)
         _showImageDetails(context, entry);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          fit: StackFit.expand, // Để các thành phần con chiếm hết không gian
          children: [
            // --- Ảnh ---
            Image.network(
              entry.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                     value: loadingProgress.expectedTotalBytes != null
                         ? loadingProgress.cumulativeBytesLoaded /
                             loadingProgress.expectedTotalBytes!
                         : null,
                     strokeWidth: 2.0,
                     color: Theme.of(context).primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                );
              },
            ),
            // --- Lớp phủ Gradient nhẹ ở dưới để ngày tháng nổi bật ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  dayFormat.format(entry.date), // Hiển thị ngày/tháng
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Hiển thị dialog chi tiết ảnh (ví dụ)
 void _showImageDetails(BuildContext context, SkinHistoryEntry entry) {
    final DateFormat detailFormat = DateFormat('MMM d, yyyy \'at\' h:mm a');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Để dialog co lại theo nội dung
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                  entry.imageUrl, 
                  fit: BoxFit.cover,
                  // Thêm errorBuilder/loadingBuilder nếu cần
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                      detailFormat.format(entry.date),
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                   ),
                   if (entry.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Notes: ${entry.notes}',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                 ]
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
 }

} 