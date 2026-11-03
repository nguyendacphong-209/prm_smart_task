import 'package:dio/dio.dart';
import 'package:prm_smart_task/features/payment/domain/entities/payment_order.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PaymentOrder> create(String planCode) async {
    final response = await _dio.post('/api/payments/create', data: {'planCode': planCode});
    return PaymentOrder.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentOrder> getStatus(String id) async {
    final response = await _dio.get('/api/payments/$id');
    return PaymentOrder.fromJson(response.data as Map<String, dynamic>);
  }
}
