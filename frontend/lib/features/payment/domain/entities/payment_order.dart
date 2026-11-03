class PaymentOrder {
  const PaymentOrder({required this.id, required this.orderCode, required this.amount, required this.planCode, required this.status, this.checkoutUrl, this.qrCode});
  final String id;
  final int orderCode;
  final int amount;
  final String planCode;
  final String status;
  final String? checkoutUrl;
  final String? qrCode;

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => PaymentOrder(
    id: json['id'].toString(), orderCode: (json['orderCode'] as num).toInt(), amount: (json['amount'] as num).toInt(),
    planCode: json['planCode'].toString(), status: json['status'].toString(), checkoutUrl: json['checkoutUrl']?.toString(), qrCode: json['qrCode']?.toString());
}
