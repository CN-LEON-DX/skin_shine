class SkinHistoryEntry {
  final String imageUrl;
  final DateTime date;
  final String notes; // Có thể thêm ghi chú hoặc kết quả phân tích sau này

  SkinHistoryEntry({
    required this.imageUrl,
    required this.date,
    this.notes = '',
  });
} 