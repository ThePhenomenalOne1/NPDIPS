import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import '../models/fib_payment_session.dart';

class FibPaymentService {
  const FibPaymentService();

  Future<FibPaymentSession> createPayment({
    required double amount,
    required String description,
  }) async {
    final response = await http
        .post(
          Uri.parse('$backendBaseUrl/api/fib/create-payment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': amount.toStringAsFixed(2),
            'description': description,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('FIB payment request timed out'),
        );

    final Map<String, dynamic> data = _decodeJson(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception((data['message'] ?? 'Failed to create FIB payment').toString());
    }

    if (_isOtpOnlyBackendResponse(data)) {
      throw Exception(
        'The configured backend is still running the old OTP-only deployment. Deploy the updated `dipstore_backend` project before using FIB payments.',
      );
    }

    final payment = data['payment'];
    if (payment is! Map<String, dynamic>) {
      throw Exception(
        'FIB payment route responded, but no payment session was returned. Check the backend deployment and FIB server response.',
      );
    }

    return FibPaymentSession.fromJson(payment);
  }

  Future<String> checkPaymentStatus(String paymentId) async {
    final response = await http
        .get(
          Uri.parse(
            '$backendBaseUrl/api/fib/payment-status?paymentId=${Uri.encodeQueryComponent(paymentId)}',
          ),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('FIB payment status request timed out'),
        );

    final Map<String, dynamic> data = _decodeJson(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception((data['message'] ?? 'Failed to check FIB payment status').toString());
    }

    if (_isOtpOnlyBackendResponse(data)) {
      throw Exception(
        'The configured backend is still running the old OTP-only deployment. Deploy the updated `dipstore_backend` project before checking FIB payment status.',
      );
    }

    return (data['status'] ?? 'UNKNOWN').toString();
  }

  bool _isOtpOnlyBackendResponse(Map<String, dynamic> data) {
    return data['message'] == 'DipStore OTP API' && data['endpoints'] is List;
  }

  Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected backend response format');
  }
}