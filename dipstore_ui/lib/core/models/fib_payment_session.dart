class FibPaymentSession {
  final String paymentId;
  final String qrCode;
  final String readableCode;
  final String validUntil;
  final String personalAppLink;
  final String businessAppLink;
  final String corporateAppLink;

  const FibPaymentSession({
    required this.paymentId,
    required this.qrCode,
    required this.readableCode,
    required this.validUntil,
    required this.personalAppLink,
    required this.businessAppLink,
    required this.corporateAppLink,
  });

  factory FibPaymentSession.fromJson(Map<String, dynamic> json) {
    return FibPaymentSession(
      paymentId: (json['paymentId'] ?? '').toString(),
      qrCode: (json['qrCode'] ?? '').toString(),
      readableCode: (json['readableCode'] ?? '').toString(),
      validUntil: (json['validUntil'] ?? '').toString(),
      personalAppLink: (json['personalAppLink'] ?? '').toString(),
      businessAppLink: (json['businessAppLink'] ?? '').toString(),
      corporateAppLink: (json['corporateAppLink'] ?? '').toString(),
    );
  }

  List<FibAppLink> get appLinks {
    return [
      FibAppLink(label: 'Personal App', url: personalAppLink),
      FibAppLink(label: 'Business App', url: businessAppLink),
      FibAppLink(label: 'Corporate App', url: corporateAppLink),
    ].where((link) => link.url.isNotEmpty).toList(growable: false);
  }
}

class FibAppLink {
  final String label;
  final String url;

  const FibAppLink({required this.label, required this.url});
}