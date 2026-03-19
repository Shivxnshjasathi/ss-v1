import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/features/services/domain/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController(text: 'Flat 402, Skyline Heights, Bangalore');
  final _nameController = TextEditingController(text: 'Shivansh Jasathi');
  final _phoneController = TextEditingController(text: '+91 98765 43210');

  String _formatCurrency(double amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
    return '₹$text';
  }

  void _placeOrder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1E60FF))),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      CartService().clearCart();
      context.pop(); // remove dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text('Order Placed Successfully!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Your materials will be delivered soon.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home'); // Send to home or tracking route
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();
    final total = cart.totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            CustomTextField(controller: _nameController, labelText: 'Contact Name'),
            const SizedBox(height: 16),
            CustomTextField(controller: _phoneController, labelText: 'Phone Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(controller: _addressController, labelText: 'Delivery Address'),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1E60FF)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF4FAFD),
              ),
              child: Row(
                children: const [
                  Icon(Icons.payment, color: Color(0xFF1E60FF)),
                  SizedBox(width: 16),
                  Text('Pay on Delivery / Credit Facility', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E60FF))),
                  Spacer(),
                  Icon(Icons.check_circle, color: Color(0xFF1E60FF)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            _buildSummaryRow('Items Total', total),
            const SizedBox(height: 8),
            _buildSummaryRow('Delivery Fee', 0.0),
            const SizedBox(height: 8),
            _buildSummaryRow('Tax & Charges', total * 0.05), // Example 5% GST
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(_formatCurrency(total + (total * 0.05)), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1E60FF))),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(amount == 0 ? 'FREE' : _formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
