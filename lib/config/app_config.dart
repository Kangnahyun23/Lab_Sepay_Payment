import 'package:flutter_dotenv/flutter_dotenv.dart';

enum RunMode { demo, sandbox, live }

class AppConfig {
  AppConfig._();

  static RunMode runMode = RunMode.demo;
  static bool envLoaded = false;

  static String apiKey = '';
  static String bankId = 'TPB';
  static String accountNo = '00000000000';
  static String accountName = 'TEN CUA HANG DEMO';
  static String accountBankId = '';
  static int pollingIntervalSeconds = 5;
  static int paymentTimeoutSeconds = 300;
  static int paymentAmount = 10000;

  static bool get isDemo => runMode == RunMode.demo;
  static bool get isSandbox => runMode == RunMode.sandbox;
  static bool get isLive => runMode == RunMode.live;

  /// Lab compatibility alias
  static bool get isTestMode => isSandbox;

  static String get modeLabel {
    return switch (runMode) {
      RunMode.demo => 'DEMO',
      RunMode.sandbox => 'SANDBOX',
      RunMode.live => 'LIVE',
    };
  }

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      envLoaded = true;
    } catch (_) {
      try {
        await dotenv.load(fileName: '.env.example');
        envLoaded = true;
      } catch (_) {
        envLoaded = false;
      }
    }
    _applyFromEnv();
  }

  static void _applyFromEnv() {
    String env(String key, String fallback) {
      if (!envLoaded) {
        return fallback;
      }
      return dotenv.env[key]?.trim() ?? fallback;
    }

    apiKey = env('SEPAY_API_KEY', '');
    bankId = env('BANK_ID', 'TPB');
    accountNo = env('ACCOUNT_NO', '00000000000');
    accountName = env('ACCOUNT_NAME', 'TEN CUA HANG DEMO');
    accountBankId = env('ACCOUNT_BANK_ID', '');
    pollingIntervalSeconds =
        int.tryParse(env('POLLING_INTERVAL_SECONDS', '5')) ?? 5;
    paymentTimeoutSeconds =
        int.tryParse(env('PAYMENT_TIMEOUT_SECONDS', '300')) ?? 300;
    paymentAmount = int.tryParse(env('PAYMENT_AMOUNT', '10000')) ?? 10000;

    final modeStr = env('SEPAY_RUN_MODE', 'demo').toLowerCase();
    if (apiKey.isEmpty) {
      runMode = RunMode.demo;
    } else if (modeStr == 'live') {
      runMode = RunMode.live;
    } else if (modeStr == 'sandbox') {
      runMode = RunMode.sandbox;
    } else {
      runMode = RunMode.demo;
    }
  }

  static String transactionsListUrl({String? searchOrderId}) {
    if (isSandbox) {
      final query = searchOrderId != null && searchOrderId.isNotEmpty
          ? 'per_page=20&q=${Uri.encodeComponent(searchOrderId)}'
          : 'per_page=20';
      return 'https://userapi-sandbox.sepay.vn/v2/transactions?$query';
    }
    return 'https://my.sepay.vn/userapi/transactions/list'
        '?account_bank_id=$accountBankId&limit=20';
  }
}
