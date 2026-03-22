import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/workspace/presentation/widgets/invite_member_dialog.dart';

import '../test_utils/red_screen_guard.dart';

void main() {
  Future<void> pumpInviteDialogHost(
    WidgetTester tester,
    void Function(InviteMemberPayload?) onResult,
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
                    final result = await showDialog<InviteMemberPayload>(
                      context: context,
                      builder: (_) => const InviteMemberDialog(),
                    );
                    onResult(result);
                  },
                  child: const Text('Open Invite Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('cancel invite dialog closes without result', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      InviteMemberPayload? capturedResult;
      await pumpInviteDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Invite Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Mời thành viên'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Mời thành viên'), findsNothing);
      expect(capturedResult, isNull);
    });
  });

  testWidgets('fill invite form then cancel still closes without submit result', (
    tester,
  ) async {
    await runWithRedScreenGuard(tester, () async {
      InviteMemberPayload? capturedResult;
      await pumpInviteDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Invite Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'member@example.com',
      );
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Mời thành viên'), findsNothing);
      expect(capturedResult, isNull);
    });
  });
}
