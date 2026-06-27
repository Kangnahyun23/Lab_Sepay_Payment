import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/sepay_theme.dart';

/// Logo / wordmark SePay cho lab
class SepayLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final Color? textColor;

  const SepayLogo({
    super.key,
    this.size = 28,
    this.showSubtitle = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'S',
              style: TextStyle(
                color: SepayTheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.55,
                height: 1,
              ),
            ),
          ),
        ),
        SizedBox(width: size * 0.35),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Se',
                    style: TextStyle(
                      color: color,
                      fontSize: size * 0.65,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Pay',
                    style: TextStyle(
                      color: SepayTheme.accent,
                      fontSize: size * 0.65,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (showSubtitle)
              Text(
                'Payment Lab · ${AppConfig.modeLabel}',
                style: TextStyle(
                  color: color.withValues(alpha: 0.75),
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Footer badge "Powered by SePay × VietQR"
class SepayPoweredBadge extends StatelessWidget {
  const SepayPoweredBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: SepayTheme.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SepayTheme.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 16, color: SepayTheme.primary),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
              children: const [
                TextSpan(text: 'Tích hợp '),
                TextSpan(
                  text: 'SePay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: SepayTheme.primary,
                  ),
                ),
                TextSpan(text: ' × '),
                TextSpan(
                  text: 'VietQR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
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
