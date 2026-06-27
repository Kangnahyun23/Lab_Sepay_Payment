// lib/services/sepay_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../constants.dart';
import 'mock_sepay_service.dart';

enum PaymentCheckResult { paid, notPaid, networkError, serverError }

class SepayService {
  static Future<bool> checkPayment(String orderId, int amount) async {
    final result = await checkPaymentDetailed(orderId, amount);
    return result == PaymentCheckResult.paid;
  }

  static Future<PaymentCheckResult> checkPaymentDetailed(
    String orderId,
    int amount,
  ) async {
    if (AppConfig.isDemo) {
      return MockSepayService.checkPaymentDetailed(orderId, amount);
    }
    return _checkPaymentViaApi(orderId, amount);
  }

  static Future<PaymentCheckResult> _checkPaymentViaApi(
    String orderId,
    int amount,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(AppConstants.transactionsListUrl(searchOrderId: orderId)),
            headers: {
              'Authorization': 'Bearer ${AppConstants.apiKey}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 401) {
        return PaymentCheckResult.serverError;
      }
      if (response.statusCode != 200) {
        return PaymentCheckResult.networkError;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final txns = _extractTransactions(data);

      final found = txns.any((t) => _matchesPayment(t, orderId, amount));

      return found ? PaymentCheckResult.paid : PaymentCheckResult.notPaid;
    } on TimeoutException {
      return PaymentCheckResult.networkError;
    } catch (e) {
      // ignore: avoid_print
      print('SePay API error: $e');
      return PaymentCheckResult.networkError;
    }
  }

  static List<dynamic> _extractTransactions(Map<String, dynamic> data) {
    if (AppConfig.isSandbox) {
      if (data['status'] != 'success') {
        return [];
      }
      return (data['data'] as List?) ?? [];
    }
    return (data['transactions'] as List?) ?? [];
  }

  static bool _matchesPayment(
    dynamic transaction,
    String orderId,
    int amount,
  ) {
    final content = transaction['transaction_content']?.toString() ?? '';
    final amountIn =
        int.tryParse(transaction['amount_in']?.toString() ?? '0') ?? 0;
    final accountNumber = transaction['account_number']?.toString() ?? '';

    final accountMatches = AppConfig.isSandbox
        ? accountNumber == AppConstants.accountNo || accountNumber.isEmpty
        : true;

    return accountMatches &&
        content.contains(orderId) &&
        amountIn >= amount;
  }
}
