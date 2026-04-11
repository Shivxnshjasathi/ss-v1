import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/features/services/domain/cart_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

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

    final l10n = AppLocalizations.of(context)!;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      CartService().clearCart();
      context.pop(); // remove dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60.w),
              SizedBox(height: 16.h),
              Text(l10n.orderSuccess, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp)),
              SizedBox(height: 8.h),
              Text(l10n.orderSuccessSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home'); // Send to home or tracking route
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w))),
                  child: Text(l10n.backToHome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final l10n = AppLocalizations.of(context)!;
    final cart = CartService();
    final total = cart.totalPrice;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 16.w),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.checkoutTitle, style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deliveryAddress, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            CustomTextField(controller: _nameController, labelText: l10n.contactName),
            SizedBox(height: 16.h),
            CustomTextField(controller: _phoneController, labelText: l10n.phoneNumber, keyboardType: TextInputType.phone),
            SizedBox(height: 16.h),
            CustomTextField(controller: _addressController, labelText: l10n.deliveryAddress),
            SizedBox(height: 32.h),
            Text(l10n.paymentMethod, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1E60FF)),
                borderRadius: BorderRadius.circular(12.w),
                color: const Color(0xFFF4FAFD),
              ),
              child: Row(
                children: [
                   Icon(Icons.payment, color: Color(0xFF1E60FF)),
                   SizedBox(width: 16.w),
                   Text(l10n.payOnDelivery, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E60FF))),
                   const Spacer(),
                   Icon(Icons.check_circle, color: Color(0xFF1E60FF)),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(l10n.orderSummary, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _buildSummaryRow(l10n.itemsTotal, total, l10n),
            SizedBox(height: 8.h),
            _buildSummaryRow(l10n.deliveryFee, 0.0, l10n),
            SizedBox(height: 8.h),
            _buildSummaryRow(l10n.taxCharges, total * 0.05, l10n), // Example 5% GST
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.grandTotal, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                Text(_formatCurrency(total + (total * 0.05)), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp, color: Color(0xFF1E60FF))),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              ),
              child: Text(l10n.confirmOrder, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(amount == 0 ? l10n.free : _formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
