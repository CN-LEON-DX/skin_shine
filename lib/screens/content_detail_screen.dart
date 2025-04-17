import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/daily_content.dart'; // Import model

class ContentDetailScreen extends StatelessWidget {
  final DailyContent content;

  const ContentDetailScreen({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content.title), // Lấy tiêu đề từ content
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh nếu có
            if (content.imageUrl != null)
              ClipRRect(
                 borderRadius: BorderRadius.circular(12.0),
                 child: Image.network(
                   content.imageUrl!,
                   width: double.infinity,
                   fit: BoxFit.cover,
                   // Thêm errorBuilder/loadingBuilder nếu cần
                  ),
              ),
            if (content.imageUrl != null)
               const SizedBox(height: 20),

            // Hiển thị tiêu đề lớn hơn
            Text(
              content.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color
              ),
            ),
            const SizedBox(height: 10),

            // Hiển thị tên chuyên gia nếu có
            if (content.type == DailyContentType.expert && content.expertName != null)
              Text(
                'By ${content.expertName}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
             if (content.type == DailyContentType.expert && content.expertName != null)
               const SizedBox(height: 15),

            // Hiển thị nội dung đầy đủ
            Text(
              content.fullContent,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.6, // Tăng khoảng cách dòng cho dễ đọc
                color: Theme.of(context).textTheme.bodyMedium?.color
              ),
            ),
          ],
        ),
      ),
    );
  }
} 