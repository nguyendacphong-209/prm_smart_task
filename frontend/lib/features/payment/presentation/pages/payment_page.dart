import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:prm_smart_task/features/payment/domain/entities/payment_order.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});
  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String selectedPlan = 'VIP_1_MONTH';
  bool loading = false;
  Timer? pollTimer;
  String? currentPaymentId;

  static const plans = {
    'VIP_1_MONTH': (label: '1 tháng', amount: 49000, months: 1),
    'VIP_3_MONTH': (label: '3 tháng', amount: 129000, months: 3),
    'VIP_1_YEAR': (label: '1 năm', amount: 399000, months: 12),
  };

  @override
  void dispose() { pollTimer?.cancel(); super.dispose(); }

  Future<void> createPayment() async {
    setState(() => loading = true);
    try {
      final source = PaymentRemoteDataSource(ref.read(dioProvider));
      final payment = await source.create(selectedPlan);
      currentPaymentId = payment.id;
      if (payment.qrCode == null && payment.checkoutUrl == null) {
        throw Exception('PayOS không trả về mã QR hoặc liên kết thanh toán');
      }
      pollTimer?.cancel();
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => checkPayment(source));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PaymentQrDialog(payment: payment, onClose: () { pollTimer?.cancel(); Navigator.of(context).pop(); }),
      );
    } catch (e) {
      showAppSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> checkPayment(PaymentRemoteDataSource source) async {
    if (currentPaymentId == null) return;
    try {
      final payment = await source.getStatus(currentPaymentId!);
      if (payment.status == 'PAID') {
        pollTimer?.cancel();
        await ref.read(authControllerProvider.notifier).refreshMe();
        if (!mounted) return;
        showAppSnack('Thanh toán thành công! Tài khoản VIP đã được kích hoạt.');
        Navigator.of(context).pop();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider.select((value) => value.user));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nâng cấp VIP'), leading: BackButton(onPressed: () { pollTimer?.cancel(); Navigator.of(context).maybePop(); })),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SMART TASK VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 8),
          Text(user?.vip == true ? 'Đang kích hoạt VIP' : 'Mở khóa đầy đủ tính năng', style: const TextStyle(color: Colors.white70)),
        ])),
        const SizedBox(height: 20),
        Text('Chọn gói VIP', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...plans.entries.map((entry) { final plan = entry.value; final selected = selectedPlan == entry.key; return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => setState(() => selectedPlan = entry.key), borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: selected ? scheme.primary.withValues(alpha: 0.12) : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 1.5)), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: scheme.primary), const SizedBox(width: 12), Expanded(child: Text(plan.label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${plan.amount ~/ 1000}.000đ', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800))])))); }),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: loading ? null : createPayment, icon: const Icon(Icons.payments_rounded), label: Text(loading ? 'Đang tạo mã QR...' : 'Nạp VIP bằng mã QR PayOS'))),
        const SizedBox(height: 12), const Text('Quét QR bằng ứng dụng ngân hàng. Trạng thái được xác nhận tự động qua PayOS.', textAlign: TextAlign.center),
      ])),
    );
  }
}

class _PaymentQrDialog extends StatelessWidget {
  const _PaymentQrDialog({required this.payment, required this.onClose});
  final PaymentOrder payment;
  final VoidCallback onClose;

  Future<void> openCheckout() async {
    final url = payment.checkoutUrl;
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrData = payment.qrCode;
    return AlertDialog(
      title: const Text('Quét mã QR để thanh toán'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (qrData != null && qrData.isNotEmpty)
          Container(width: 260, height: 260, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: qrData, version: QrVersions.auto, backgroundColor: Colors.white))
        else
          const Padding(padding: EdgeInsets.all(20), child: Icon(Icons.qr_code_2_rounded, size: 140)),
        const SizedBox(height: 12),
        Text('${payment.amount ~/ 1000}.000đ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Mã đơn: ${payment.orderCode}', textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text('Sử dụng ứng dụng ngân hàng quét mã. Không đóng màn hình khi đang chờ xác nhận.', textAlign: TextAlign.center),
      ])),
      actions: [
        if (payment.checkoutUrl != null)
          TextButton(onPressed: openCheckout, child: const Text('Mở trình thanh toán')),
        FilledButton(onPressed: onClose, child: const Text('Đóng')),
      ],
    );
  }
}
