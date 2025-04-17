import 'package:flutter/material.dart';
import '../screens/skin_history_screen.dart'; // Import màn hình lịch sử

class BottomBar extends StatelessWidget {
  final VoidCallback? onFlarePressed;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onFacePressed;
  
  const BottomBar({
    Key? key,
    this.onFlarePressed,
    this.onCameraPressed,
    this.onFacePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Tăng độ mờ đục chút
        borderRadius: BorderRadius.circular(30), // Bo tròn nhiều
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8, // Tăng blur cho shadow đẹp hơn
            offset: Offset(0, 4), // Shadow nhẹ phía dưới
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Phân bố đều các icon
        children: [
          IconButton(
            icon: Icon(Icons.flare_outlined, color: Colors.grey[600], size: 28), // Icon tia sáng/flare
            onPressed: onFlarePressed ?? () {
              // Điều hướng đến màn hình lịch sử
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SkinHistoryScreen()),
              );
            },
          ),
          Container( // Làm nổi bật nút camera
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.camera_alt_rounded, color: Colors.purple[700], size: 32),
              onPressed: onCameraPressed ?? () {
                print('Camera icon tapped');
              },
              padding: EdgeInsets.zero, // Bỏ padding mặc định của IconButton
              constraints: BoxConstraints(), // Bỏ giới hạn kích thước mặc định
            ),
          ),
          IconButton(
             // Icon mặt cười/chăm sóc da (thay bằng icon phù hợp hơn nếu có)
            icon: Icon(Icons.face_retouching_natural_outlined, color: Colors.grey[600], size: 28),
            onPressed: onFacePressed ?? () { print('Face icon tapped'); },
          ),
        ],
      ),
    );
  }
} 