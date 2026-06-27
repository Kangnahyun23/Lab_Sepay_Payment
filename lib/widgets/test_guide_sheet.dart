import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../utils/format_helper.dart';

void showTestGuideSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hướng dẫn test SePay Lab',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConfig.modeLabel,
                  style: TextStyle(
                    color: AppConfig.isDemo
                        ? Colors.orange.shade800
                        : const Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                if (AppConfig.isDemo) ...[
                  const _GuideStep(
                    number: 1,
                    title: 'Xem mã QR',
                    body: 'App tự sinh Order ID và hiển thị QR VietQR demo.',
                  ),
                  const _GuideStep(
                    number: 2,
                    title: 'Xác nhận demo',
                    body:
                        'Bấm "Xác nhận đã chuyển khoản (Demo)" — polling giả lập '
                        'sẽ nhận giao dịch sau ~5 giây.',
                  ),
                  const _GuideStep(
                    number: 3,
                    title: 'Màn thành công',
                    body: 'App tự chuyển sang màn Success khi polling khớp.',
                  ),
                  const SizedBox(height: 12),
                  _NoteBox(
                    text:
                        'Clone git chạy ngay ở chế độ DEMO — không cần tài khoản SePay.',
                  ),
                ] else ...[
                  const _GuideStep(
                    number: 1,
                    title: 'Copy mã đơn hàng',
                    body: 'Sao chép nội dung chuyển khoản (ORD...) trên màn hình.',
                  ),
                  const _GuideStep(
                    number: 2,
                    title: 'Mô phỏng trên SePay',
                    body:
                        'my.sepay.vn (Test mode) → Mô phỏng giao dịch → '
                        'chọn TK, số tiền đúng, dán mã ORD → Gửi.',
                  ),
                  _GuideStep(
                    number: 3,
                    title: 'Chờ polling',
                    body:
                        'App gọi SePay API mỗi ${AppConfig.pollingIntervalSeconds}s '
                        'và tự chuyển Success khi khớp.',
                  ),
                  const SizedBox(height: 12),
                  _NoteBox(
                    text:
                        'Mô phỏng: ${AppConfig.accountNo} · '
                        '${formatVnd(AppConfig.paymentAmount)} VNĐ',
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _GuideStep extends StatelessWidget {
  final int number;
  final String title;
  final String body;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1565C0),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String text;

  const _NoteBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.4),
      ),
    );
  }
}
