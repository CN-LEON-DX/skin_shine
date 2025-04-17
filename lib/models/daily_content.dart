enum DailyContentType { tip, product, expert }

class DailyContent {
  final String title;
  final String shortDescription; // Mô tả ngắn gọn hiển thị trên card
  final DailyContentType type;
  final String? imageUrl; // Ảnh minh họa (tùy chọn)
  final String fullContent; // Nội dung chi tiết (sẽ dùng ở màn hình detail)
  final String? expertName; // Tên chuyên gia (nếu type là expert)

  DailyContent({
    required this.title,
    required this.shortDescription,
    required this.type,
    this.imageUrl,
    required this.fullContent,
    this.expertName,
  });
} 