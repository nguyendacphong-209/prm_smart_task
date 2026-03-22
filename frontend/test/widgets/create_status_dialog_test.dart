import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/kanban/presentation/widgets/create_status_dialog.dart';

import '../test_utils/red_screen_guard.dart';

void main() {
  Future<void> pumpCreateStatusDialogHost(
    WidgetTester tester,
    void Function(String?) onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: appScaffoldMessengerKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (_) => const CreateStatusDialog(),
                    );
                    onResult(result);
                  },
                  child: const Text('Open Create Status Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('cancel create status dialog closes without result', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      String? capturedResult;
      await pumpCreateStatusDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Create Status Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Tạo status mới'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Tạo status mới'), findsNothing);
      expect(capturedResult, isNull);
    });
  });

  testWidgets('invalid status then cancel closes safely', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      String? capturedResult;
      await pumpCreateStatusDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Create Status Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'a');
      await tester.tap(find.text('Tạo'));
      await tester.pumpAndSettle();

      expect(find.text('Tên status tối thiểu 2 ký tự'), findsOneWidget);
      expect(find.text('Tạo status mới'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Tạo status mới'), findsNothing);
      expect(capturedResult, isNull);
    });
  });
}
