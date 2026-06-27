import 'sepay_service.dart';

class MockSepayService {
  MockSepayService._();

  static String? _confirmedOrderId;

  static void confirmDemoPayment(String orderId) {
    _confirmedOrderId = orderId;
  }

  static void reset() {
    _confirmedOrderId = null;
  }

  static Future<PaymentCheckResult> checkPaymentDetailed(
    String orderId,
    int amount,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (_confirmedOrderId == orderId) {
      return PaymentCheckResult.paid;
    }
    return PaymentCheckResult.notPaid;
  }

  static Future<bool> checkPayment(String orderId, int amount) async {
    final result = await checkPaymentDetailed(orderId, amount);
    return result == PaymentCheckResult.paid;
  }
}
