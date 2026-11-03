import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/task/presentation/pages/label_management_page.dart';

void main() {
  Future<void> mount(WidgetTester tester, Dio dio) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: const MaterialApp(
          home: LabelManagementPage(projectId: 'project-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('create, rename, recolor, cancel delete and delete', (
    tester,
  ) async {
    final labels = <Map<String, dynamic>>[];
    final mutations = <String>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (o.method != 'GET') {
              mutations.add(o.method);
            }
            if (o.method == 'POST') {
              labels.add({
                'id': 'label-1',
                ...Map<String, dynamic>.from(o.data as Map),
              });
            }
            if (o.method == 'PUT') {
              labels[0] = {
                'id': 'label-1',
                ...Map<String, dynamic>.from(o.data as Map),
              };
            }
            if (o.method == 'DELETE') {
              labels.clear();
            }
            h.resolve(
              Response(
                requestOptions: o,
                data: o.method == 'GET'
                    ? labels.map((e) => Map<String, dynamic>.from(e)).toList()
                    : null,
              ),
            );
          },
        ),
      );
    await mount(tester, dio);
    expect(find.textContaining('Chưa có nhãn'), findsOneWidget);
    await tester.tap(find.text('Tạo nhãn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập tên nhãn'), findsOneWidget);
    expect(mutations, isEmpty);
    await tester.enterText(find.byType(TextFormField).first, ' Bug ');
    await tester.tap(find.byTooltip('#F44336'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Bug'), findsOneWidget);
    expect(labels.single['color'], '#F44336');
    await tester.tap(find.byTooltip('Sửa nhãn'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Backend');
    await tester.tap(find.byTooltip('#4CAF50'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Backend'), findsOneWidget);
    expect(labels.single['color'], '#4CAF50');
    await tester.tap(find.byTooltip('Xóa nhãn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(labels, hasLength(1));
    await tester.tap(find.byTooltip('Xóa nhãn'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa nhãn'));
    await tester.pumpAndSettle();
    expect(labels, isEmpty);
    expect(mutations, ['POST', 'PUT', 'DELETE']);
    expect(tester.takeException(), isNull);
  });
  testWidgets('load error retries and forbidden save preserves form', (
    tester,
  ) async {
    var loads = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (o.method == 'GET' && loads++ > 0) {
              h.resolve(Response(requestOptions: o, data: <dynamic>[]));
            } else {
              h.reject(
                DioException(
                  requestOptions: o,
                  response: Response(requestOptions: o, statusCode: 403),
                ),
              );
            }
          },
        ),
      );
    await mount(tester, dio);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo nhãn'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Frontend');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(
      find.text('Chỉ chủ workspace hoặc admin được quản lý nhãn.'),
      findsOneWidget,
    );
    expect(find.text('Frontend'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
