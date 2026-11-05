import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthSessionModel.fromJson', () {
    test('parses the backend login response', () {
      final session = AuthSessionModel.fromJson({
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'userId': 'user-id',
        'email': 'person@example.com',
        'fullName': 'Example Person',
      });

      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, 'refresh-token');
      expect(session.user.id, 'user-id');
      expect(session.user.email, 'person@example.com');
      expect(session.user.fullName, 'Example Person');
    });

    test('rejects a response without tokens or user identity', () {
      expect(
        () => AuthSessionModel.fromJson({
          'accessToken': '',
          'refreshToken': 'refresh-token',
          'userId': 'user-id',
          'email': 'person@example.com',
        }),
        throwsFormatException,
      );
    });
  });
}
