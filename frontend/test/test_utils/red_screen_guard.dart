import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> runWithRedScreenGuard(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  final originalOnError = FlutterError.onError;
  final capturedErrors = <FlutterErrorDetails>[];

  FlutterError.onError = (details) {
    capturedErrors.add(details);
  };

  try {
    await body();
    await tester.pump();

    final frameworkException = tester.takeException();
    if (frameworkException != null) {
      fail('Framework exception detected (red-screen risk): $frameworkException');
    }

    if (capturedErrors.isNotEmpty) {
      final message = capturedErrors
          .map((error) => error.exceptionAsString())
          .join('\n---\n');
      fail('FlutterError detected (red-screen risk):\n$message');
    }
  } finally {
    FlutterError.onError = originalOnError;
  }
}