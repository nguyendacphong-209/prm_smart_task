import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prm_smart_task/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/test_utils/red_screen_guard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app opens login and can navigate to register then back', (
    tester,
  ) async {
    await runWithRedScreenGuard(tester, () async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SmartTaskApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập'), findsWidgets);

      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng ký'), findsWidgets);

      await tester.tap(find.text('Đã có tài khoản? Quay lại đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập'), findsWidgets);
    });
  });
}
