import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/task/application/providers/task_pin_provider.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_pin_button.dart';
import 'package:prm_smart_task/features/task/presentation/pages/pinned_tasks_page.dart';

void main() {
  const task = PinnedTask(
    taskId: 't',
    projectId: 'p',
    workspaceId: 'w',
    title: 'Task test',
    projectName: 'Project test',
  );
  testWidgets('toggle pin and unpin updates state after successful requests', (
    tester,
  ) async {
    bool pinned = false;
    final calls = <String>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            calls.add('${o.method} ${o.path}');
            pinned = o.method == 'PUT';
            h.resolve(Response(requestOptions: o, statusCode: 204));
          },
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          taskPinsProvider.overrideWith((ref) async => pinned ? [task] : []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TaskPinButton(taskId: 't')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ghim task cho tôi'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Bỏ ghim task'), findsOneWidget);
    await tester.tap(find.byTooltip('Bỏ ghim task'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ghim task cho tôi'), findsOneWidget);
    expect(calls, ['PUT /api/tasks/t/pin', 'DELETE /api/tasks/t/pin']);
  });
  testWidgets('failed save keeps unpinned state', (tester) async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.reject(DioException(requestOptions: o)),
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          taskPinsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TaskPinButton(taskId: 't')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ghim task cho tôi'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ghim task cho tôi'), findsOneWidget);
    expect(
      find.text('Không cập nhật được ghim. Vui lòng thử lại.'),
      findsOneWidget,
    );
  });
  testWidgets('list shows task and project', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskPinsProvider.overrideWith((ref) async => [task]),
        ],
        child: const MaterialApp(home: PinnedTasksPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Task test'), findsOneWidget);
    expect(find.text('Project test'), findsOneWidget);
  });
}
