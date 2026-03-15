import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentApp {
  fib,
  nass,
}

Future<void> openPaymentApp({
  required BuildContext context,
  required PaymentApp app,
  required double amount,
}) async {
  final launched = await _launchFirstAvailable(_buildCandidates(app, amount));

  if (!context.mounted) {
    return;
  }

  if (!launched) {
    final appName = app == PaymentApp.fib ? 'FIB' : 'NASS Wallet';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$appName is not installed or does not support direct payment links yet.',
        ),
      ),
    );
  }
}

List<Uri> _buildCandidates(PaymentApp app, double amount) {
  final amountValue = amount.toStringAsFixed(2);
  final params = <String, String>{
    'amount': amountValue,
    'currency': 'USD',
    'source': 'dipstore',
    'reference': 'checkout',
  };

  switch (app) {
    case PaymentApp.fib:
      return [
        Uri(scheme: 'fibbank', host: 'payment', queryParameters: params),
        Uri(scheme: 'fibbank', host: 'pay', queryParameters: params),
        Uri(scheme: 'fibbank', queryParameters: params),
        Uri(scheme: 'fib', host: 'payment', queryParameters: params),
        Uri(scheme: 'fib', queryParameters: params),
      ];
    case PaymentApp.nass:
      return [
        Uri(scheme: 'nasswallet', host: 'payment', queryParameters: params),
        Uri(scheme: 'nasswallet', host: 'pay', queryParameters: params),
        Uri(scheme: 'nasswallet', queryParameters: params),
        Uri(scheme: 'nass', host: 'payment', queryParameters: params),
        Uri(scheme: 'nass', queryParameters: params),
      ];
  }
}

Future<bool> _launchFirstAvailable(List<Uri> candidates) async {
  for (final uri in candidates) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return true;
      }
    } catch (_) {
      continue;
    }
  }

  return false;
}