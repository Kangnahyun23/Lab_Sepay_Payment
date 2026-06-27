import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../theme/sepay_theme.dart';
import '../utils/format_helper.dart';
import '../widgets/sepay_logo.dart';
import 'payment_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String orderId;
  final bool viaSimulation;

  const SuccessScreen({
    super.key,
    required this.orderId,
    this.viaSimulation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SepayTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              decoration: const BoxDecoration(
                gradient: SepayTheme.successGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SepayLogo(size: 32, showSubtitle: false),
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giao dịch thành công',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    viaSimulation
                        ? 'SePay Demo — xác nhận polling giả lập'
                        : 'SePay đã xác nhận qua Polling API',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '${formatVnd(AppConstants.paymentAmount)} VNĐ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: SepayTheme.primaryDark,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _ReceiptRow(
                        label: 'Mã đơn hàng',
                        value: orderId,
                        onCopy: () => _copy(context, orderId),
                      ),
                      _ReceiptRow(
                        label: 'Ngân hàng',
                        value: bankDisplayName(AppConstants.bankId),
                      ),
                      _ReceiptRow(
                        label: 'Số tài khoản',
                        value: AppConstants.accountNo,
                      ),
                      _ReceiptRow(
                        label: 'Thời gian',
                        value: _nowFormatted(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      PaymentScreen.routeName,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thanh toán đơn mới'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép')),
    );
  }

  static String _nowFormatted() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final mo = now.month.toString().padLeft(2, '0');
    return '$d/$mo/${now.year} $h:$m';
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
