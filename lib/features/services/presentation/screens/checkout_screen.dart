import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 70.sp),
              SizedBox(height: 24.h),
              Text(
                l10n.orderSuccess,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20.sp,
                  fontFamily: 'Poppins',
                  color: context.primaryTextColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.orderSuccessSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.sp)),
                  ),
                  child: Text(
                    l10n.backToHome.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(14.sp),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: context.iconColor,
                  size: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              l10n.checkoutTitle,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 24.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deliveryAddress,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22.sp,
                fontFamily: 'Poppins',
                color: context.primaryTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildInputSection(l10n.contactName, _nameController),
            SizedBox(height: 16.h),
            _buildInputSection(l10n.phoneNumber, _phoneController, keyboardType: TextInputType.phone),
            SizedBox(height: 16.h),
            _buildInputSection(l10n.deliveryAddress, _addressController),
            SizedBox(height: 32.h),
            Text(
              l10n.paymentMethod,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18.sp,
                fontFamily: 'Poppins',
                color: context.primaryTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
                borderRadius: BorderRadius.circular(20.sp),
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Icon(Icons.payment, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    l10n.payOnDelivery,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                      color: AppTheme.primaryBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 24.sp),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              l10n.orderSummary,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18.sp,
                fontFamily: 'Poppins',
                color: context.primaryTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSummaryRow(l10n.itemsTotal, total, l10n),
            SizedBox(height: 10.h),
            _buildSummaryRow(l10n.deliveryFee, 0.0, l10n),
            SizedBox(height: 10.h),
            _buildSummaryRow(l10n.taxCharges, total * 0.05, l10n),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Divider(color: context.borderColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.grandTotal,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    color: context.primaryTextColor,
                  ),
                ),
                Text(
                  _formatCurrency(total + (total * 0.05)),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24.sp,
                    fontFamily: 'Poppins',
                    color: AppTheme.primaryBlue,
                  ),
                ),
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
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
              ),
              child: Text(
                l10n.confirmOrder.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.2,
                ),
              ),
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
        Text(
          label,
          style: TextStyle(
            color: context.secondaryTextColor,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            fontSize: 13.sp,
          ),
        ),
        Text(
          amount == 0 ? l10n.free : _formatCurrency(amount),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: context.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10.sp,
            fontFamily: 'Poppins',
            color: AppTheme.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(color: context.borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: context.primaryTextColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }
}
