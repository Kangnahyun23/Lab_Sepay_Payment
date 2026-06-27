// lib/utils/order_helper.dart
import 'dart:math';

class OrderHelper {
  /// Sinh mã đơn hàng độc nhất: ORD + timestamp + random 4 số
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ORD$timestamp$random';
    // Ví dụ kết quả: ORD17051234567891234
  }

  /// Sinh URL ảnh QR từ VietQR API (miễn phí, không cần đăng ký)
  static String generateVietQR({
    required String bankId,
    required String accountNo,
    required String accountName,
    required int amount,
    required String orderId,
  }) {
    final addInfo = Uri.encodeComponent(orderId);
    return 'https://img.vietqr.io/image/'
        '$bankId-$accountNo-compact2.png'
        '?amount=$amount'
        '&addInfo=$addInfo'
        '&accountName=$accountName';
  }
}
