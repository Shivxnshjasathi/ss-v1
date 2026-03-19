

class PaymentService {
  // Singleton pattern for the unified payment abstraction layer
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  Future<PaymentResult> processPayment({
    required double amount,
    required String orderId,
    String? title,
  }) async {
    // Simulate a network call and payment gateway process
    await Future.delayed(const Duration(seconds: 2));

    // Mock logic: 90% success rate
    bool isSuccess = DateTime.now().millisecond % 10 != 0;

    if (isSuccess) {
      return PaymentResult(
        isSuccess: true,
        transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Payment of ₹$amount successful via Razorpay/PhonePe Mock',
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        message: 'Payment failed due to mock server error.',
      );
    }
  }
}

class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final String message;

  PaymentResult({
    required this.isSuccess,
    this.transactionId,
    required this.message,
  });
}
