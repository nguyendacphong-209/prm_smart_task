import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_form_dialog.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import '../test_utils/red_screen_guard.dart';

void main() {
  Future<void> pumpDialogHost(
    WidgetTester tester,
    void Function(TaskFormResult?) onResult,
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
                    final result = await showDialog<TaskFormResult>(
                      context: context,
                      builder: (_) => TaskFormDialog(
                        dialogTitle: 'Tạo task mới',
                        confirmLabel: 'Tạo task',
                        statusOptions: const [
                          TaskStatusOption(id: 'status-1', name: 'Todo'),
                        ],
                        assigneeOptions: const [
                          WorkspaceMember(
                            id: 'member-1',
                            userId: 'user-1',
                            email: 'member@example.com',
                            fullName: 'Member One',
                            avatarUrl: null,
                            role: 'member',
                          ),
                        ],
                        labelOptions: const [
                          TaskLabelOption(
                            id: 'label-1',
                            name: 'Bug',
                            color: '#FF0000',
                          ),
                        ],
                        initialTitle: '',
                        initialDescription: '',
                        initialPriority: 'medium',
                        initialDeadline: null,
                        initialStatusId: 'status-1',
                        initialAssigneeIds: {'user-1'},
                        initialLabelIds: {'label-1'},
                        deadlineButtonLabel: 'Chọn deadline',
                      ),
                    );
                    onResult(result);
                  },
                  child: const Text('Open Task Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> pumpEditDialogHost(
    WidgetTester tester,
    void Function(TaskFormResult?) onResult,
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
                    final result = await showDialog<TaskFormResult>(
                      context: context,
                      builder: (_) => TaskFormDialog(
                        dialogTitle: 'Cập nhật task',
                        confirmLabel: 'Lưu',
                        statusOptions: const [
                          TaskStatusOption(id: 'status-1', name: 'Todo'),
                        ],
                        assigneeOptions: const [
                          WorkspaceMember(
                            id: 'member-1',
                            userId: 'user-1',
                            email: 'member@example.com',
                            fullName: 'Member One',
                            avatarUrl: null,
                            role: 'member',
                          ),
                        ],
                        labelOptions: const [
                          TaskLabelOption(
                            id: 'label-1',
                            name: 'Bug',
                            color: '#FF0000',
                          ),
                        ],
                        initialTitle: 'Existing task',
                        initialDescription: 'Existing description',
                        initialPriority: 'medium',
                        initialDeadline: null,
                        initialStatusId: 'status-1',
                        initialAssigneeIds: {'user-1'},
                        initialLabelIds: {'label-1'},
                        deadlineButtonLabel: 'Đổi deadline',
                      ),
                    );
                    onResult(result);
                  },
                  child: const Text('Open Edit Task Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('shows validation message when title is too short', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      TaskFormResult? capturedResult;
      await pumpDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Task Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'ab');
      await tester.tap(find.text('Tạo task'));
      await tester.pumpAndSettle();

      expect(find.text('Tiêu đề tối thiểu 3 ký tự'), findsOneWidget);
      expect(capturedResult, isNull);
    });
  });

  testWidgets('returns payload when form is valid', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      TaskFormResult? capturedResult;
      await pumpDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Task Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Implement tests');
      await tester.enterText(
        find.byType(TextField).at(1),
        'Create smoke test suite',
      );

      await tester.tap(find.text('Tạo task'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNotNull);
      expect(capturedResult!.title, 'Implement tests');
      expect(capturedResult!.description, 'Create smoke test suite');
      expect(capturedResult!.priority, 'medium');
      expect(capturedResult!.statusId, 'status-1');
      expect(capturedResult!.assigneeIds, contains('user-1'));
      expect(capturedResult!.labelIds, contains('label-1'));
    });
  });

  testWidgets('cancel edit task dialog closes without result', (tester) async {
    await runWithRedScreenGuard(tester, () async {
      TaskFormResult? capturedResult;
      await pumpEditDialogHost(tester, (result) => capturedResult = result);

      await tester.tap(find.text('Open Edit Task Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cập nhật task'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Cập nhật task'), findsNothing);
      expect(capturedResult, isNull);
    });
  });
}
