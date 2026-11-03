import 'package:dio/dio.dart';
import 'package:prm_smart_task/features/payment/domain/entities/payment_order.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PaymentOrder> create(String planCode) async {
    try {
      final response = await _dio.post(
        '/api/payments/create',
        data: {'planCode': planCode},
      );
      return PaymentOrder.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<PaymentOrder> getStatus(String id) async {
    final response = await _dio.get('/api/payments/$id');
    return PaymentOrder.fromJson(response.data as Map<String, dynamic>);
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? 'Không thể tạo thanh toán';
  }
}
