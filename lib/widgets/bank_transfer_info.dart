import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sepay_theme.dart';
import '../utils/format_helper.dart';

class BankTransferInfo extends StatelessWidget {
  final String bankName;
  final String accountNo;
  final String accountName;
  final int amount;
  final String transferContent;
  final String countdown;

  const BankTransferInfo({
    super.key,
    required this.bankName,
    required this.accountNo,
    required this.accountName,
    required this.amount,
    required this.transferContent,
    required this.countdown,
  });

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  '${formatVnd(amount)} VNĐ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: SepayTheme.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Hết hạn sau $countdown',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              _InfoRow(
                label: 'Ngân hàng',
                value: bankName,
                onCopy: () => _copy(context, bankName, 'ngân hàng'),
              ),
              _InfoRow(
                label: 'Số tài khoản',
                value: accountNo,
                onCopy: () => _copy(context, accountNo, 'số tài khoản'),
              ),
              _InfoRow(
                label: 'Chủ tài khoản',
                value: accountName,
                onCopy: () => _copy(context, accountName, 'tên TK'),
              ),
              _InfoRow(
                label: 'Nội dung CK',
                value: transferContent,
                highlight: true,
                onCopy: () => _copy(context, transferContent, 'nội dung CK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? SepayTheme.primary : Colors.black87,
                fontFamily: highlight ? 'monospace' : null,
              ),
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Sao chép',
          ),
        ],
      ),
    );
  }
}
