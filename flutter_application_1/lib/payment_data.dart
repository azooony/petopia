import 'package:flutter/foundation.dart';

class PaymentRequest {
  final String doctorName;
  final String day;
  final String time;
  final String fee;
  final Uint8List screenshotBytes;
  String status; // 'pending' | 'approved' | 'rejected'

  PaymentRequest({
    required this.doctorName,
    required this.day,
    required this.time,
    required this.fee,
    required this.screenshotBytes,
    this.status = 'pending',
  });
}

class PaymentRepository {
  static final List<PaymentRequest> requests = [];
  static final ValueNotifier<PaymentRequest?> latestUpdate = ValueNotifier(null);

  static void approve(PaymentRequest r) {
    r.status = 'approved';
    latestUpdate.value = null;
    latestUpdate.value = r;
  }

  static void reject(PaymentRequest r) {
    r.status = 'rejected';
    latestUpdate.value = null;
    latestUpdate.value = r;
  }
}
