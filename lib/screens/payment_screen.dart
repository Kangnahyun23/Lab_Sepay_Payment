// lib/screens/payment_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../constants.dart';
import '../services/mock_sepay_service.dart';
import '../services/sepay_service.dart';
import '../utils/format_helper.dart';
import '../utils/order_helper.dart';
import '../widgets/bank_payment_header.dart';
import '../widgets/bank_transfer_info.dart';
import '../widgets/qr_payment_frame.dart';
import '../widgets/test_guide_sheet.dart';
import '../theme/sepay_theme.dart';
import '../widgets/sepay_logo.dart';
import 'success_screen.dart';

enum PaymentPhase { waiting, checking, error, timeout }

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String currentOrderId;
  late String qrUrl;

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _elapsedSeconds = 0;
  int _remainingSeconds = AppConstants.paymentTimeoutSeconds;
  PaymentPhase _phase = PaymentPhase.waiting;
  String _statusDetail = 'Đang chờ xác nhận giao dịch';
  bool _qrLoadFailed = false;
  int _qrRetryKey = 0;
  bool _demoConfirmed = false;

  @override
  void initState() {
    super.initState();
    _generateNewOrder(restartPolling: false);
    _startPolling();
  }

  void _generateNewOrder({bool restartPolling = true}) {
    _stopTimers();
    MockSepayService.reset();

    setState(() {
      currentOrderId = OrderHelper.generateOrderId();
      qrUrl = OrderHelper.generateVietQR(
        bankId: AppConstants.bankId,
        accountNo: AppConstants.accountNo,
        accountName: AppConstants.accountName,
        amount: AppConstants.paymentAmount,
        orderId: currentOrderId,
      );
      _elapsedSeconds = 0;
      _remainingSeconds = AppConstants.paymentTimeoutSeconds;
      _phase = PaymentPhase.waiting;
      _statusDetail = AppConfig.isDemo
          ? 'Bấm "Xác nhận demo" hoặc chờ polling kiểm tra'
          : 'Quét QR hoặc mô phỏng giao dịch trên SePay';
      _qrLoadFailed = false;
      _demoConfirmed = false;
      _qrRetryKey++;
    });

    if (restartPolling) {
      _startPolling();
    }
  }

  void _startPolling() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase == PaymentPhase.timeout) {
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });

    _pollingTimer = Timer.periodic(
      Duration(seconds: AppConstants.pollingIntervalSeconds),
      (timer) async {
        _elapsedSeconds += AppConstants.pollingIntervalSeconds;

        if (_elapsedSeconds >= AppConstants.paymentTimeoutSeconds) {
          timer.cancel();
          _countdownTimer?.cancel();
          if (mounted) {
            setState(() {
              _phase = PaymentPhase.timeout;
              _statusDetail = 'Hết giờ. Tạo đơn mới để thử lại.';
            });
          }
          return;
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _phase = PaymentPhase.checking;
          _statusDetail = AppConfig.isDemo
              ? 'Polling demo — kiểm tra mỗi ${AppConstants.pollingIntervalSeconds}s'
              : 'Gọi SePay API — kiểm tra mỗi ${AppConstants.pollingIntervalSeconds}s';
        });

        final result = await SepayService.checkPaymentDetailed(
          currentOrderId,
          AppConstants.paymentAmount,
        );

        if (!mounted) {
          return;
        }

        switch (result) {
          case PaymentCheckResult.paid:
            timer.cancel();
            _countdownTimer?.cancel();
            _onPaymentSuccess(viaSimulation: AppConfig.isDemo && _demoConfirmed);
          case PaymentCheckResult.serverError:
            setState(() {
              _phase = PaymentPhase.error;
              _statusDetail = 'API Key sai. Kiểm tra file .env';
            });
          case PaymentCheckResult.networkError:
            setState(() {
              _phase = PaymentPhase.error;
              _statusDetail = 'Lỗi kết nối — thử lại lần polling sau';
            });
          case PaymentCheckResult.notPaid:
            setState(() {
              _phase = PaymentPhase.waiting;
              _statusDetail = AppConfig.isDemo
                  ? (_demoConfirmed
                      ? 'Đang chờ polling nhận giao dịch demo...'
                      : 'Chưa xác nhận — bấm "Xác nhận demo" bên dưới')
                  : 'Chưa thấy giao dịch — mô phỏng trên SePay Dashboard';
            });
        }
      },
    );
  }

  void _stopTimers() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer = null;
  }

  void _onPaymentSuccess({required bool viaSimulation}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          orderId: currentOrderId,
          viaSimulation: viaSimulation,
        ),
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huỷ thanh toán?'),
        content: const Text('Timer polling sẽ dừng và tạo đơn mới.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Huỷ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _stopTimers();
      _generateNewOrder();
    }
  }

  void _retryQrLoad() {
    setState(() {
      _qrLoadFailed = false;
      _qrRetryKey++;
    });
  }

  void _confirmDemoPayment() {
    MockSepayService.confirmDemoPayment(currentOrderId);
    setState(() {
      _demoConfirmed = true;
      _statusDetail = 'Đã xác nhận demo — polling sẽ nhận trong ~5 giây';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo: polling sẽ xác nhận thanh toán tự động'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyOrderId() async {
    await Clipboard.setData(ClipboardData(text: currentOrderId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép mã đơn — dán vào SePay Mô phỏng giao dịch'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _phaseColor() {
    return switch (_phase) {
      PaymentPhase.waiting => SepayTheme.success,
      PaymentPhase.checking => SepayTheme.primary,
      PaymentPhase.error => Colors.red,
      PaymentPhase.timeout => Colors.orange,
    };
  }

  String _phaseTitle() {
    return switch (_phase) {
      PaymentPhase.waiting => 'Đang chờ thanh toán',
      PaymentPhase.checking => 'Đang kiểm tra giao dịch',
      PaymentPhase.error => 'Có lỗi kết nối',
      PaymentPhase.timeout => 'Hết giờ thanh toán',
    };
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SepayTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            BankPaymentHeader(
              onHelpTap: () => showTestGuideSheet(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BankTransferInfo(
                      bankName: bankDisplayName(AppConstants.bankId),
                      accountNo: AppConstants.accountNo,
                      accountName: AppConstants.accountName,
                      amount: AppConstants.paymentAmount,
                      transferContent: currentOrderId,
                      countdown: formatCountdown(_remainingSeconds),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBar(),
                    const SizedBox(height: 16),
                    QrPaymentFrame(
                      qrUrl: qrUrl,
                      retryKey: _qrRetryKey,
                      loadFailed: _qrLoadFailed,
                      onRetry: _retryQrLoad,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SepayPoweredBadge(),
                    ),
                    const SizedBox(height: 20),
                    _buildActions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final color = _phaseColor();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            if (_phase == PaymentPhase.checking)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
              )
            else
              Icon(
                switch (_phase) {
                  PaymentPhase.waiting => Icons.hourglass_top_rounded,
                  PaymentPhase.error => Icons.wifi_off_rounded,
                  PaymentPhase.timeout => Icons.timer_off_rounded,
                  PaymentPhase.checking => Icons.sync,
                },
                color: color,
                size: 20,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _phaseTitle(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _statusDetail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_phase == PaymentPhase.timeout)
            FilledButton.icon(
              onPressed: () => _generateNewOrder(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tạo đơn hàng mới'),
            )
          else ...[
            if (AppConfig.isDemo)
              FilledButton.icon(
                onPressed: _demoConfirmed ? null : _confirmDemoPayment,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  _demoConfirmed
                      ? 'Đã xác nhận — chờ polling...'
                      : 'Xác nhận đã chuyển khoản (Demo)',
                ),
              )
            else ...[
              FilledButton.tonalIcon(
                onPressed: _copyOrderId,
                icon: const Icon(Icons.copy),
                label: const Text('Sao chép mã đơn hàng'),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _generateNewOrder,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Tạo QR mới'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _confirmCancel,
              icon: const Icon(Icons.close),
              label: const Text('Huỷ thanh toán'),
            ),
          ],
        ],
      ),
    );
  }
}
