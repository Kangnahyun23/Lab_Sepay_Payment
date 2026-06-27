// lib/constants.dart
import 'config/app_config.dart';

/// Wrapper theo yêu cầu lab — đọc cấu hình từ AppConfig / .env
class AppConstants {
  static bool get isTestMode => AppConfig.isTestMode;
  static bool get isDemo => AppConfig.isDemo;

  static String get apiKey => AppConfig.apiKey;
  static String get bankId => AppConfig.bankId;
  static String get accountNo => AppConfig.accountNo;
  static String get accountName => AppConfig.accountName;
  static String get accountBankId => AppConfig.accountBankId;

  static int get pollingIntervalSeconds => AppConfig.pollingIntervalSeconds;
  static int get paymentTimeoutSeconds => AppConfig.paymentTimeoutSeconds;
  static int get paymentAmount => AppConfig.paymentAmount;

  static String transactionsListUrl({String? searchOrderId}) =>
      AppConfig.transactionsListUrl(searchOrderId: searchOrderId);
}
