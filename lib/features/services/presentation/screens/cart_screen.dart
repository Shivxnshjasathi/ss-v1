import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/services/domain/cart_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cart = CartService();

  String _formatCurrency(double amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
    return '₹$text';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.myCart,
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
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80.w, color: context.borderColor),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.cartEmpty,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: context.secondaryTextColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(24.w),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => Divider(height: 32.h),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(18.sp),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(item.image),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: context.borderColor),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLocalizedCategoryName(item.category, l10n).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryBlue,
                                    letterSpacing: 1.2,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.sp,
                                    fontFamily: 'Poppins',
                                    color: context.primaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '${_formatCurrency(item.price)} / ${item.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                    fontFamily: 'Poppins',
                                    color: context.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(item.price * item.quantity),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                  fontFamily: 'Poppins',
                                  color: context.primaryTextColor,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: context.surfaceColor,
                                  border: Border.all(color: context.borderColor),
                                  borderRadius: BorderRadius.circular(10.sp),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => cart.decrementQuantity(item.id),
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        child: Icon(Icons.remove, size: 14.sp, color: context.primaryTextColor),
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.sp,
                                        fontFamily: 'Poppins',
                                        color: context.primaryTextColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => cart.incrementQuantity(item.id),
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        child: Icon(Icons.add, size: 14.sp, color: context.primaryTextColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: context.scaffoldColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.totalAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: context.secondaryTextColor,
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            _formatCurrency(cart.totalPrice),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 26.sp,
                              fontFamily: 'Poppins',
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/services/marketplace/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.sp),
                            ),
                          ),
                          child: Text(
                            l10n.proceedToCheckout.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLocalizedCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'All': return l10n.all;
      case 'Cement': return l10n.cement;
      case 'Steel': return l10n.steel;
      case 'Bricks': return l10n.bricks;
      case 'Paint': return l10n.paint;
      case 'Basics': return l10n.basics;
      default: return category;
    }
  }
}
