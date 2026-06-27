import 'package:flutter_test/flutter_test.dart';
import 'package:sepay_payment_lab/config/app_config.dart';
import 'package:sepay_payment_lab/main.dart';

void main() {
  testWidgets('Payment screen loads with bank UI', (WidgetTester tester) async {
    await AppConfig.init();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Quét mã chuyển khoản'), findsOneWidget);
    expect(find.textContaining('SePay'), findsWidgets);
    expect(find.text('Quét mã để chuyển khoản'), findsOneWidget);
  });
}
