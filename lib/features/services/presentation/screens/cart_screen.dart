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
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 16.w),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.myCart, style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18.sp)),
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80.w, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text(l10n.cartEmpty, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
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
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12.w),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(item.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getLocalizedCategoryName(item.category, l10n).toUpperCase(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                              SizedBox(height: 4.h),
                              Text(item.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                              SizedBox(height: 8.h),
                              Text('${_formatCurrency(item.price)} / ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E60FF))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatCurrency(item.price * item.quantity), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                            SizedBox(height: 8.h),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: context.borderColor),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, size: 16.w),
                                    onPressed: () => cart.decrementQuantity(item.id),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                  IconButton(
                                    icon: Icon(Icons.add, size: 16.w),
                                    onPressed: () => cart.incrementQuantity(item.id),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          Text(l10n.totalAmount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(_formatCurrency(cart.totalPrice), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: Color(0xFF1E60FF))),
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
                            backgroundColor: const Color(0xFF1E60FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                          ),
                          child: Text(l10n.proceedToCheckout, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: Colors.white)),
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
