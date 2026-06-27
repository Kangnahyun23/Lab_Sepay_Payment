import 'package:flutter/material.dart';

import '../theme/sepay_theme.dart';

class QrPaymentFrame extends StatelessWidget {
  final String qrUrl;
  final int retryKey;
  final bool loadFailed;
  final VoidCallback onRetry;

  const QrPaymentFrame({
    super.key,
    required this.qrUrl,
    required this.retryKey,
    required this.loadFailed,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _BrandChip(label: 'SePay', color: SepayTheme.primary),
              const SizedBox(width: 8),
              _BrandChip(label: 'VietQR', color: const Color(0xFFE53935)),
              const SizedBox(width: 8),
              _BrandChip(label: 'Napas', color: SepayTheme.primaryDark),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: SepayTheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SePay QR Payment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SepayTheme.primaryDark,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Quét mã để chuyển khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                if (loadFailed)
                  Column(
                    children: [
                      Icon(Icons.qr_code_2,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('Không tải được mã QR'),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: onRetry,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      qrUrl,
                      key: ValueKey(retryKey),
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) {
                          return child;
                        }
                        return SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, st) {
                        return SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: TextButton(
                              onPressed: onRetry,
                              child: const Text('Tải lại QR'),
                            ),
                          ),
                        );
                      },
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

class _BrandChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BrandChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
