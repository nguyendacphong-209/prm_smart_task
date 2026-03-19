import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AuthSessionModel> register({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'avatarUrl': avatarUrl,
        },
      );

      return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {
          'refreshToken': refreshToken,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AuthUserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return AuthUserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AuthUserModel> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.me,
        data: {
          'fullName': fullName,
          'avatarUrl': avatarUrl,
        },
      );

      return AuthUserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _dio.put(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối tới server đang chậm. Có thể Render đang khởi động, vui lòng thử lại sau 30-60 giây.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối tới server. Vui lòng kiểm tra mạng hoặc thử lại sau.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? 'Request failed';
  }
}
