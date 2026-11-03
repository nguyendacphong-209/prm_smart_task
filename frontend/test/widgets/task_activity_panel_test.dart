import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_activity_panel.dart';

void main() {
  Future<void> mount(WidgetTester tester, Dio dio) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TaskActivityPanel(taskId: 'task-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty history and refresh', (tester) async {
    var requests = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'content': [], 'last': true},
              ),
            );
          },
        ),
      );
    await mount(tester, dio);
    expect(find.text('Chưa có thay đổi được ghi nhận.'), findsOneWidget);
    await tester.tap(find.byTooltip('Làm mới lịch sử'));
    await tester.pumpAndSettle();
    expect(requests, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows actor, before/after and paginates', (tester) async {
    final pages = <int>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final page = options.queryParameters['page'] as int;
            pages.add(page);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'content': [
                    {
                      'actorName': 'Huy',
                      'createdAt': '2026-10-31T01:00:00Z',
                      'field': 'title',
                      'oldValue': 'Old $page',
                      'newValue': 'New $page',
                    },
                  ],
                  'last': page == 1,
                },
              ),
            );
          },
        ),
      );
    await mount(tester, dio);
    expect(find.textContaining('Trước: Old 0'), findsOneWidget);
    await tester.tap(find.text('Xem thêm'));
    await tester.pumpAndSettle();
    expect(pages, [0, 1]);
    expect(find.textContaining('Trước: Old 1'), findsOneWidget);
    expect(find.text('Xem thêm'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('failure offers retry and recovers', (tester) async {
    var requests = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (requests++ == 0) {
              handler.reject(DioException(requestOptions: options));
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'content': [], 'last': true},
              ),
            );
          },
        ),
      );
    await mount(tester, dio);
    expect(find.text('Thử lại'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có thay đổi được ghi nhận.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
