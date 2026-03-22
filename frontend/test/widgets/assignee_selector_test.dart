import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/assignee_selector.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

import '../test_utils/red_screen_guard.dart';

void main() {
  const members = [
    WorkspaceMember(
      id: 'member-1',
      userId: 'user-1',
      email: 'a@example.com',
      fullName: 'Alice',
      avatarUrl: null,
      role: 'member',
    ),
    WorkspaceMember(
      id: 'member-2',
      userId: 'user-2',
      email: 'b@example.com',
      fullName: 'Bob',
      avatarUrl: null,
      role: 'member',
    ),
  ];

  Future<void> pumpAssigneeSelector(
    WidgetTester tester,
    Set<String> selected,
    void Function(Set<String>) onChanged,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: appScaffoldMessengerKey,
        home: Scaffold(
          body: AssigneeSelector(
            assigneeOptions: members,
            selectedAssigneeIds: selected,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('select assignee then cancel does not call onChanged', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      Set<String>? latestSelection;
      await pumpAssigneeSelector(tester, {}, (value) => latestSelection = value);

      await tester.tap(find.text('Chọn'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn thành viên'), findsNothing);
      expect(latestSelection, isNull);
      expect(find.text('Chưa chọn assignee'), findsOneWidget);
    });
  });

  testWidgets('select assignee then save updates selected chips', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      Set<String> selectedIds = {};
      await pumpAssigneeSelector(tester, selectedIds, (value) {
        selectedIds = value;
      });

      await tester.tap(find.text('Chọn'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(selectedIds, contains('user-1'));
    });
  });
}